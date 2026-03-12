dot_prompt_precmd() {
  local exit_code=$?

  typeset -g DOT_PROMPT_LAST_EXIT=$exit_code
  typeset -g DOT_PROMPT_GIT_VISIBLE=1

  if (( DOT_PROMPT_HAS_RENDERED )) && (( ! DOT_PROMPT_SUPPRESS_PRECMD_NEWLINE )); then
    print
  else
    typeset -g DOT_PROMPT_HAS_RENDERED=1
  fi
  typeset -g DOT_PROMPT_SUPPRESS_PRECMD_NEWLINE=0

  dot_prompt_async_maybe_reset_for_pwd
  dot_prompt_build_right_base
  dot_prompt_build_git_prompt
  dot_prompt_build_left "$exit_code"
  dot_prompt_apply_render
  dot_prompt_async_tasks
}

dot_prompt_preexec() {
  case $2 in
    clear|clear\ *|command\ clear|command\ clear\ *|builtin\ clear|builtin\ clear\ *)
      typeset -g DOT_PROMPT_SUPPRESS_PRECMD_NEWLINE=1
      ;;
    *)
      typeset -g DOT_PROMPT_SUPPRESS_PRECMD_NEWLINE=0
      ;;
  esac
}

dot_prompt_zle_line_finish() {
  typeset -g DOT_PROMPT_GIT_VISIBLE=0
}

dot_prompt_zle_line_init() {
  typeset -g DOT_PROMPT_GIT_VISIBLE=1

  if (( ${DOT_BUFFER_STACK_RESTORE_PENDING:-0} )) && (( ${#buffer_stack_value_arr:-0} > 0 )) && (( $+functions[dot-buffer-stack-pop] )); then
    typeset -g DOT_BUFFER_STACK_RESTORE_PENDING=0
    dot-buffer-stack-pop
    dot_prompt_refresh_right
    zle reset-prompt
  fi
}

dot_prompt_zle_line_pre_redraw() {
  dot_prompt_refresh_right
}

dot_prompt_clear_screen() {
  typeset -g DOT_PROMPT_SUPPRESS_PRECMD_NEWLINE=1
  typeset -g DOT_PROMPT_GIT_VISIBLE=1
  dot_prompt_refresh_right
  dot_prompt_build_git_prompt
  dot_prompt_build_left "$DOT_PROMPT_LAST_EXIT"
  dot_prompt_apply_render
  zle .clear-screen
}

clear() {
  if [[ -o interactive ]]; then
    typeset -g DOT_PROMPT_SUPPRESS_PRECMD_NEWLINE=1
    print -n -- $'\e[H\e[2J\e[3J'
    return 0
  fi

  command clear "$@"
}

dot_prompt_setup() {
  autoload -Uz add-zsh-hook
  autoload -Uz add-zle-hook-widget

  add-zsh-hook precmd dot_prompt_precmd
  add-zsh-hook preexec dot_prompt_preexec
  add-zsh-hook zshexit dot_prompt_async_shutdown
  add-zle-hook-widget zle-line-finish dot_prompt_zle_line_finish
  add-zle-hook-widget zle-line-init dot_prompt_zle_line_init
  add-zle-hook-widget zle-line-pre-redraw dot_prompt_zle_line_pre_redraw
  zle -N clear-screen dot_prompt_clear_screen
}

dot_prompt_setup
