#!/usr/bin/zsh

function _fzf-tmux-completion() {
  local tokens cmd1 cmd2 cmd3 cmd4
  setopt localoptions noshwordsplit
  tokens=(${(z)LBUFFER})
  cmd1=${tokens[1]}
  cmd2=${tokens[2]}
  cmd3=${tokens[3]}
  cmd4=${tokens[4]}

  case "$cmd1" in
    tmux)
      case "$cmd2" in
        swap-pane)
          case "$cmd3" in
            -t)
              case "$cmd4" in
                '')
                  _fzf_complete_tmux_pane
                  return
                  ;;
              esac
              ;;
          esac
          ;;
      esac
      ;;
  esac
  zle expand-or-complete
}
zle -N fzf-tmux-completion _fzf-tmux-completion

function _fzf_complete_tmux_pane() {
  local panes
  panes=$(tmux list-panes -sF '#I.#P #{pane_title}')
  FZF_COMPLETION_OPTS='--height 50% --prompt "tmux pane>"'
  _fzf_complete '' "$BUFFER" < <(
    echo $panes
  )
}

function _fzf_complete_tmux_pane_post() {
  awk '{ print $1 }'
}
