typeset -gA DOT_PROMPT_GIT_INFO
typeset -g DOT_PROMPT_GIT_BRANCH=""
typeset -g DOT_PROMPT_GIT_DETACHED=""
typeset -g DOT_PROMPT_GIT_UPSTREAM=""
typeset -g DOT_PROMPT_GIT_ACTION=""
typeset -g DOT_PROMPT_GIT_CONFLICT=""
typeset -g DOT_PROMPT_GIT_AHEAD=0
typeset -g DOT_PROMPT_GIT_BEHIND=0
typeset -g DOT_PROMPT_GIT_UNMERGED=0
typeset -g DOT_PROMPT_GIT_STAGED=0
typeset -g DOT_PROMPT_GIT_UNSTAGED=0
typeset -g DOT_PROMPT_GIT_UNTRACKED=0
typeset -g DOT_PROMPT_GIT_STASH=0
typeset -g DOT_PROMPT_GIT_TOP=""

: ${DOT_PROMPT_GIT_DAEMON_CONNECT_RETRIES:=10}
: ${DOT_PROMPT_GIT_DAEMON_CONNECT_WAIT:=5}
: ${DOT_PROMPT_GIT_EVENT_SETTLE_WAIT:=35}

typeset -g DOT_PROMPT_GIT_DAEMON_STARTED=0

dot_prompt_json_quote() {
  local value=$1
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  REPLY="\"${value}\""
}

dot_prompt_git_cache_path_for_top() {
  setopt localoptions noshwordsplit

  local top=$1
  local cache_root=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/prompt/git-status
  local cache_key=${top//\//%}

  REPLY="${cache_root}/${cache_key}.status"
}

# Uses flock so the kernel releases the lock even when the holder is killed
# (a mkdir-based lock dir is left behind when e.g. async_flush_jobs sends SIGHUP).
# On success REPLY holds the fd. Without zsh/system, proceed unlocked (REPLY empty).
dot_prompt_git_lock_acquire() {
  setopt localoptions noshwordsplit

  local lock_path=$1 timeout=${2:-0}
  local fd

  REPLY=""
  zmodload zsh/system 2>/dev/null || return 0
  : >>| "$lock_path" 2>/dev/null || return 0
  zsystem flock -t "$timeout" -f fd "$lock_path" 2>/dev/null || return 1
  REPLY=$fd
}

dot_prompt_git_lock_release() {
  local fd=$1
  [[ -n $fd ]] || return 0
  exec {fd}>&-
}

dot_prompt_git_daemon_paths() {
  setopt localoptions noshwordsplit

  local tmp_root=${TMPDIR:-/tmp}
  tmp_root=${tmp_root%/}
  local runtime_base=${DOT_PROMPT_GITD_RUNTIME_BASE:-${tmp_root}/dot-prompt-gitd-${EUID}}
  typeset -g DOT_PROMPT_GITD_RUNTIME_DIR=$runtime_base
  typeset -g DOT_PROMPT_GITD_SOCKET_PATH=${DOT_PROMPT_GITD_SOCKET_PATH:-${runtime_base}/daemon.sock}
  typeset -g DOT_PROMPT_GITD_SCRIPT=${DOT_PROMPT_GITD_SCRIPT:-$HOME/dotfiles/bin/dot-prompt-gitd.ts}
}

dot_prompt_git_daemon_available() {
  command -v deno >/dev/null 2>&1 || return 1
  command -v watchman >/dev/null 2>&1 || return 1
  dot_prompt_git_daemon_paths
  [[ -r $DOT_PROMPT_GITD_SCRIPT ]]
}

dot_prompt_git_daemon_connect() {
  zmodload zsh/net/socket 2>/dev/null || return 1
  zsocket "$DOT_PROMPT_GITD_SOCKET_PATH" 2>/dev/null
}

dot_prompt_git_daemon_start() {
  (( DOT_PROMPT_GIT_DAEMON_STARTED )) && return 0
  typeset -g DOT_PROMPT_GIT_DAEMON_STARTED=1

  command deno run --quiet -A "$DOT_PROMPT_GITD_SCRIPT" >/dev/null 2>&1 &!
}

dot_prompt_git_daemon_register() {
  setopt localoptions noshwordsplit

  local top=$1
  local cache_path=$2
  local top_json cache_json request fd attempt
  local connected=0

  dot_prompt_git_daemon_available || return 1

  if dot_prompt_git_daemon_connect; then
    connected=1
  else
    # A daemon that was started by this shell may have exited since the last
    # registration. The singleton lock keeps a restart attempt safe.
    typeset -g DOT_PROMPT_GIT_DAEMON_STARTED=0
    dot_prompt_git_daemon_start
    zmodload zsh/zselect 2>/dev/null || return 1
    for (( attempt = 0; attempt < DOT_PROMPT_GIT_DAEMON_CONNECT_RETRIES; attempt++ )); do
      zselect -t "$DOT_PROMPT_GIT_DAEMON_CONNECT_WAIT" 2>/dev/null || true
      if dot_prompt_git_daemon_connect; then
        connected=1
        break
      fi
    done
  fi

  (( connected )) || return 1
  fd=$REPLY
  [[ -n $fd ]] || return 1

  dot_prompt_json_quote "$top"; top_json=$REPLY
  dot_prompt_json_quote "$cache_path"; cache_json=$REPLY
  request="{\"top\":${top_json},\"cachePath\":${cache_json}}"
  print -r -u "$fd" -- "$request" 2>/dev/null
  local code=$?
  exec {fd}>&-
  return $code
}

dot_prompt_git_status_from_cache() {
  setopt localoptions noshwordsplit

  local cache_path=$1
  local line signature=""
  local -a items
  local -A info stat

  [[ -r $cache_path ]] || return 1
  # Stat before reading so a newer atomic rename never gets tied to older content.
  # Inode distinguishes multiple cache replacements within the same second.
  if zmodload zsh/stat 2>/dev/null && zstat -H stat -- "$cache_path" 2>/dev/null; then
    signature="${stat[mtime]}:${stat[inode]}:${stat[size]}"
  fi
  IFS= read -r line < "$cache_path" || return 1
  [[ -n $line ]] || return 1

  items=("${(Q@)${(z)line}}")
  (( ${#items} > 0 && ${#items} % 2 == 0 )) || return 1

  info=("${items[@]}")
  info[pwd]=$PWD
  info[signature]=$signature
  print -r -- ${(@kvq)info}
}

dot_prompt_git_empty_status() {
  local -A info
  info=(pwd "$PWD" top "")
  print -r -- ${(@kvq)info}
}

dot_prompt_git_status_uncached() {
  setopt localoptions noshwordsplit

  local -A info
  local git_dir oid="" branch="" upstream="" line
  local ahead=0 behind=0 staged=0 unstaged=0 untracked=0 unmerged=0 stash=0
  local action="" conflict=""

  info[pwd]=$PWD
  info[top]=$(command git rev-parse --show-toplevel 2>/dev/null) || return 1
  git_dir=$(command git rev-parse --git-dir 2>/dev/null) || return 1
  dot_prompt_git_cache_path_for_top "$info[top]"
  info[cache]=$REPLY

  while IFS= read -r line; do
    case $line in
      "# branch.oid "*)
        oid=${line#\# branch.oid }
        ;;
      "# branch.head "*)
        branch=${line#\# branch.head }
        ;;
      "# branch.upstream "*)
        upstream=${line#\# branch.upstream }
        ;;
      "# branch.ab "*)
        local branch_ab=${line#\# branch.ab }
        local ahead_raw=${branch_ab%% *}
        local behind_raw=${branch_ab#* }
        ahead=${ahead_raw#+}
        behind=${behind_raw#-}
        ;;
      "# stash "*)
        stash=${line#\# stash }
        ;;
      \?*)
        (( untracked++ ))
        ;;
      u\ *)
        (( unmerged++ ))
        ;;
      1\ *|2\ *)
        local xy=${${(z)line}[2]}
        [[ ${xy[1,1]} != "." ]] && (( staged++ ))
        [[ ${xy[2,2]} != "." ]] && (( unstaged++ ))
        ;;
    esac
  done < <(GIT_OPTIONAL_LOCKS=0 command git status --show-stash --branch --porcelain=v2 2>/dev/null)

  if [[ -d $git_dir/rebase-merge ]] || [[ -d $git_dir/rebase-apply ]]; then
    action="Rebasing"
  fi

  if [[ -f $git_dir/MERGE_HEAD ]]; then
    conflict=1
  fi

  if [[ $branch == "(detached)" ]]; then
    info[detached]=1
    info[branch]=${oid[1,7]}
  else
    info[detached]=
    info[branch]=$branch
  fi
  info[upstream]=$upstream
  info[action]=$action
  info[conflict]=$conflict
  info[ahead]=$ahead
  info[behind]=$behind
  info[staged]=$staged
  info[unstaged]=$unstaged
  info[untracked]=$untracked
  info[unmerged]=$unmerged
  info[stash]=$stash

  print -r -- ${(@kvq)info}
}

dot_prompt_git_update_cache() {
  setopt localoptions noshwordsplit

  local top=${1:-}
  local cache_path lock_path tmp_path output code=0
  local canonical_top lock_fd=""

  if [[ -n $top ]]; then
    builtin cd -q "$top" 2>/dev/null || return 1
  fi

  canonical_top=$(command git rev-parse --show-toplevel 2>/dev/null) || return 1
  dot_prompt_git_cache_path_for_top "$canonical_top"
  cache_path=$REPLY
  lock_path="${cache_path}.flock"

  command mkdir -p "${cache_path:h}" 2>/dev/null || return 1

  if ! dot_prompt_git_lock_acquire "$lock_path" 0; then
    # Another updater is running. Returning empty output would make the
    # caller discard the repo state and blank the prompt, so serve the
    # current cache content instead.
    dot_prompt_git_status_from_cache "$cache_path"
    return $?
  fi
  lock_fd=$REPLY

  output=$(dot_prompt_git_status_uncached) || code=$?
  if (( code != 0 )); then
    dot_prompt_git_lock_release "$lock_fd"
    return $code
  fi

  local -A info
  local -a items
  items=("${(Q@)${(z)output}}")
  info=("${items[@]}")
  cache_path=$info[cache]
  if [[ -z $cache_path ]]; then
    dot_prompt_git_lock_release "$lock_fd"
    return 1
  fi

  # The lock guarantees a single writer, so a fixed tmp name is safe and any
  # leftover from a killed writer gets overwritten next time.
  tmp_path="${cache_path}.tmp"
  if ! { print -r -- "$output" >| "$tmp_path" && command mv -f "$tmp_path" "$cache_path" }; then
    dot_prompt_git_lock_release "$lock_fd"
    return 1
  fi
  # Re-read through the cache so the reported signature matches the content.
  dot_prompt_git_status_from_cache "$cache_path"
  code=$?
  dot_prompt_git_lock_release "$lock_fd"
  return $code
}

dot_prompt_git_status() {
  setopt localoptions noshwordsplit

  local mode=${1:-cached}
  local cache_path top
  local daemon_registered=0

  if [[ $mode == cache-only ]]; then
    cache_path=$2
    [[ -n $cache_path ]] || return 1
    dot_prompt_git_status_from_cache "$cache_path"
    return $?
  fi

  if ! dot_prompt_git_daemon_available; then
    # Event-driven updates require the daemon. Keep the prompt quiet on
    # machines without Deno or Watchman instead of falling back to polling.
    dot_prompt_git_empty_status
    return 0
  fi

  if [[ $mode == known || $mode == known-after-event ]]; then
    top=$2
    cache_path=$3
    if [[ -z $top || -z $cache_path ]]; then
      dot_prompt_git_empty_status
      return 0
    fi

    if ! dot_prompt_git_daemon_register "$top" "$cache_path"; then
      dot_prompt_git_empty_status
      return 0
    fi
    if [[ $mode == known-after-event ]] && zmodload zsh/zselect 2>/dev/null; then
      # Give Watchman and the daemon time to settle after the preceding shell
      # command. This is a zsh builtin wait in the async worker, not a process.
      zselect -t "$DOT_PROMPT_GIT_EVENT_SETTLE_WAIT" 2>/dev/null || true
    fi
    dot_prompt_git_status_from_cache "$cache_path" || dot_prompt_git_empty_status
    return 0
  fi

  if ! top=$(command git rev-parse --show-toplevel 2>/dev/null); then
    # Outside a repo, return a sentinel with an empty top. Empty output and
    # non-zero codes are treated as transient failures, so be explicit here.
    dot_prompt_git_empty_status
    return 0
  fi
  dot_prompt_git_cache_path_for_top "$top"
  cache_path=$REPLY
  if dot_prompt_git_daemon_register "$top" "$cache_path"; then
    daemon_registered=1
  fi

  if (( ! daemon_registered )); then
    dot_prompt_git_empty_status
    return 0
  fi

  if (( daemon_registered )) && [[ -s $cache_path ]]; then
    dot_prompt_git_status_from_cache "$cache_path" && return 0
  fi

  dot_prompt_git_update_cache "$top"
}

dot_prompt_build_git_prompt() {
  local prompt=""
  local has_local_changes=0

  if [[ -n $DOT_PROMPT_GIT_BRANCH ]]; then
    if [[ -n $DOT_PROMPT_GIT_DETACHED ]]; then
      dot_prompt_escape "$DOT_PROMPT_GIT_BRANCH"
      prompt+="%B%F{6}:%f%F{7}${REPLY}%f%b"
    else
      dot_prompt_escape "$DOT_PROMPT_GIT_BRANCH"
      prompt+="%B%F{7} ${REPLY}%f%b"
    fi
  fi

  if [[ -n $DOT_PROMPT_GIT_UPSTREAM ]]; then
    dot_prompt_escape "$DOT_PROMPT_GIT_UPSTREAM"
    prompt+="%F{5}->%f%F{6}${REPLY}%f "
  fi

  (( DOT_PROMPT_GIT_BEHIND > 0 )) && prompt+="%B%F{6}↓ ${DOT_PROMPT_GIT_BEHIND}%f%b"
  (( DOT_PROMPT_GIT_AHEAD > 0 )) && prompt+="%B%F{6}↑ ${DOT_PROMPT_GIT_AHEAD}%f%b"

  if [[ -n $DOT_PROMPT_GIT_TOP ]]; then
    prompt+="|"
  fi

  (( DOT_PROMPT_GIT_UNMERGED > 0 )) && prompt+=" %F{1}X:${DOT_PROMPT_GIT_UNMERGED}%f"
  (( DOT_PROMPT_GIT_STAGED > 0 )) && prompt+=" %F{2}M:${DOT_PROMPT_GIT_STAGED}%f"
  (( DOT_PROMPT_GIT_UNSTAGED > 0 )) && prompt+=" %F{1}M:${DOT_PROMPT_GIT_UNSTAGED}%f"
  (( DOT_PROMPT_GIT_UNTRACKED > 0 )) && prompt+=" %F{1}?:${DOT_PROMPT_GIT_UNTRACKED}%f"
  (( DOT_PROMPT_GIT_STASH > 0 )) && prompt+=" %F{4}Stash:${DOT_PROMPT_GIT_STASH}%f"

  if (( DOT_PROMPT_GIT_UNMERGED > 0 || DOT_PROMPT_GIT_STAGED > 0 || DOT_PROMPT_GIT_UNSTAGED > 0 || DOT_PROMPT_GIT_UNTRACKED > 0 )); then
    has_local_changes=1
  fi

  if [[ -n $DOT_PROMPT_GIT_TOP ]] && (( ! has_local_changes )); then
    prompt+=" %B%F{2}✔%f%b "
  fi

  if [[ -n $prompt ]]; then
    prompt+=" "
  fi

  typeset -g DOT_PROMPT_GIT_PROMPT="$prompt"
}
