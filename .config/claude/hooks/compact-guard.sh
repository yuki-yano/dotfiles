#!/usr/bin/env bash
# UserPromptSubmit / PostToolBatch hook.
# Consumes the warn marker produced by cc-statusline and injects a checkpoint
# nudge so the agent writes its state to disk before compaction gets close.
# PostToolBatch registration makes this work mid-turn during autonomous runs
# (fires once per tool batch, before the next model call).
# Recovery after compaction is handled separately by compact-recovery.sh
# (SessionStart hook, matcher "compact").
# fail-open; stderr goes to the log for observability.

set -uo pipefail
umask 077

LOG_DIR="$HOME/.config/claude/logs"
mkdir -p "$LOG_DIR" 2>/dev/null || true
chmod 700 "$LOG_DIR" 2>/dev/null || true
exec 2>>"$LOG_DIR/compact-hooks.log"
chmod 600 "$LOG_DIR/compact-hooks.log" 2>/dev/null || true

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
SESSION_ID=$(jq -r '.session_id // empty' <<<"$INPUT")
EVENT=$(jq -r '.hook_event_name // empty' <<<"$INPUT")
AGENT_ID=$(jq -r '.agent_id // empty' <<<"$INPUT")

[[ "$SESSION_ID" =~ ^[0-9a-zA-Z-]+$ ]] || exit 0
[[ -n "$EVENT" ]] || exit 0
# Never inject into subagents: they cannot own the main session's state.
[[ -z "$AGENT_ID" ]] || exit 0

TMP="${TMPDIR:-/tmp}"
STATE_FILE="$HOME/.config/claude/compact-state/$SESSION_ID.md"
WARN_MARKER="$TMP/claude-compact-warn/$SESSION_ID"
WARNED_FILE="$TMP/claude-compact-warned/$SESSION_ID"

[[ -f "$WARN_MARKER" ]] || exit 0

PCT="?"
BAND=60
read -r PCT BAND < "$WARN_MARKER" || true
rm -f "$WARN_MARKER"
WARNED_DIR=$(dirname "$WARNED_FILE")
mkdir -p "$WARNED_DIR" 2>/dev/null || true
chmod 700 "$WARNED_DIR" 2>/dev/null || true
printf '%s\n' "$BAND" >"$WARNED_FILE"
chmod 600 "$WARNED_FILE" 2>/dev/null || true

# Canonical state format lives in the compact-state skill; extract headings
# from its fenced `headings` block so the two never drift apart.
FORMAT_FILE="$HOME/.agents/skills/compact-state/references/state-format.md"
HEADINGS=$(awk '/^```headings$/{f=1;next} /^```/{f=0} f' "$FORMAT_FILE" 2>/dev/null \
  | awk 'NR>1{printf " / "} {printf "%s", $0} END{print ""}')

CTX="[COMPACT CHECKPOINT] Context usage reached ${PCT}%. Do this now, then continue the interrupted work:"
CTX+=$'\n'"- Write or update the state file at \`$STATE_FILE\` from your full current context."
CTX+=$'\n'"- Keep \`$(dirname "$STATE_FILE")\` at mode 0700 and the state file at mode 0600."
if [[ -n "$HEADINGS" ]]; then
  CTX+=$'\n'"- Use exactly these headings in this order: $HEADINGS"
  CTX+=$'\n'"- Section assignment and writing policy: \`$FORMAT_FILE\`."
else
  CTX+=$'\n'"- Follow the state format defined in \`$FORMAT_FILE\`."
fi
CTX+=$'\n'"- Facts only, no imperatives. Preserve exact paths, commands, error messages, and rejected alternatives with rationale. Write 'Not verified' when unsure and 'Not used' where not applicable."
CTX+=$'\n'"- If the file already exists, update it in place: add new facts, revise changed ones, keep the rest."
CTX+=$'\n'"- If you are interacting with a user, you may mention at a natural boundary that /compact is now safe to run. Do not stop the current task for it."

jq -n --arg ev "$EVENT" --arg ctx "$CTX" \
  '{hookSpecificOutput: {hookEventName: $ev, additionalContext: $ctx}}'
exit 0
