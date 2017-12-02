# profile
# zmodload zsh/zprof && zprof

# 言語
export LANG=ja_JP.UTF-8

# エディタ
export EDITOR=nvim
alias c=ccat

# path_helperを実行しないようにする
# show: http://qiita.com/t-takaai/items/8574ff312f2caa5177c2
setopt no_global_rcs

# default path
export PATH=$HOME/dotfiles/bin:$HOME/dotfiles/vendor/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin
# Play
export PATH=$PATH:$HOME/.play
# node.js
export PATH=$PATH:$HOME/dotfiles/node_modules/.bin
# powerline
export PATH=$PATH:~/.local/bin

# rbenv
export PATH=$HOME/.rbenv/shims:$PATH
export RBENV_SHELL=zsh
function rbenv() {
  local command
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
    rehash|shell)
      eval "$(rbenv "sh-$command" "$@")";;
    *)
      command rbenv "$command" "$@";;
  esac
}

# python
export PATH=/usr/local/opt/python/libexec/bin:$PATH

# nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# go
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/.ghg/bin

# llvm
export PATH=/usr/local/opt/llvm/bin:$PATH

# heroku
export PATH=$PATH:/usr/local/heroku/bin

# vim
alias vi='nvim'
alias vr='nvr'

# eslint-friendly-formatter
export EFF_NO_GRAY=true

# ls
alias ll='ls -l'
alias la='ls -al'

# sed
alias sed=gsed

# cd
alias u='cd ..'
alias uu='cd ../..'
alias uuu='cd ../../..'
alias uuuu='cd ../../../..'

# popd
alias p='popd'

# yes
alias y='yes'

# updatedb
alias updatedb=/usr/libexec/locate.updatedb

# ruby
alias be='bundle exec'

# git alias
if whence hub > /dev/null; then
  alias git='nocorrect hub'
fi
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gs='git status --short --branch'
alias gb='git branch'
alias gd='git diff'
alias gdw='git diff --color-words'
alias gdc='git diff --cached'
alias gdcw='git diff --cached --color-words'
alias gco='git checkout'
alias gci='git commit'
alias gst='git stash'
alias gcb='git rev-parse --abbrev-ref HEAD'
alias agit='vim +Agit'
alias gitt='gittower .'

function gwt() {
  GIT_CDUP_DIR=`git rev-parse --show-cdup`
  git worktree add ${GIT_CDUP_DIR}git-worktrees/$1 -b $1
}

# diff
alias diff='diff -u'

# direnv
if whence direnv > /dev/null; then
  _direnv_hook() {
    eval "$(direnv export zsh)";
  }
  typeset -ag precmd_functions;
  if [[ -z ${precmd_functions[(r)_direnv_hook]} ]]; then
    precmd_functions+=_direnv_hook;
  fi
fi

# pbcopy
alias -g C='| pbcopy'

# git-foresta
function gifo() {
  git-foresta --style=10 "$@" | less -RSX
}
function gifa() {
  git-foresta --all --style=10 "$@" | less -RSX
}

# config
[ -f ~/.config/nicovideo-dump.zsh ] && source ~/.config/nicovideo-dump.zsh

# vim:set et ts=2 sts=2 sw=2 fen fdm=marker:
