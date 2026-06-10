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

: ${DOT_PROMPT_GIT_WATCH_TTL:=60}
: ${DOT_PROMPT_GIT_UPDATE_DEBOUNCE:=1}
: ${DOT_PROMPT_GIT_WATCH_LOCK_WAIT:=10}

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

dot_prompt_git_cache_is_fresh() {
  setopt localoptions noshwordsplit

  local cache_path=$1
  local ttl=${2:-$DOT_PROMPT_GIT_WATCH_TTL}
  local -a stat

  [[ -s $cache_path ]] || return 1
  zmodload zsh/datetime 2>/dev/null || return 1
  zmodload zsh/stat 2>/dev/null || return 1
  zstat -A stat +mtime -- "$cache_path" 2>/dev/null || return 1

  (( EPOCHSECONDS - stat[1] < ttl ))
}

dot_prompt_git_watch_register_trigger() {
  setopt localoptions noshwordsplit

  local root=$1
  local name=$2
  local top=$3
  local updater=${DOT_PROMPT_GIT_WATCH_UPDATE_COMMAND:-$HOME/dotfiles/bin/dot-prompt-git-watch-update}
  local root_json name_json updater_json top_json

  [[ -x $updater ]] || return 1
  command watchman watch "$root" >/dev/null 2>&1 || return 1

  dot_prompt_json_quote "$root"; root_json=$REPLY
  dot_prompt_json_quote "$name"; name_json=$REPLY
  dot_prompt_json_quote "$updater"; updater_json=$REPLY
  dot_prompt_json_quote "$top"; top_json=$REPLY

  print -r -- "[\"trigger\", ${root_json}, {\"name\": ${name_json}, \"expression\": [\"true\"], \"command\": [${updater_json}, ${top_json}]}]" |
    command watchman -j >/dev/null 2>&1
}

dot_prompt_git_watch_ensure() {
  setopt localoptions noshwordsplit

  local top=$1
  local git_dir=$2
  local cache_path=$3
  local watch_state="${cache_path}.watch"
  local watch_lock="${cache_path}.watch.flock"
  local lock_fd

  command -v watchman >/dev/null || return 1
  dot_prompt_git_cache_is_fresh "$watch_state" "$DOT_PROMPT_GIT_WATCH_TTL" && return 0

  command mkdir -p "${cache_path:h}" 2>/dev/null || return 1
  dot_prompt_git_lock_acquire "$watch_lock" 0 || return 0
  lock_fd=$REPLY
  if dot_prompt_git_watch_register_trigger "$top" dot-prompt-git-worktree "$top" &&
     dot_prompt_git_watch_register_trigger "$git_dir" dot-prompt-git-gitdir "$top"; then
    print -r -- "$top" >| "$watch_state"
  fi
  dot_prompt_git_lock_release "$lock_fd"
}

dot_prompt_git_status_from_cache() {
  setopt localoptions noshwordsplit

  local cache_path=$1
  local line mtime=0
  local -a items stat
  local -A info

  [[ -r $cache_path ]] || return 1
  # Stat before reading so a newer write's mtime never gets tied to older content
  if zmodload zsh/stat 2>/dev/null && zstat -A stat +mtime -- "$cache_path" 2>/dev/null; then
    mtime=$stat[1]
  fi
  IFS= read -r line < "$cache_path" || return 1
  [[ -n $line ]] || return 1

  items=("${(Q@)${(z)line}}")
  (( ${#items} > 0 && ${#items} % 2 == 0 )) || return 1

  info=("${items[@]}")
  info[pwd]=$PWD
  info[mtime]=$mtime
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
  local source=${2:-direct}
  local cache_path lock_path tmp_path output code=0
  local canonical_top debounce_path lock_fd=""

  if [[ -n $top ]]; then
    builtin cd -q "$top" 2>/dev/null || return 1
  fi

  canonical_top=$(command git rev-parse --show-toplevel 2>/dev/null) || return 1
  dot_prompt_git_cache_path_for_top "$canonical_top"
  cache_path=$REPLY
  lock_path="${cache_path}.flock"
  debounce_path="${cache_path}.updated"

  command mkdir -p "${cache_path:h}" 2>/dev/null || return 1

  if [[ $source == watch ]]; then
    # Watchman-driven updates must capture the state after the triggering
    # change, so wait for any in-flight update instead of skipping.
    dot_prompt_git_lock_acquire "$lock_path" "$DOT_PROMPT_GIT_WATCH_LOCK_WAIT" || return 1
    lock_fd=$REPLY
    # Treat the debounce as a throttle: wait it out and always recompute.
    # Skipping would drop the final state of a rapid change sequence.
    while dot_prompt_git_cache_is_fresh "$debounce_path" "$DOT_PROMPT_GIT_UPDATE_DEBOUNCE"; do
      command sleep 0.2
    done
  else
    if ! dot_prompt_git_lock_acquire "$lock_path" 0; then
      # Another updater is running. Returning empty output would make the
      # caller discard the repo state and blank the prompt, so serve the
      # current cache content instead.
      dot_prompt_git_status_from_cache "$cache_path"
      return $?
    fi
    lock_fd=$REPLY
  fi

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
  print -r -- "$canonical_top" >| "$debounce_path"
  # Re-read through the cache so the reported mtime matches the content
  dot_prompt_git_status_from_cache "$cache_path"
  code=$?
  dot_prompt_git_lock_release "$lock_fd"
  return $code
}

dot_prompt_git_status() {
  setopt localoptions noshwordsplit

  local mode=${1:-cached}
  local cache_path top git_dir output

  if [[ $mode == cache-only ]]; then
    cache_path=$2
    [[ -n $cache_path ]] || return 1
    dot_prompt_git_status_from_cache "$cache_path"
    return $?
  fi

  if ! top=$(command git rev-parse --show-toplevel 2>/dev/null); then
    # Outside a repo, return a sentinel with an empty top. Empty output and
    # non-zero codes are treated as transient failures, so be explicit here.
    local -A info
    info=(pwd "$PWD" top "")
    print -r -- ${(@kvq)info}
    return 0
  fi
  git_dir=$(command git rev-parse --absolute-git-dir 2>/dev/null) || return 1
  dot_prompt_git_cache_path_for_top "$top"
  cache_path=$REPLY
  dot_prompt_git_watch_ensure "$top" "$git_dir" "$cache_path" || true

  if [[ $mode != force ]] && [[ -s $cache_path ]]; then
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
