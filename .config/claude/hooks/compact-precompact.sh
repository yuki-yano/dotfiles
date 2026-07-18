#!/usr/bin/env bash
# PreCompact hook. Deterministic only, no LLM:
#   1. back up the transcript JSONL (keep the newest 10 per session)
#   2. append machine-collectable facts to the session state file so recovery
#      has fresh ground truth even when the agent's last checkpoint is stale
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
TRANSCRIPT_PATH=$(jq -r '.transcript_path // empty' <<<"$INPUT")
TRIGGER=$(jq -r '.trigger // "unknown"' <<<"$INPUT")
CWD=$(jq -r '.cwd // empty' <<<"$INPUT")

[[ "$SESSION_ID" =~ ^[0-9a-zA-Z-]+$ ]] || exit 0

# 1. Transcript backup
BACKUP_PATH=""
if [[ -n "$TRANSCRIPT_PATH" && -f "$TRANSCRIPT_PATH" ]]; then
  BACKUP_DIR="$HOME/.config/claude/backups/transcripts"
  mkdir -p "$BACKUP_DIR" 2>/dev/null || true
  chmod 700 "$BACKUP_DIR" 2>/dev/null || true
  BACKUP_PATH="$BACKUP_DIR/$(date +%s)-$SESSION_ID.jsonl"
  cp "$TRANSCRIPT_PATH" "$BACKUP_PATH" || BACKUP_PATH=""
  [[ -z "$BACKUP_PATH" ]] || chmod 600 "$BACKUP_PATH" 2>/dev/null || true
  find "$BACKUP_DIR" -maxdepth 1 -type f -name "*-$SESSION_ID.jsonl" 2>/dev/null \
    | sort -r | tail -n +11 | while IFS= read -r old; do rm -f "$old"; done
  # Age out backups from dead sessions; per-session retention alone grows forever.
  find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.jsonl" -mtime +14 -delete 2>/dev/null || true
fi

# 2. Machine facts in the state file
STATE_DIR="$HOME/.config/claude/compact-state"
mkdir -p "$STATE_DIR" 2>/dev/null || true
chmod 700 "$STATE_DIR" 2>/dev/null || true
STATE_FILE="$STATE_DIR/$SESSION_ID.md"

FACTS_HEADING="## Machine Facts (PreCompact)"
if [[ -f "$STATE_FILE" ]]; then
  # Drop only the previous machine facts section (up to the next ## heading),
  # preserving anything the agent wrote after it.
  TMP_STATE=$(mktemp "${TMPDIR:-/tmp}/compact-state.XXXXXX")
  awk -v heading="$FACTS_HEADING" '
    $0 == heading {skip = 1; next}
    skip && /^## / {skip = 0}
    !skip {print}
  ' "$STATE_FILE" >"$TMP_STATE"
  mv "$TMP_STATE" "$STATE_FILE"
else
  printf '# Compact Prep State\n\n(No agent checkpoint was written before compaction.)\n' >"$STATE_FILE"
fi

GIT_BRANCH=""
GIT_STATUS=""
if [[ -n "$CWD" && -d "$CWD" ]]; then
  GIT_BRANCH=$(GIT_OPTIONAL_LOCKS=0 git -C "$CWD" symbolic-ref --short HEAD 2>/dev/null \
    || GIT_OPTIONAL_LOCKS=0 git -C "$CWD" rev-parse --short HEAD 2>/dev/null)
  GIT_STATUS=$(GIT_OPTIONAL_LOCKS=0 git -C "$CWD" status --porcelain 2>/dev/null | head -n 15)
fi

{
  printf '%s\n' "$FACTS_HEADING"
  printf -- '- compacted_at: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"
  printf -- '- trigger: %s\n' "$TRIGGER"
  printf -- '- cwd: %s\n' "${CWD:-unknown}"
  printf -- '- git_branch: %s\n' "${GIT_BRANCH:-not a git repo}"
  if [[ -n "$GIT_STATUS" ]]; then
    printf -- '- git_status (first 15 lines):\n'
    printf '%s\n' "$GIT_STATUS" | sed 's/^/    /'
  fi
  printf -- '- transcript_path: %s\n' "${TRANSCRIPT_PATH:-unknown}"
  if [[ -n "$BACKUP_PATH" ]]; then
    printf -- '- transcript_backup: %s\n' "$BACKUP_PATH"
  fi
} >>"$STATE_FILE"
chmod 600 "$STATE_FILE" 2>/dev/null || true

# Clean up state files from long-dead sessions.
find "$STATE_DIR" -maxdepth 1 -type f -name "*.md" -mtime +14 -delete 2>/dev/null || true

exit 0
