#!/usr/bin/env bash

set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
HOOK="$ROOT/.config/claude/hooks/compact-guard.sh"
WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/compact-guard-test.XXXXXX")
WRITER_PID=""

cleanup() {
  if [[ -n "$WRITER_PID" ]]; then
    kill "$WRITER_PID" 2>/dev/null || true
    wait "$WRITER_PID" 2>/dev/null || true
  fi
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

TEST_HOME="$WORK_DIR/home"
TEST_TMP="$WORK_DIR/tmp"
SESSION_ID="test-session-123"
mkdir -p "$TEST_HOME" "$TEST_TMP/claude-compact-warn"
printf '75 75\n' >"$TEST_TMP/claude-compact-warn/$SESSION_ID"

# Reproduce Claude leaving the hook input pipe open after writing one complete
# JSON object. The hook must not wait for EOF.
FIFO="$WORK_DIR/hook-input"
mkfifo "$FIFO"
(
  exec 3>"$FIFO"
  printf '%s' \
    "{\"session_id\":\"$SESSION_ID\",\"hook_event_name\":\"UserPromptSubmit\"}" >&3
  sleep 5
) &
WRITER_PID=$!

STARTED_AT=$(date +%s)
HOME="$TEST_HOME" TMPDIR="$TEST_TMP" bash "$HOOK" <"$FIFO" >"$WORK_DIR/output.json"
ELAPSED=$(( $(date +%s) - STARTED_AT ))

if (( ELAPSED >= 3 )); then
  printf 'compact guard waited %ss for EOF\n' "$ELAPSED" >&2
  exit 1
fi

jq -e '
  .hookSpecificOutput.hookEventName == "UserPromptSubmit" and
  (.hookSpecificOutput.additionalContext | contains("Context usage reached 75%"))
' "$WORK_DIR/output.json" >/dev/null

kill "$WRITER_PID" 2>/dev/null || true
wait "$WRITER_PID" 2>/dev/null || true
WRITER_PID=""

# Incomplete input is discarded without turning a hook transport problem into
# a prompt submission failure.
printf '{' >"$WORK_DIR/incomplete-input"
HOME="$TEST_HOME" TMPDIR="$TEST_TMP" bash "$HOOK" \
  <"$WORK_DIR/incomplete-input" >"$WORK_DIR/incomplete-output"
[[ ! -s "$WORK_DIR/incomplete-output" ]]

printf 'compact guard tests passed\n'
