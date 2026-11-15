typeset -g DOT_PROMPT_GIT_LINE=""
typeset -g DOT_PROMPT_GIT_TOP=""
typeset -g DOT_PROMPT_GITD_FD=""
typeset -g DOT_PROMPT_GITD_BUFFER=""
typeset -g DOT_PROMPT_GITD_ANSWERED=0
typeset -g DOT_PROMPT_GITD_RETRY_DELAY=0
typeset -g DOT_PROMPT_GITD_SPAWNED_AT=0

: ${DOT_PROMPT_GITD_ANSWER_TIMEOUT:=2}
: ${DOT_PROMPT_GITD_RETRY_MAX:=32}

dot_prompt_json_quote() {
  local value=$1
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  REPLY="\"${value}\""
}

dot_prompt_git_daemon_paths() {
  setopt localoptions noshwordsplit

  local tmp_root=${TMPDIR:-/tmp}
  tmp_root=${tmp_root%/}
  local runtime_base=${DOT_PROMPT_GITD_RUNTIME_BASE:-${tmp_root}/dot-prompt-gitd-${EUID}}
  typeset -g DOT_PROMPT_GITD_SOCKET_PATH=${DOT_PROMPT_GITD_SOCKET_PATH:-${runtime_base}/daemon.sock}
  typeset -g DOT_PROMPT_GITD_SCRIPT=${DOT_PROMPT_GITD_SCRIPT:-$HOME/dotfiles/bin/dot-prompt-gitd.ts}
}

dot_prompt_git_daemon_available() {
  command -v deno >/dev/null 2>&1 || return 1
  command -v watchman >/dev/null 2>&1 || return 1
  dot_prompt_git_daemon_paths
  [[ -r $DOT_PROMPT_GITD_SCRIPT ]]
}

dot_prompt_git_daemon_start() {
  # Started from the interactive shell: do not let the daemon hold its terminal.
  command deno run --quiet -A "$DOT_PROMPT_GITD_SCRIPT" </dev/null >/dev/null 2>&1 &!
}

dot_prompt_git_find_top() {
  local dir=${PWD:A}

  while [[ ${dir:t} != .git ]]; do
    if [[ -e $dir/.git ]]; then
      REPLY=$dir
      return 0
    fi
    [[ $dir == / ]] && break
    dir=${dir:h}
  done
  REPLY=""
  return 1
}

dot_prompt_git_precmd() {
  dot_prompt_git_find_top
  if [[ $REPLY != "$DOT_PROMPT_GIT_TOP" ]]; then
    dot_prompt_git_close
    typeset -g DOT_PROMPT_GIT_TOP=$REPLY
    typeset -g DOT_PROMPT_GIT_LINE=""
  fi
  [[ -n $DOT_PROMPT_GIT_TOP && -z $DOT_PROMPT_GITD_FD ]] || return 0

  if dot_prompt_git_open; then
    dot_prompt_git_schedule_retry "$DOT_PROMPT_GITD_ANSWER_TIMEOUT"
    return 0
  fi
  typeset -g DOT_PROMPT_GIT_LINE=""
  if dot_prompt_git_daemon_available; then
    dot_prompt_git_spawn_daemon
    dot_prompt_git_schedule_retry 1
  fi
  return 0
}

dot_prompt_git_open() {
  setopt localoptions noshwordsplit
  local raw fd=""

  zmodload zsh/net/socket zsh/system 2>/dev/null || return 1
  dot_prompt_git_daemon_paths
  zsocket "$DOT_PROMPT_GITD_SOCKET_PATH" 2>/dev/null || return 1
  raw=$REPLY
  # zsocket cannot set close-on-exec. Without it, a long-lived process started
  # by a zle widget would hold the connection open after this shell closes it.
  sysopen -r -w -o cloexec -u fd "/dev/fd/$raw" 2>/dev/null || fd=""
  exec {raw}>&-
  [[ -n $fd ]] || return 1

  dot_prompt_json_quote "$DOT_PROMPT_GIT_TOP"
  if ! dot_prompt_git_write "$fd" "{\"top\":${REPLY}}"; then
    exec {fd}>&-
    return 1
  fi
  typeset -g DOT_PROMPT_GITD_FD=$fd
  typeset -g DOT_PROMPT_GITD_BUFFER=""
  typeset -g DOT_PROMPT_GITD_ANSWERED=0
  [[ -o zle ]] && zle -F "$fd" dot_prompt_git_on_readable
  return 0
}

dot_prompt_git_write() {
  setopt localoptions localtraps
  trap '' PIPE
  print -r -u "$1" -- "$2" 2>/dev/null
}

dot_prompt_git_close() {
  dot_prompt_git_cancel_retry
  [[ -n $DOT_PROMPT_GITD_FD ]] || return 0
  [[ -o zle ]] && zle -F "$DOT_PROMPT_GITD_FD" 2>/dev/null
  exec {DOT_PROMPT_GITD_FD}>&-
  typeset -g DOT_PROMPT_GITD_FD=""
  typeset -g DOT_PROMPT_GITD_BUFFER=""
  typeset -g DOT_PROMPT_GITD_ANSWERED=0
}

# zle -F handler: $1 is the descriptor, $2 is set when it is in an error state.
dot_prompt_git_on_readable() {
  dot_prompt_git_receive "$1" "$2" && dot_prompt_git_render
}

dot_prompt_git_receive() {
  setopt localoptions noshwordsplit
  local chunk newest="" closed=0 refused=0 delay
  local -a items

  # Read even in an error state: a refusal arrives together with the close.
  while true; do
    # read would block on a partial line. sysread returns 0 with data, 4 when
    # nothing more is ready, 5 at end of file.
    sysread -i "$1" -t 0 chunk
    case $? in
      0) DOT_PROMPT_GITD_BUFFER+=$chunk ;;
      4) break ;;
      *) closed=1; break ;;
    esac
  done
  [[ -n $2 ]] && closed=1

  if [[ $DOT_PROMPT_GITD_BUFFER == *$'\n'* ]]; then
    newest=${${DOT_PROMPT_GITD_BUFFER%$'\n'*}##*$'\n'}
    DOT_PROMPT_GITD_BUFFER=${DOT_PROMPT_GITD_BUFFER##*$'\n'}
    if [[ $newest == refused ]]; then
      refused=1
    else
      items=("${(Q@)${(z)newest}}")
      (( ${#items} > 0 && ${#items} % 2 == 0 )) || closed=1
    fi
  fi

  if (( refused )); then
    # The daemon does not serve this top: asking again would be refused again.
    dot_prompt_git_close
    newest=""
  elif (( closed )); then
    # A connection that never answered keeps its backoff instead of restarting at 1s.
    (( delay = DOT_PROMPT_GITD_RETRY_DELAY > 0 ? DOT_PROMPT_GITD_RETRY_DELAY : 1 ))
    dot_prompt_git_close
    dot_prompt_git_schedule_retry $delay
    newest=""
  elif [[ -z $newest ]]; then
    return 1
  else
    typeset -g DOT_PROMPT_GITD_ANSWERED=1
    dot_prompt_git_cancel_retry
  fi
  [[ $newest != "$DOT_PROMPT_GIT_LINE" ]] || return 1
  typeset -g DOT_PROMPT_GIT_LINE=$newest
}

dot_prompt_git_render() {
  dot_prompt_build_right_base
  dot_prompt_build_git_prompt
  dot_prompt_build_left "$DOT_PROMPT_LAST_EXIT"
  dot_prompt_apply_render
  dot_prompt_reset_prompt_full
}

dot_prompt_git_schedule_retry() {
  zmodload zsh/sched 2>/dev/null || return 0
  dot_prompt_git_cancel_retry
  typeset -g DOT_PROMPT_GITD_RETRY_DELAY=$1
  sched +$1 dot_prompt_git_retry
}

dot_prompt_git_cancel_retry() {
  local index=${zsh_scheduled_events[(I)*:dot_prompt_git_retry]}

  (( index )) && sched -$index
  typeset -g DOT_PROMPT_GITD_RETRY_DELAY=0
}

# Runs from sched, so only while zle waits for input or right before a prompt.
dot_prompt_git_retry() {
  local delay=$DOT_PROMPT_GITD_RETRY_DELAY

  typeset -g DOT_PROMPT_GITD_RETRY_DELAY=0
  [[ -n $DOT_PROMPT_GIT_TOP ]] && (( ! DOT_PROMPT_GITD_ANSWERED )) || return 0
  dot_prompt_git_close
  if [[ -n $DOT_PROMPT_GIT_LINE ]]; then
    typeset -g DOT_PROMPT_GIT_LINE=""
    dot_prompt_git_render
  fi
  dot_prompt_git_open
  (( delay = delay * 2 > DOT_PROMPT_GITD_RETRY_MAX ? DOT_PROMPT_GITD_RETRY_MAX : delay * 2 ))
  dot_prompt_git_schedule_retry "$delay"
}

# shortcut: one start per shell per 10 seconds; many shells can still start one
# each at the same moment, and the daemon's pid lock lets a single one survive.
# Upgrade to a lock shared by the shells when those simultaneous starts show up
# as visible load or as errors.
dot_prompt_git_spawn_daemon() {
  zmodload zsh/datetime 2>/dev/null || return 0
  (( EPOCHSECONDS - DOT_PROMPT_GITD_SPAWNED_AT >= 10 )) || return 0
  typeset -g DOT_PROMPT_GITD_SPAWNED_AT=$EPOCHSECONDS
  dot_prompt_git_daemon_start
}

dot_prompt_build_git_prompt() {
  setopt localoptions noshwordsplit
  local prompt=""
  local has_local_changes=0
  local -A git

  typeset -g DOT_PROMPT_GIT_PROMPT=""
  typeset -g DOT_PROMPT_GIT_BADGE=""
  [[ -n $DOT_PROMPT_GIT_LINE ]] || return 0
  git=("${(Q@)${(z)DOT_PROMPT_GIT_LINE}}")

  if [[ -n $git[action] ]]; then
    dot_prompt_escape "$git[action]"
    typeset -g DOT_PROMPT_GIT_BADGE="%F{1} ${REPLY} %f"
  fi

  if [[ -n $git[branch] ]]; then
    if [[ -n $git[detached] ]]; then
      dot_prompt_escape "$git[branch]"
      prompt+="%B%F{6}:%f%F{7}${REPLY}%f%b"
    else
      dot_prompt_escape "$git[branch]"
      prompt+="%B%F{7} ${REPLY}%f%b"
    fi
  fi

  if [[ -n $git[upstream] ]]; then
    dot_prompt_escape "$git[upstream]"
    prompt+="%F{5}->%f%F{6}${REPLY}%f "
  fi

  (( ${git[behind]:-0} > 0 )) && prompt+="%B%F{6}↓ ${git[behind]}%f%b"
  (( ${git[ahead]:-0} > 0 )) && prompt+="%B%F{6}↑ ${git[ahead]}%f%b"

  prompt+="|"

  (( ${git[unmerged]:-0} > 0 )) && prompt+=" %F{1}X:${git[unmerged]}%f"
  (( ${git[staged]:-0} > 0 )) && prompt+=" %F{2}M:${git[staged]}%f"
  (( ${git[unstaged]:-0} > 0 )) && prompt+=" %F{1}M:${git[unstaged]}%f"
  (( ${git[untracked]:-0} > 0 )) && prompt+=" %F{1}?:${git[untracked]}%f"
  (( ${git[stash]:-0} > 0 )) && prompt+=" %F{4}Stash:${git[stash]}%f"

  if (( ${git[unmerged]:-0} > 0 || ${git[staged]:-0} > 0 || ${git[unstaged]:-0} > 0 || ${git[untracked]:-0} > 0 )); then
    has_local_changes=1
  fi

  if (( ! has_local_changes )); then
    prompt+=" %B%F{2}✔%f%b "
  fi

  if (( ${git[added]:-0} > 0 || ${git[deleted]:-0} > 0 )); then
    prompt+=" %F{244}│%f %F{2}+${git[added]:-0}%f %F{1}-${git[deleted]:-0}%f"
  fi

  typeset -g DOT_PROMPT_GIT_PROMPT="${prompt} "
}
