#!/usr/bin/zsh

function _fzf-rspec-completion() {
  local tokens lastcmd
  setopt localoptions noshwordsplit
  tokens=(${(z)LBUFFER})
  lastcmd=${tokens[-1]}

  case "$lastcmd" in
    rspec)
      _fzf_complete_rspec_file
      return
      ;;
    grspec)
      _fzf_complete_git_rspec_file
      BUFFER=${BUFFER//grspec/rspec}
      CURSOR=$#BUFFER
      zle reset-prompt
      return
      ;;
  esac
  zle expand-or-complete
}

zle -N fzf-rspec-completion _fzf-rspec-completion

function _fzf_complete_rspec_file() {
  local files
  files=$(find spec -name "*_spec.rb")
  FZF_COMPLETION_OPTS='--multi --height 80% --prompt "RSpec Files>" --preview "ccat --color=always {}" --bind ctrl-d:preview-page-down,ctrl-u:preview-page-up,?:toggle-preview'
  _fzf_complete '' "$BUFFER" < <(
    echo $files
  )
}

function _fzf_complete_git_rspec_file() {
  local files
  files=$(git status --short | fzf-git-rspec)
  FZF_COMPLETION_OPTS='--multi --height 80% --prompt "Git RSpec Files>" --preview "git diff --color=always {}" --bind ctrl-d:preview-page-down,ctrl-u:preview-page-up,?:toggle-preview'
  _fzf_complete '' "$BUFFER" < <(
    echo $files
  )
}
