"""外部送信を行わない契約テスト: python3 -m unittest discover -s scripts"""

import contextlib
from concurrent.futures import ThreadPoolExecutor
import io
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time
import unittest
from unittest.mock import patch

import rewrite


def stream(workspace, response="本文です。", status="SUCCESS", **changes):
    init = {"model": rewrite.MODEL, "agent": rewrite.AGENT,
            "cwd": str(workspace), "permission_mode": "strict", "tools": ["view_file"]}
    init.update(changes)
    return [
        {"event": "init", "init": init},
        {"event": "step_update", "step_update": {
            "step_type": "agent_response", "text_delta": "途中出力"}},
        {"event": "result", "result": {"status": status, "response": response}},
    ]


def encode(events):
    return ("\n".join(json.dumps(e, ensure_ascii=False) for e in events) + "\n").encode()


class RewriteTests(unittest.TestCase):
    def validate(self, events, code=0):
        with contextlib.redirect_stderr(io.StringIO()):
            return rewrite.validate_output(encode(events), code, "/tmp/workspace")

    def test_input(self):
        self.assertEqual(rewrite.read_input('{"text":"/確認\\n本文"}'.encode()),
                         {"text": "/確認\n本文", "context": ""})
        for raw in [b"", b"{", b"[]", b"null", b"{}", b'{"text":1}',
                    b'{"text":"  "}', b'{"text":"a","context":null}',
                    b'{"text":"a","context":1}', b'\xff', b'{"text":"\\ud800"}',
                    b'{"text":"a","extra":NaN}', b'{"text":Infinity}']:
            with self.subTest(raw=raw), self.assertRaises(ValueError):
                rewrite.read_input(raw)

    def test_success_returns_only_final_response(self):
        self.assertEqual(self.validate(stream("/tmp/workspace")), "本文です。")

    def test_failures_never_return_response(self):
        cases = [([], 0), ([None], 0), (stream("/tmp/workspace"), 1)]
        for status in ["ERROR", "CANCELED", "WAITING", "RUNNING", None]:
            events = stream("/tmp/workspace", status=status)
            events[-1]["result"]["error"] = "認証失敗 / 利用枠不足"
            cases.append((events, 0))
        for response in ["", "  \n", 1, None, "\ud800"]:
            cases.append((stream("/tmp/workspace", response=response), 0))
        for change in [{"model": "other"}, {"agent": "other"}, {"permission_mode": "auto"},
                       {"cwd": "/other"}, {"tools": None}, {"tools": [1]}]:
            cases.append((stream("/tmp/workspace", **change), 0))
        events = stream("/tmp/workspace")
        cases += [(events[:-1], 0), (events[1:], 0), (events + [events[-1]], 0),
                  (events + [events[1]], 0), ([events[0]] + events, 0)]
        denied = stream("/tmp/workspace")
        denied[-1]["result"]["denied_actions"] = [{"action": "read_file"}]
        cases.append((denied, 0))
        for step in [{"step_type": "tool", "tool_name": "view_file"},
                     {"step_type": "agent_response", "tool_info": {}},
                     {"step_type": "agent_response", "subagent_info": {}},
                     {"step_type": "unknown"}]:
            altered = stream("/tmp/workspace")
            altered[1]["step_update"] = step
            cases.append((altered, 0))
        for events, code in cases:
            with self.subTest(events=events, code=code), self.assertRaises(ValueError):
                self.validate(events, code)
        for raw in [b"not json", b'\xff', b'{"event":"result","result":null}',
                    b'{"event":"result","result":{"status":"SUCCESS","response":NaN}}']:
            with self.subTest(raw=raw), self.assertRaises(ValueError):
                rewrite.validate_output(raw, 0, "/tmp/workspace")

    def fake_agy(self, directory, body):
        executable = Path(directory) / "agy"
        executable.write_text(f"#!{os.sys.executable}\n" + body)
        executable.chmod(0o700)
        return str(executable)

    def test_large_input_concurrent_isolation_and_arguments(self):
        body = '''import json, os, pathlib, sys, time
args = sys.argv[1:]
assert '-p' not in args and '--add-dir' not in args and '--continue' not in args
assert args[args.index('--model') + 1] == 'gemini-4-argon-high'
settings = json.loads(args[args.index('--settings') + 1])
assert settings['toolPermission'] == 'strict' and settings['agentMode'] == ''
assert args[args.index('--input-format') + 1] == 'stream-json'
assert args[args.index('--output-format') + 1] == 'stream-json'
assert '--disable-slash-commands' in args
messages = sys.stdin.read().splitlines()
assert len(messages) == 1
message = json.loads(messages[0])
assert message['event'] == 'user'
payload = json.loads(message['message']['content'])
assert payload['text'] not in args
agent = pathlib.Path('.agents/agents/argon-rewrite.md').read_text()
assert 'tools: []' in agent and 'model:' not in agent
pathlib.Path('private-state').write_text(payload['context'])
time.sleep(0.1)
assert pathlib.Path('private-state').read_text() == payload['context']
print(json.dumps({'event':'init','init':{'model':'gemini-4-argon-high',
 'agent':'argon-rewrite','cwd':os.getcwd(),'permission_mode':'strict','tools':[]}}))
print(json.dumps({'event':'result','result':{'status':'SUCCESS','response':
 json.dumps({'text':payload['text'],'cwd':os.getcwd(),'context':payload['context']})}}))
'''
        with tempfile.TemporaryDirectory() as directory:
            executable = self.fake_agy(directory, body)
            payloads = [{"text": "/確認\n" + "日本語を保持します。" * 2200, "context": tag}
                        for tag in ["回答下書き", "貼付文章"]]
            with patch.object(rewrite.shutil, "which", return_value=executable):
                with ThreadPoolExecutor(max_workers=2) as executor:
                    results = list(executor.map(rewrite.rewrite, payloads))
            outputs = [json.loads(result) for result in results]
            self.assertNotEqual(outputs[0]["cwd"], outputs[1]["cwd"])
            for source, output in zip(payloads, outputs):
                self.assertEqual(output["text"], source["text"])
                self.assertEqual(output["context"], source["context"])
                self.assertFalse(Path(output["cwd"]).exists())

    def test_timeout_kills_child_and_cleans_workspace(self):
        with tempfile.TemporaryDirectory() as directory:
            marker = Path(directory) / "child-ran"
            cwd_record = Path(directory) / "cwd"
            child_code = f"import time,pathlib; time.sleep(2); pathlib.Path({str(marker)!r}).touch()"
            body = ("import pathlib, subprocess, sys, time, os\n"
                    f"pathlib.Path({str(cwd_record)!r}).write_text(os.getcwd())\n"
                    "sys.stdin.read()\n"
                    f"subprocess.Popen([sys.executable, '-c', {child_code!r}])\n"
                    "time.sleep(30)\n")
            executable = self.fake_agy(directory, body)
            with patch.object(rewrite.shutil, "which", return_value=executable), \
                    patch.object(rewrite, "TIMEOUT_SECONDS", 1):
                with self.assertRaisesRegex(ValueError, "タイムアウト"):
                    rewrite.rewrite({"text": "本文", "context": ""})
            time.sleep(1.3)
            self.assertFalse(marker.exists(), "タイムアウト後に子プロセスが動作した")
            self.assertFalse(Path(cwd_record.read_text()).exists())

    def test_cli_invalid_input_has_empty_stdout(self):
        result = subprocess.run([os.sys.executable, str(Path(rewrite.__file__))],
                                input=b'{"text":""}', capture_output=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, b"")
        self.assertIn("text", result.stderr.decode())

    def test_cli_process_errors_have_empty_stdout(self):
        with tempfile.TemporaryDirectory() as directory:
            for status, code, reason in [("SUCCESS", 7, "abnormal exit"),
                                         ("ERROR", 0, "quota exhausted"),
                                         ("ERROR", 1, "authentication required")]:
                with self.subTest(status=status, code=code):
                    result = {"event": "result", "result": {
                        "status": status, "response": "失敗時の本文", "error": reason}}
                    body = ("import sys\nsys.stdin.read()\n"
                            f"print({json.dumps(result)!r})\nsys.exit({code})\n")
                    self.fake_agy(directory, body)
                    env = {**os.environ, "PATH": directory + os.pathsep + os.environ["PATH"]}
                    proc = subprocess.run([os.sys.executable, str(Path(rewrite.__file__))],
                                          input='{"text":"本文"}'.encode(), env=env, capture_output=True)
                    self.assertNotEqual(proc.returncode, 0)
                    self.assertEqual(proc.stdout, b"")
                    self.assertIn(reason, proc.stderr.decode())


if __name__ == "__main__":
    unittest.main()
