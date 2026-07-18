#!/usr/bin/env bash
set -euo pipefail

# Claude Code の Bash tool 環境から現在の session id を出力する。
# compact-state skill が state file 名の決定に使う。
# 検出できない場合は推測せず、非ゼロ終了する。

session_id="${CLAUDE_CODE_SESSION_ID:-}"

if [[ -z "$session_id" ]]; then
  echo "error: session id not found (CLAUDE_CODE_SESSION_ID is not set)" >&2
  exit 1
fi

if [[ ! "$session_id" =~ ^[0-9a-fA-F][0-9a-fA-F-]+$ ]]; then
  echo "error: unexpected session id format: $session_id" >&2
  exit 1
fi

printf '%s\n' "$session_id"
