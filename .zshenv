#! /usr/local/bin/zsh

# profile
# zmodload zsh/zprof && zprof

# language
export LANG=ja_JP.UTF-8

# editor
export EDITOR=nvim
export VISUAL=nvim
export MANPAGER='nvim -c MANPAGER -'
alias c=ccat

# path_helperを実行しないようにする
# show: http://qiita.com/t-takaai/items/8574ff312f2caa5177c2
setopt no_global_rcs

typeset -U path fpath

# default path
path=(~/dotfiles/node_modules/.bin(N-/) /usr/local/bin(N-/) /usr/bin(N-/) /bin(N-/) /sbin(N-/) /usr/sbin(N-/) /usr/X11/bin(N-/))
fpath=(~/.zsh/completions(N-/) $fpath)

# curl
path=(/usr/local/opt/curl/bin(N-/) $path)

# XDG Base Directory
export XDG_CONFIG_HOME=$HOME/.config

# gtags
export GTAGSLABEL=pygments

# homebrew
alias brew='env PATH=${PATH/${HOME}\/\.pyenv\/shims:/} brew'

# rbenv
path=(~/.rbenv/shims(N-/) $path)
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

# python2
path=(/usr/local/opt/python@2/bin(N-/) $path)

# pyenv
path=(~/.pyenv/shims(N-/) $path)
export PYENV_ROOT=~/.pyenv
export PYENV_SHELL=zsh
export PYTHON_CONFIGURE_OPTS='--enable-framework'
pyenv() {
  local command
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
    rehash|shell)
      eval "$(pyenv "sh-$command" "$@")";;
    *)
      command pyenv "$command" "$@";;
  esac
}

# nodenv
path=(~/.nodenv/shims(N-/) $path)
export NODENV_SHELL=zsh
nodenv() {
  local command
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
    rehash|shell)
      eval "$(nodenv "sh-$command" "$@")";;
    *)
      command nodenv "$command" "$@";;
  esac
}

# go
export GOPATH=$HOME/.go
path=(~/.go/bin(N-/) ~/.ghg/bin(N-/) $path)

# rust
path=(~/.cargo/bin(N-/) $path)

# llvm
path=(/usr/local/opt/llvm/bin(N-/) $path)

# heroku
## Update completions
## $ heroku autocomplete --refresh-cache
path=(/usr/local/heroku/bin(N-/) $path)
export HEROKU_AC_ANALYTICS_DIR=~/Library/Caches/heroku/autocomplete/completion_analytics
export HEROKU_AC_COMMANDS_PATH=~/Library/Caches/heroku/autocomplete/commands
export HEROKU_AC_ZSH_SETTERS_PATH=${HEROKU_AC_COMMANDS_PATH}_setters && test -f $HEROKU_AC_ZSH_SETTERS_PATH && source $HEROKU_AC_ZSH_SETTERS_PATH

# vim
alias vi='nvim'
alias vr='nvr'
alias vimdiff='nvim -d'

# eslint-friendly-formatter
export EFF_NO_GRAY=true

# ls
if whence exa > /dev/null; then
  alias ls="exa"
  alias ll="exa -lh  --git"
  alias la="exa -alh --git"
  alias lt="exa -alh --git"
elif whence gls > /dev/null; then
  alias ls='gls --color=auto'
  alias ll='ls -lh'
  alias la='ls -alh'
else
  alias ll='ls -lh'
  alias la='ls -alh'
fi

# sed
if whence gsed > /dev/null; then
  alias sed='gsed'
fi

# cd
alias u='cd ..'
alias uu='cd ../..'
alias uuu='cd ../../..'
alias uuuu='cd ../../../..'

# diff
alias diff='diff -u'

# rpgrep
function rg() {
  if [[ -t 1 ]]; then
    command rg -p "$@" | less -RFX
  else
    command rg "$@"
  fi
}

# popd
alias p='popd'

# yes
alias y='yes'

# git
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
alias agit='nvim +Agit'
alias gitt='gittower .'

function gwt() {
  GIT_CDUP_DIR=$(git rev-parse --show-cdup)
  git worktree add "${GIT_CDUP_DIR}git-worktrees/$1 -b $1"
}

# tmux
if [[ -z $TMUX ]]; then
  function tmux() {
    if [[ $# == 0 ]] && tmux has-session 2>/dev/null; then
      command tmux attach-session
    else
      command tmux "$@"
    fi
  }
fi

# direnv
if whence direnv > /dev/null; then
  _direnv_hook() {
    eval "$(direnv export zsh)";
  }
  typeset -ag precmd_functions;
  if [[ -z ${precmd_functions[(r)_direnv_hook]} ]]; then
    precmd_functions+=(_direnv_hook);
  fi
fi

# pbcopy
alias -g C='| pbcopy'

#  Finally add the path of dotfiles/bin to the beginning
path=(~/dotfiles/bin(N-/) $path)

# config
[ -f ~/.config/nicovideo-dump.zsh ] && source "${XDG_CONFIG_HOME}/nicovideo-dump.zsh"

# vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
