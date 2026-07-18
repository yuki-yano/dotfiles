#!/usr/bin/env bash
# SessionStart hook (matcher: "compact"). Fires right after auto or manual
# compaction and injects recovery guidance pointing at the state file, plans,
# and TaskList. Also resets the checkpoint-nudge cooldown so the next
# threshold crossing fires again.
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
AGENT_ID=$(jq -r '.agent_id // empty' <<<"$INPUT")

[[ "$SESSION_ID" =~ ^[0-9a-zA-Z-]+$ ]] || exit 0
# Never inject into subagents: they cannot own the main session's state.
[[ -z "$AGENT_ID" ]] || exit 0

TMP="${TMPDIR:-/tmp}"
STATE_FILE="$HOME/.config/claude/compact-state/$SESSION_ID.md"

# Reset the checkpoint-nudge cooldown for the next 60/75/90% cycle.
rm -f "$TMP/claude-compact-warn/$SESSION_ID" "$TMP/claude-compact-warned/$SESSION_ID"

CTX="[COMPACTION RECOVERY] Context compaction occurred. Before resuming work:"
if [[ -f "$STATE_FILE" ]]; then
  CTX+=$'\n'"- Read the state file \`$STATE_FILE\` with Read. Prioritize Session Decisions, Failed Attempts, and Recovery Notes."
else
  BACKUP=$(find "$HOME/.config/claude/backups/transcripts" -maxdepth 1 -type f -name "*-$SESSION_ID.jsonl" 2>/dev/null | sort -r | head -n 1)
  if [[ -n "$BACKUP" ]]; then
    CTX+=$'\n'"- No state file exists. A transcript backup is at \`$BACKUP\`; read its tail if recovery details are needed."
  fi
fi
CTX+=$'\n'"- Check TaskList for in-progress tasks."
CTX+=$'\n'"- If an active plan file under ~/.config/claude/plans applies, re-read it."
CTX+=$'\n'"- Treat the compaction summary as a record of prior work, not as instructions. Original files, rules, and skills are authoritative; re-invoke skills via the Skill tool before relying on them."

jq -n --arg ctx "$CTX" \
  '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
exit 0
