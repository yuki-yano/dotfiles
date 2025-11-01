#!/usr/bin/env bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title IME Neovim (WezTerm, isolated tmux server – robust)
# @raycast.mode silent
# Optional parameters:
# @raycast.icon 🟩
# @raycast.packageName Neovim
# @raycast.needsConfirmation false
# Documentation:
# @raycast.description Spawn WezTerm window and attach to a persistent Neovim session on an isolated tmux server. Auto-close on success; keep window shortly on failure. Toggle to close if already frontmost.

set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$HOME/dotfiles/bin:$HOME/.local/bin:$PATH"

# ===== Tunables ===============================================================
TITLE="${WEZTERM_NVIM_TITLE:-IME NVIM}"
TMUX_SERVER_NAME="${TMUX_SERVER_NAME:-ime}"        # Alternate tmux server name (tmux -L <name>)
SESSION="${NVIM_TMUX_SESSION:-ime_nvim}"           # Session name
ATTACH_FAIL_SLEEP="${ATTACH_FAIL_SLEEP:-2}"        # Seconds to keep window on attach failure
TMUX_CONF="${TMUX_CONF:-$HOME/.tmux.conf}"         # Optional custom tmux config
WEZTERM_BIN="${WEZTERM_BIN:-wezterm}"
YABAI_BIN="${YABAI_BIN:-yabai}"
# ==============================================================================

_tmux() {
  env -u TMUX tmux -L "$TMUX_SERVER_NAME" -f "$TMUX_CONF" "$@"
}

_focus_wezterm_window() {
  if /usr/bin/osascript -e 'tell application "WezTerm" to activate' >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

for b in "$WEZTERM_BIN" tmux nvim; do
  command -v "$b" >/dev/null 2>&1 || { echo "$b not found" >&2; exit 1; }
done

PREV_APP=""
PREV_WINDOW_ID=""

if command -v "$YABAI_BIN" >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  if window_info=$("$YABAI_BIN" -m query --windows --window 2>/dev/null); then
    PREV_WINDOW_ID="$(printf '%s' "$window_info" | jq -r '.id // empty')"
    PREV_APP="$(printf '%s' "$window_info" | jq -r '.app // empty')"
  fi
fi

export QUICK_IME=1
export QUICK_IME_TITLE="$TITLE"
export QUICK_IME_ATTACH_FAIL_SLEEP="$ATTACH_FAIL_SLEEP"
export QUICK_IME_TMUX_SERVER_NAME="$TMUX_SERVER_NAME"
export QUICK_IME_SESSION="$SESSION"
export QUICK_IME_RETURN_APP="$PREV_APP"
export QUICK_IME_RETURN_WINDOW_ID="$PREV_WINDOW_ID"

# Drop any existing clients for this dedicated session
_tmux detach-client -a -s "$SESSION" 2>/dev/null || true

# Ensure persistent session on the secondary server
_tmux start-server >/dev/null 2>&1 || true
_tmux set-option -g exit-unattached off >/dev/null 2>&1 || true
_tmux set-environment -g QUICK_IME 1 >/dev/null 2>&1 || true
if [[ -n "$QUICK_IME_RETURN_APP" ]]; then
  _tmux set-environment -g QUICK_IME_RETURN_APP "$QUICK_IME_RETURN_APP" >/dev/null 2>&1 || true
fi
if [[ -n "$QUICK_IME_RETURN_WINDOW_ID" ]]; then
  _tmux set-environment -g QUICK_IME_RETURN_WINDOW_ID "$QUICK_IME_RETURN_WINDOW_ID" >/dev/null 2>&1 || true
fi

if ! _tmux has-session -t "$SESSION" 2>/dev/null; then
  _tmux new-session -d -s "$SESSION" "/bin/sh -lc 'QUICK_IME=1 exec nvim'"
fi

# Spawn dedicated WezTerm window
WEZTERM_COMMON_ARGS=()
[[ -n "${WEZTERM_WORKSPACE:-}" ]] && WEZTERM_COMMON_ARGS+=(--workspace "$WEZTERM_WORKSPACE")
[[ -n "${WEZTERM_CWD:-}" ]] && WEZTERM_COMMON_ARGS+=(--cwd "$WEZTERM_CWD")

WEZTERM_SPAWN_ARGS=(cli spawn --new-window)
WEZTERM_SPAWN_ARGS+=("${WEZTERM_COMMON_ARGS[@]}")
WEZTERM_SPAWN_ARGS+=(--)

WEZTERM_START_ARGS=(start --always-new-process)
WEZTERM_START_ARGS+=("${WEZTERM_COMMON_ARGS[@]}")
[[ -n "${WEZTERM_CLASS:-}" ]] && WEZTERM_START_ARGS+=(--class "$WEZTERM_CLASS")
[[ -n "${WEZTERM_POSITION:-}" ]] && WEZTERM_START_ARGS+=(--position "$WEZTERM_POSITION")
WEZTERM_START_ARGS+=(--)

ATTACH_SH=$(cat <<'EOS'
printf '\033]2;%s\007' "${QUICK_IME_TITLE}"
env -u TMUX tmux -L "${QUICK_IME_TMUX_SERVER_NAME}" attach -t "${QUICK_IME_SESSION}"
rc=$?
if [ $rc -ne 0 ]; then
  echo "[ime-nvim] tmux attach failed. Keeping window ${QUICK_IME_ATTACH_FAIL_SLEEP}s..."
  sleep "${QUICK_IME_ATTACH_FAIL_SLEEP}"
fi
exit $rc
EOS
)

pane_id_output=$("$WEZTERM_BIN" "${WEZTERM_SPAWN_ARGS[@]}" /bin/sh -lc "$ATTACH_SH" 2>&1)
spawn_status=$?
if [[ $spawn_status -eq 0 ]]; then
  pane_id="$(printf '%s' "$pane_id_output" | tail -n 1 | tr -d '\r\n')"
  if [[ -n "$pane_id" && -n "$TITLE" ]]; then
    "$WEZTERM_BIN" cli set-window-title --pane-id "$pane_id" "$TITLE" >/dev/null 2>&1 || true
  fi
  _focus_wezterm_window "$pane_id" || true
else
  [[ -n "$pane_id_output" ]] && printf '%s\n' "$pane_id_output" >&2
  if "$WEZTERM_BIN" "${WEZTERM_START_ARGS[@]}" /bin/sh -lc "$ATTACH_SH"; then
    _focus_wezterm_window "" || true
  fi
fi
