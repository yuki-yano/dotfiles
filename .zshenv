#!/usr/local/bin/zsh

# profile
# zmodload zsh/zprof && zprof

export XDG_CONFIG_DIR=$HOME/.config

# language
export LANG=ja_JP.UTF-8

# editor
export EDITOR=nvim
export VISUAL=nvim
alias vi=nvim

# lambdalisue/vim-manpager
export MANPAGER='nvim -c ASMANPAGER -'

# Disable path_helper
# show: http://qiita.com/t-takaai/items/8574ff312f2caa5177c2
setopt no_global_rcs

typeset -U path fpath

# default path
path=(/opt/homebrew/bin(N-/) /usr/local/bin(N-/) /usr/bin(N-/) /bin(N-/) /sbin(N-/) /usr/sbin(N-/) /usr/local/sbin(N-/) ~/dotfiles/bin(N-/) ~/.bin(N-/))
fpath=(~/.zsh/completions(N-/) $fpath)

# OpenSSL
path=(/usr/local/opt/openssl/bin(N-/) $path)
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/

# homebrew
alias brew="PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin brew"

# zinit
ZPLG_HOME=$HOME/.zinit
ZPFX=$ZPLG_HOME/polaris
path=($ZPFX/bin(N-/) $path)

# popd
alias p=popd

# ripgrep
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/rc

# XDG Base Directory
export XDG_CONFIG_HOME=$HOME/.config

# gtags
export GTAGSLABEL=pygments

# mise
eval "$(/opt/homebrew/bin/mise activate zsh)"

# pnpm
# export PNPM_HOME="/Users/yuki-yano/Library/pnpm"
export PNPM_HOME=$HOME/Library/pnpm
path=($PNPM_HOME(N-/) $path)

# deno
path=(~/.deno/bin(N-/) $path)

# bun
path=(~/.bun/bin(N-/) $path)

# Ruby
path=(/opt/homebrew/opt/ruby/bin(N-/) $path)

# Rust
if [[ -d "$HOME/.cargo" ]]; then
  path=(~/.cargo/bin(N-/) $path)
  source "$HOME/.cargo/env"
fi

# go
export GOPATH=$HOME/.go
path=(~/.go/bin(N-/) ~/.ghg/bin(N-/) $path)

# java
export JAVA_HOME=$(/usr/libexec/java_home -v "14")

# llvm
path=(/usr/local/opt/llvm/bin(N-/) $path)

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

# NOTE: Workaround for Homebrew shellenv in sandbox-exec environments
#
# Issue:
# - AI Agents like Claude Code run brew commands in sandbox-exec environments
# - brew internally calls shellenv which tries to detect the shell name
# - shellenv executes /bin/ps to detect the parent shell, but ps is restricted in sandbox
# - This causes brew commands to fail with "Operation not permitted" errors
#
# Solution:
# - When HOMEBREW_PATH is already set, shellenv skips the ps command execution
# - By pre-setting this environment variable, we can avoid the sandbox restriction
# - This allows brew to work without modifying Homebrew's source code
#
# Reference: Library/Homebrew/cmd/shellenv.sh:9-11

#  Finally add the path of ~/bin and ~/dotfiles/bin to the beginning
path=(~/bin(N-/) $path)
path=(~/dotfiles/bin(N-/) $path)
path=(~/.local/bin(N-/) $path)

# Added by Windsurf
path=(~/.codeium/windsurf/bin(N-/) $path)

# Added by LM Studio CLI (lms)
path=(~/.lmstudio/bin(N-/) $path)

# vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
