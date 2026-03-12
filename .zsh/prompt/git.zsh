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

dot_prompt_git_status() {
  setopt localoptions noshwordsplit

  local -A info
  local git_dir oid="" branch="" upstream="" line
  local ahead=0 behind=0 staged=0 unstaged=0 untracked=0 unmerged=0 stash=0
  local action="" conflict=""

  info[pwd]=$PWD
  info[top]=$(command git rev-parse --show-toplevel 2>/dev/null) || return 1
  git_dir=$(command git rev-parse --git-dir 2>/dev/null) || return 1

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
    info[branch]=${branch//\%/%%}
  fi
  info[upstream]=${upstream//\%/%%}
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
