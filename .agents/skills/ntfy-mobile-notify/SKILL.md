---
name: ntfy-mobile-notify
description: スマホ通知を ntfy で送信する運用を統一する。ユーザーが「スマホ通知も」「スマホにも通知」など明示的に要求した場合のみ通知し、`NTFY_TOPIC` の存在確認、タイトル規約 `[$REPO_NAME] {Codex|Claude Code} ...`、100-200字の要約ルールを守って `ntfy publish` を実行するときに使う。
---

# Ntfy Mobile Notify

## 概要

`~/.agents/skills/ntfy-mobile-notify/scripts/send_mobile_notification.sh` を使って、スマホ通知を `ntfy` コマンドで送信する。

## 通知ポリシー

1. ユーザーが「スマホ通知も」「スマホにも通知」など、明示的に要求した場合のみ通知する。
2. `NTFY_TOPIC` が設定されていることを確認する。
3. 通知は必ず `ntfy publish -t "<title>" "$NTFY_TOPIC" "<message>"` で送信する。

## タイトル規約

タイトルは必ず `[$REPO_NAME] {Codex|Claude Code} ${実行内容の要約}` 形式にする。

`REPO_NAME` は次のコマンドで取得する。

```bash
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "non-git")
```

## 本文規約

- 本文は 100-200 文字程度で作成する。
- 変更内容、検証結果、補足を簡潔に含める。
- 1 通で要点が伝わるように情報を圧縮する。

## 実行主体の切替

- スクリプトは実行環境を判定して `Codex` / `Claude Code` を自動選択する。
- `--agent codex|claude` で明示指定できる。
- `NTFY_NOTIFY_AGENT=codex|claude` でも上書きできる。

## 実行手順

1. `NTFY_TOPIC` を設定する。
2. `--summary` に 100-200 文字の要約を指定する。
3. 必要なら `--agent codex|claude` で通知主体を指定する（省略時は自動判定）。
4. `--title-suffix` でタイトル末尾を指定する（省略時は `スマホ通知`）。
5. `--dry-run` で内容確認後に本送信する。

## 環境変数

- `NTFY_TOPIC`: 必須。通知先トピック。
- `NTFY_NOTIFY_AGENT`: 任意。`codex` または `claude` を指定して自動判定を上書きする。

## 実行例

```bash
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "non-git")
SKILL_SCRIPT="$HOME/.agents/skills/ntfy-mobile-notify/scripts/send_mobile_notification.sh"
SUMMARY='今回の作業では通知スキルの作成と検証を実施し、タイトル規約と本文長のチェックを追加しました。dry-runでコマンド整形とパラメータ展開を確認し、実行前に送信内容の妥当性を担保しています。'

NTFY_TOPIC="your-topic" \
  "$SKILL_SCRIPT" \
  --agent "codex" \
  --title-suffix "通知スキル作成完了" \
  --summary "$SUMMARY"
```

## 対応オプション

- `--summary`: 必須。通知本文（100-200文字）。
- `--title-suffix`: 任意。タイトル末尾の要約。
- `--agent`: 任意。通知主体を `codex` または `claude` に固定する。
- `--title`: 任意。完全なタイトルを指定（`[$REPO_NAME]` プレフィックス必須）。
- `--repo-name`: 任意。`REPO_NAME` を明示指定。
- `--dry-run`: 任意。送信せずに実行内容を表示。
- `--help`: 使い方を表示。

## 挙動メモ

- `NTFY_TOPIC` 未設定時はエラー終了する。
- `ntfy` コマンドが見つからない場合はエラー終了する（`--dry-run` を除く）。
- `--summary` が 100-200 文字を外れる場合はエラー終了する。
- `--agent` や `NTFY_NOTIFY_AGENT` が `codex|claude` 以外の場合はエラー終了する。
- `--title` 指定時も `[$REPO_NAME]` プレフィックスを必須チェックする。
