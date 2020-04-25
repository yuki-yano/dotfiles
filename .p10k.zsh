() {
  # Prompt colors.
  local grey='246'
  local red='1'
  local yellow='3'
  local blue='4'
  local magenta='5'
  local cyan='6'
  local white='7'

  function prompt_anyenv() {
    local ruby_version python_version node_version

    if which rbenv > /dev/null 2>&1; then
      ruby_version="Ruby-$(rbenv version-name)"
    fi
    if which pyenv > /dev/null 2>&1; then
      if [[ -n "$VIRTUAL_ENV" ]]; then
        python_version="Python-venv"
      else
        python_version="Python-$(pyenv version-name)"
      fi
    fi
    if which nodenv > /dev/null 2>&1; then
      node_version="Node-$(nodenv version-name)"
    fi
    p10k segment -f white -t "[%{$MAGENTA%}${ruby_version}%{$DEFAULT%} %{$GREEN%}${python_version}%{$DEFAULT%} %{$BLUE%}${node_version}%{$DEFAULT%}]"
  }

  function prompt_venv() {
    local venv
    venv=""
    if [[ -n "$VIRTUAL_ENV" ]]; then
      venv="venv:$(basename $VIRTUAL_ENV)"
      p10k segment -f white -t "[%F{72}${venv}%f]"
    fi
  }

  function prompt_show_buffer_stack() {
    p10k segment -f white -e -t '$COMMAND_BUFFER_STACK'
  }
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir
    vcs
    anyenv
    newline
    venv
    prompt_char
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    show_buffer_stack
  )

  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=

  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
}
