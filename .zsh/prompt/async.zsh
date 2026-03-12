typeset -g DOT_PROMPT_ASYNC_INITED=0
typeset -g DOT_PROMPT_ASYNC_RENDER_REQUESTED=0
typeset -g DOT_PROMPT_GIT_PWD=""

dot_prompt_async_renice() {
  setopt localoptions noshwordsplit

  if command -v renice >/dev/null; then
    command renice +15 -p $$ >/dev/null 2>&1
  fi

  if command -v ionice >/dev/null; then
    command ionice -c 3 -p $$ >/dev/null 2>&1
  fi
}

dot_prompt_async_init() {
  if (( DOT_PROMPT_ASYNC_INITED )); then
    return
  fi

  DOT_PROMPT_ASYNC_INITED=1
  async_start_worker dot_prompt_git -u -n
  async_register_callback dot_prompt_git dot_prompt_async_callback
  async_worker_eval dot_prompt_git dot_prompt_async_renice
}

dot_prompt_async_reset_repo_state() {
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
  typeset -g DOT_PROMPT_GIT_PWD=""
}

dot_prompt_async_maybe_reset_for_pwd() {
  if [[ -n $DOT_PROMPT_GIT_PWD ]] && [[ $PWD != $DOT_PROMPT_GIT_PWD && $PWD != $DOT_PROMPT_GIT_PWD/* ]]; then
    if (( DOT_PROMPT_ASYNC_INITED )); then
      async_flush_jobs dot_prompt_git
    fi
    dot_prompt_async_reset_repo_state
  fi
}

dot_prompt_async_refresh() {
  async_job dot_prompt_git dot_prompt_git_status
}

dot_prompt_async_tasks() {
  dot_prompt_async_init
  async_worker_eval dot_prompt_git builtin cd -q "$PWD"
  dot_prompt_async_refresh
}

dot_prompt_async_render() {
  dot_prompt_build_right_base
  dot_prompt_build_git_prompt
  dot_prompt_build_left "$DOT_PROMPT_LAST_EXIT"
  dot_prompt_apply_render
  dot_prompt_reset_prompt
}

dot_prompt_async_callback() {
  setopt localoptions noshwordsplit

  local job=$1
  local code=$2
  local output=$3
  local next_pending=$6
  local do_render=0

  case $job in
    \[async])
      if (( code == 2 || code == 3 || code == 130 )); then
        DOT_PROMPT_ASYNC_INITED=0
        async_stop_worker dot_prompt_git
        dot_prompt_async_reset_repo_state
        dot_prompt_async_init
        dot_prompt_async_tasks
      fi
      ;;
    dot_prompt_git_status)
      local -A info
      local state_changed=0
      info=("${(Q@)${(z)output}}")

      if [[ $info[pwd] != $PWD ]]; then
        return
      fi

      [[ $DOT_PROMPT_GIT_BRANCH != $info[branch] ]] && state_changed=1
      [[ $DOT_PROMPT_GIT_DETACHED != $info[detached] ]] && state_changed=1
      [[ $DOT_PROMPT_GIT_UPSTREAM != $info[upstream] ]] && state_changed=1
      [[ $DOT_PROMPT_GIT_ACTION != $info[action] ]] && state_changed=1
      [[ $DOT_PROMPT_GIT_CONFLICT != $info[conflict] ]] && state_changed=1
      [[ $DOT_PROMPT_GIT_TOP != $info[top] ]] && state_changed=1
      [[ $DOT_PROMPT_GIT_AHEAD != ${info[ahead]:-0} ]] && state_changed=1
      [[ $DOT_PROMPT_GIT_BEHIND != ${info[behind]:-0} ]] && state_changed=1
      [[ $DOT_PROMPT_GIT_UNMERGED != ${info[unmerged]:-0} ]] && state_changed=1
      [[ $DOT_PROMPT_GIT_STAGED != ${info[staged]:-0} ]] && state_changed=1
      [[ $DOT_PROMPT_GIT_UNSTAGED != ${info[unstaged]:-0} ]] && state_changed=1
      [[ $DOT_PROMPT_GIT_UNTRACKED != ${info[untracked]:-0} ]] && state_changed=1
      [[ $DOT_PROMPT_GIT_STASH != ${info[stash]:-0} ]] && state_changed=1

      typeset -g DOT_PROMPT_GIT_BRANCH=$info[branch]
      typeset -g DOT_PROMPT_GIT_DETACHED=$info[detached]
      typeset -g DOT_PROMPT_GIT_UPSTREAM=$info[upstream]
      typeset -g DOT_PROMPT_GIT_ACTION=$info[action]
      typeset -g DOT_PROMPT_GIT_CONFLICT=$info[conflict]
      typeset -g DOT_PROMPT_GIT_TOP=$info[top]
      typeset -g DOT_PROMPT_GIT_AHEAD=${info[ahead]:-0}
      typeset -g DOT_PROMPT_GIT_BEHIND=${info[behind]:-0}
      typeset -g DOT_PROMPT_GIT_UNMERGED=${info[unmerged]:-0}
      typeset -g DOT_PROMPT_GIT_STAGED=${info[staged]:-0}
      typeset -g DOT_PROMPT_GIT_UNSTAGED=${info[unstaged]:-0}
      typeset -g DOT_PROMPT_GIT_UNTRACKED=${info[untracked]:-0}
      typeset -g DOT_PROMPT_GIT_STASH=${info[stash]:-0}
      if [[ -n $info[top] ]]; then
        typeset -g DOT_PROMPT_GIT_PWD=$info[top]
      else
        typeset -g DOT_PROMPT_GIT_PWD=""
      fi

      if [[ -z $info[top] ]]; then
        dot_prompt_async_reset_repo_state
      fi

      do_render=$state_changed
      ;;
  esac

  if (( next_pending )); then
    (( do_render )) && typeset -g DOT_PROMPT_ASYNC_RENDER_REQUESTED=1
    return
  fi

  if (( DOT_PROMPT_ASYNC_RENDER_REQUESTED || do_render )); then
    dot_prompt_async_render
  fi
  typeset -g DOT_PROMPT_ASYNC_RENDER_REQUESTED=0
}

dot_prompt_async_shutdown() {
  if (( DOT_PROMPT_ASYNC_INITED )); then
    async_stop_worker dot_prompt_git
    DOT_PROMPT_ASYNC_INITED=0
  fi
}
