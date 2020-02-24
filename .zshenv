#!/usr/local/bin/zsh

# profile
# zmodload zsh/zprof && zprof

# language
export LANG=ja_JP.UTF-8

# editor
export EDITOR=nvim
export VISUAL=nvim
export MANPAGER='nvim -c MANPAGER -'

# Disable path_helper
# show: http://qiita.com/t-takaai/items/8574ff312f2caa5177c2
setopt no_global_rcs

typeset -U path fpath

# default path
path=(~/.config/yarn/global/node_modules/.bin(N-/) /usr/local/bin(N-/) /usr/bin(N-/) /bin(N-/) /sbin(N-/) /usr/sbin(N-/) /usr/X11/bin(N-/))
fpath=(~/.zsh/completions(N-/) $fpath)

# library path
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/

# zinit
ZPLG_HOME=$HOME/.zinit
ZPFX=$ZPLG_HOME/polaris
path=($ZPFX/bin(N-/) $path)

# curl
path=(/usr/local/opt/curl/bin(N-/) $path)

# XDG Base Directory
export XDG_CONFIG_HOME=$HOME/.config

# gtags
export GTAGSLABEL=pygments

# ripgrep
RIPGREP_CONFIG_PATH=$HOME/.ripgreprc

# homebrew
alias brew='env PATH=${PATH/${HOME}\/\.pyenv\/shims:/} brew'

# ruby
alias grspec='rspec'

# rbenv
path=(~/.rbenv/shims(N-/) $path)
export RBENV_SHELL=zsh
function rbenv() {
  local command
  command="$1"
  if [[ "$#" -gt 0 ]]; then
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
  if [[ "$#" -gt 0 ]]; then
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
  if [[ "$#" -gt 0 ]]; then
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
if [[ ! -d $HOME/.cargo ]]; then
  echo ">>>Install rustup \n"
  yes 1 | curl https://sh.rustup.rs -sSf | sh
  echo ">>>Install Completed \n"
  rustup install nightly
  rustup default nightly
fi

# java
export JAVA_HOME=$(/usr/libexec/java_home -v "13")

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

# popd
alias p='popd'

# yes
alias y='yes'

# git
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

#  Finally add the path of ~/bin and ~/dotfiles/bin to the beginning
path=(~/bin(N-/) $path)
path=(~/dotfiles/bin(N-/) $path)

# config
[[ -f ~/.config/nicovideo-dump.zsh ]] && source "${XDG_CONFIG_HOME}/nicovideo-dump.zsh"

# vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
