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
path=(~/.config/yarn/global/node_modules/.bin(N-/) /usr/local/bin(N-/) /usr/bin(N-/) /bin(N-/) /sbin(N-/) /usr/sbin(N-/) /usr/local/sbin(N-/) /usr/X11/bin(N-/))
fpath=(~/.zsh/completions(N-/) $fpath)

# library path
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/

# zinit
ZPLG_HOME=$HOME/.zinit
ZPFX=$ZPLG_HOME/polaris
path=($ZPFX/bin(N-/) $path)

# popd
alias p=popd

# curl
path=(/usr/local/opt/curl/bin(N-/) $path)

# ripgrep
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/rc

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

# Rust
path=(~/.cargo/bin(N-/) $path)

# go
export GOPATH=$HOME/.go
path=(~/.go/bin(N-/) ~/.ghg/bin(N-/) $path)

# java
export JAVA_HOME=$(/usr/libexec/java_home -v "14")

# llvm
path=(/usr/local/opt/llvm/bin(N-/) $path)

# heroku
## Update completions
## $ heroku autocomplete --refresh-cache
path=(/usr/local/heroku/bin(N-/) $path)
export HEROKU_AC_ANALYTICS_DIR=~/Library/Caches/heroku/autocomplete/completion_analytics
export HEROKU_AC_COMMANDS_PATH=~/Library/Caches/heroku/autocomplete/commands
export HEROKU_AC_ZSH_SETTERS_PATH=${HEROKU_AC_COMMANDS_PATH}_setters && test -f $HEROKU_AC_ZSH_SETTERS_PATH && source $HEROKU_AC_ZSH_SETTERS_PATH

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

#  Finally add the path of ~/bin and ~/dotfiles/bin to the beginning
path=(~/bin(N-/) $path)
path=(~/dotfiles/bin(N-/) $path)

# vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
