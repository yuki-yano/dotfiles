#!/usr/bin/zsh

function _fzf-anyenv-completion() {
  local tokens cmd1 cmd2 cmd3
  setopt localoptions noshwordsplit
  tokens=(${(z)LBUFFER})
  cmd1=${tokens[1]}
  cmd2=${tokens[2]}
  cmd3=${tokens[3]}

  case "$cmd1" in rbenv|pyenv|nodenv)
     case "$cmd2" in
       install|uninstall|global|local)
         case "$cmd3" in
           '')
             _fzf_complete_anyenv_versions $cmd1 $cmd2
             return
           ;;
         esac
       ;;
     esac
     ;;
  esac
  zle expand-or-complete
}
zle -N fzf-anyenv-completion _fzf-anyenv-completion

function _fzf_complete_anyenv_versions() {
  local versions
  versions=$($1 completions $2)
  FZF_COMPLETION_OPTS='--multi --height 80% --prompt "anyenv versions>"'
  _fzf_complete '' "$BUFFER" < <(
    echo $versions
  )
}
