#!/usr/bin/env python3
"""標準入力のJSONを、使い捨てのagyセッションへ一度だけ渡す。"""

import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile


MODEL = "gemini-4-argon-high"
AGENT = "argon-rewrite"
TIMEOUT_SECONDS = 600
TEMPLATE = Path(__file__).resolve().parents[1] / "assets" / "argon-rewrite.md"


def reject_constant(value):
    raise ValueError(f"JSONでは{value}を使えません")


def read_input(raw):
    try:
        value = json.loads(raw.decode("utf-8"), parse_constant=reject_constant)
    except (UnicodeError, ValueError) as exc:
        raise ValueError(f"入力はUTF-8 JSONで指定してください: {exc}") from exc
    if not isinstance(value, dict):
        raise ValueError("入力はJSONオブジェクトで指定してください")
    if not isinstance(value.get("text"), str) or not value["text"].strip():
        raise ValueError("textは空でない文字列で指定してください")
    if "context" in value and not isinstance(value["context"], str):
        raise ValueError("contextは文字列で指定してください")
    payload = {"text": value["text"], "context": value.get("context", "")}
    # JSONのエスケープで渡された不正なUnicodeも、送信前に拒否する。
    json.dumps(payload, ensure_ascii=False).encode("utf-8")
    return payload


def validate_output(raw, returncode, workspace):
    try:
        events = [json.loads(line, parse_constant=reject_constant)
                  for line in raw.decode("utf-8").splitlines() if line.strip()]
    except (UnicodeError, ValueError) as exc:
        raise ValueError(f"agyの応答が不正なUTF-8/JSONです: {exc}") from exc
    if not events or any(not isinstance(e, dict) for e in events):
        raise ValueError(f"agyの応答イベントがありません、または不正です (終了コード {returncode})")
    results = [e.get("result") for e in events if e.get("event") == "result"]
    if not results or not isinstance(results[-1], dict):
        raise ValueError(f"agyのresultがありません、または不正です (終了コード {returncode})")
    result = results[-1]
    if returncode != 0 or result.get("status") != "SUCCESS":
        raise ValueError(f"agy失敗: 終了コード {returncode}, status={result.get('status')}, "
                         f"理由={result.get('error') or '標準エラーの診断を確認してください'}")
    if result.get("denied_actions"):
        raise ValueError("agyでツール操作が拒否されています。結果は採用しません")
    if len(results) != 1 or events[-1].get("event") != "result":
        raise ValueError("agyの最終resultまたはターン数が不正です")
    if events[0].get("event") != "init" or sum(e.get("event") == "init" for e in events) != 1:
        raise ValueError("agyのinitがありません、または重複しています")
    init = events[0].get("init")
    if not isinstance(init, dict):
        raise ValueError("agyのinitが不正です")
    print("argon-rewrite: init " + json.dumps(init, ensure_ascii=False), file=sys.stderr)
    if (init.get("model") != MODEL or init.get("agent") != AGENT
            or init.get("permission_mode") != "strict"
            or not isinstance(init.get("cwd"), str)
            or Path(init["cwd"]).resolve() != Path(workspace).resolve()
            or not isinstance(init.get("tools"), list)
            or any(not isinstance(t, str) for t in init["tools"])):
        raise ValueError("agyのモデル・Agent・cwd・権限・ツール情報が要求と一致しません")
    for event in events[1:-1]:
        step = event.get("step_update")
        if event.get("event") != "step_update" or not isinstance(step, dict):
            raise ValueError("agyに未対応の応答イベントがあります")
        if (step.get("step_type") not in {"user_input", "agent_response", "checkpoint"}
                or any(k in step for k in ("tool_name", "tool_info", "subagent_info"))):
            raise ValueError("agyにツール操作または未対応のstepがあります。結果は採用しません")
    response = result.get("response")
    if not isinstance(response, str) or not response.strip():
        raise ValueError("agyのresponseが空、または文字列ではありません")
    response.encode("utf-8")
    print("argon-rewrite: SUCCESS, tool_steps=0", file=sys.stderr)
    return response


def kill_process_group(proc):
    try:
        os.killpg(proc.pid, signal.SIGKILL)
    except ProcessLookupError:
        pass
    proc.communicate()


def rewrite(payload):
    executable = shutil.which("agy")
    if not executable:
        raise ValueError("agyがPATHにありません。導入済みのagyを使える環境で実行してください")
    message = json.dumps({"event": "user", "message": {
        "content": json.dumps(payload, ensure_ascii=False)
    }}, ensure_ascii=False).encode("utf-8") + b"\n"
    with tempfile.TemporaryDirectory(prefix="argon-rewrite-") as workspace:
        agent_file = Path(workspace) / ".agents" / "agents" / f"{AGENT}.md"
        agent_file.parent.mkdir(parents=True)
        shutil.copyfile(TEMPLATE, agent_file)
        settings = {"toolPermission": "strict", "agentMode": "", "allowNonWorkspaceAccess": False}
        command = [executable, "--model", MODEL, "--agent", AGENT,
                   "--settings", json.dumps(settings), "--disable-slash-commands",
                   "--input-format", "stream-json", "--output-format", "stream-json",
                   "--print-timeout", f"{TIMEOUT_SECONDS}s"]
        proc = subprocess.Popen(command, cwd=workspace, stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                start_new_session=True)
        try:
            stdout, stderr = proc.communicate(message, timeout=TIMEOUT_SECONDS)
        except subprocess.TimeoutExpired as exc:
            kill_process_group(proc)
            raise ValueError(f"agyが{TIMEOUT_SECONDS}秒でタイムアウトしました。起動した処理を終了しました") from exc
        except BaseException:
            kill_process_group(proc)
            raise
        if stderr:
            sys.stderr.write(stderr.decode("utf-8", errors="replace"))
        return validate_output(stdout, proc.returncode, workspace)


def main():
    try:
        response = rewrite(read_input(sys.stdin.buffer.read()))
    except (OSError, ValueError) as exc:
        print(f"argon-rewrite: {exc}", file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        print("argon-rewrite: 中断しました", file=sys.stderr)
        return 130
    sys.stdout.buffer.write(response.encode("utf-8"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
