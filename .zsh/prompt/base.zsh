typeset -g DOT_PROMPT_LEFT=""
typeset -g DOT_PROMPT_RIGHT_BASE=""
typeset -g DOT_PROMPT_GIT_PROMPT=""
typeset -g DOT_PROMPT_LAST_EXIT=0
typeset -g DOT_PROMPT_HAS_RENDERED=0
typeset -g DOT_PROMPT_SUPPRESS_PRECMD_NEWLINE=0
typeset -g DOT_PROMPT_TRANSIENT_ACTIVE=0

dot_prompt_escape() {
  REPLY=${1//\%/%%}
}

dot_prompt_build_left() {
  local exit_code=${1:-0}
  local path_display="${(%):-%~}"
  local -a badges=()
  local prompt_char prompt_color venv_segment=""

  dot_prompt_escape "$path_display"
  path_display=$REPLY

  if [[ -n $DOT_PROMPT_GIT_CONFLICT ]]; then
    badges+=("%F{1} Conflicting %f")
  fi
  if [[ -n $DOT_PROMPT_GIT_ACTION ]]; then
    dot_prompt_escape "$DOT_PROMPT_GIT_ACTION"
    badges+=("%F{1} ${REPLY} %f")
  fi

  if [[ -n $VIRTUAL_ENV ]]; then
    dot_prompt_escape "${VIRTUAL_ENV:t}"
    venv_segment="%F{72}[venv:${REPLY}]%f "
  fi

  prompt_char='$'
  if (( exit_code == 0 )); then
    prompt_color=7
  else
    prompt_color=1
  fi

  if (( ${DOT_PROMPT_ENABLE_TRANSIENT:-0} )) && (( DOT_PROMPT_TRANSIENT_ACTIVE )); then
    typeset -g DOT_PROMPT_LEFT="%F{${prompt_color}}${prompt_char}%f "
    return
  fi

  typeset -g DOT_PROMPT_LEFT="%F{4}${path_display}%f"
  if (( $#badges > 0 )); then
    DOT_PROMPT_LEFT+=" ${(j: :)badges}"
  fi
  if [[ -n $DOT_PROMPT_GIT_PROMPT ]]; then
    DOT_PROMPT_LEFT+="${DOT_PROMPT_GIT_PROMPT}"
  fi
  DOT_PROMPT_LEFT+=$'\n'"${venv_segment}%F{${prompt_color}}${prompt_char}%f "
}

dot_prompt_build_right_base() {
  if (( ${DOT_PROMPT_ENABLE_TRANSIENT:-0} )) && (( DOT_PROMPT_TRANSIENT_ACTIVE )); then
    typeset -g DOT_PROMPT_RIGHT_BASE=""
    return
  fi

  local -a parts=()
  local command_buffer_stack=$COMMAND_BUFFER_STACK

  if (( $+functions[__susp_jobs_update_rprompt] )); then
    __susp_jobs_update_rprompt
  fi

  [[ -n $SUSP_JOBS_RPROMPT ]] && parts+=("$SUSP_JOBS_RPROMPT")
  [[ -n $command_buffer_stack ]] && parts+=("$command_buffer_stack")

  typeset -g DOT_PROMPT_RIGHT_BASE="${(j: :)parts}"
}

dot_prompt_refresh_right() {
  dot_prompt_build_right_base
  RPROMPT=$DOT_PROMPT_RIGHT_BASE
}

dot_prompt_apply_render() {
  PROMPT=$DOT_PROMPT_LEFT
  RPROMPT=$DOT_PROMPT_RIGHT_BASE
}

dot_prompt_reset_prompt() {
  if [[ -o zle ]] && zle >/dev/null 2>&1; then
    zle -R
  fi
}

dot_prompt_reset_prompt_full() {
  if [[ -o zle ]] && zle >/dev/null 2>&1; then
    zle reset-prompt
  fi
}
