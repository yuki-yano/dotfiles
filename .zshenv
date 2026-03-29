#!/usr/local/bin/zsh

# profile
# zmodload zsh/zprof && zprof

export XDG_CONFIG_DIR=$HOME/.config
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache

# language
export LANG=ja_JP.UTF-8

# editor
export EDITOR=nvim
export VISUAL=nvim
export MANPAGER="nvim +Man!"

# ripgrep
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/rc

# runtime paths
export PNPM_HOME=$HOME/Library/pnpm
export GOPATH=$HOME/.go
export MISE_SHIMS_DIR=$HOME/.local/share/mise/shims

# Disable path_helper
# show: http://qiita.com/t-takaai/items/8574ff312f2caa5177c2
setopt no_global_rcs

typeset -U path

# default path
path=(/opt/homebrew/bin(N-/) /usr/local/bin(N-/) /usr/bin(N-/) /bin(N-/) /sbin(N-/) /usr/sbin(N-/) /usr/local/sbin(N-/) ~/dotfiles/bin(N-/) ~/.bin(N-/))

# mise
path=(${MISE_SHIMS_DIR}(N-/) $path)

# pnpm
path=($PNPM_HOME(N-/) $path)

# deno
path=(~/.deno/bin(N-/) $path)

# bun
path=(~/.bun/bin(N-/) $path)
path=(~/.cache/.bun/bin(N-/) $path)

# Ruby
path=(/opt/homebrew/opt/ruby/bin(N-/) $path)

# go
path=($GOPATH/bin(N-/) ~/.ghg/bin(N-/) $path)

# luarocks
path=(~/.luarocks/bin(N-/) $path)

# llvm
# path=(/usr/local/opt/llvm/bin(N-/) $path)

# home bin
path=(~/bin(N-/) $path)
path=(~/dotfiles/bin(N-/) $path)
path=(~/.local/bin(N-/) $path)

# Added by Alacritty
path=(/Applications/Alacritty.app/Contents/MacOS/(N-/) $path)

# Flutter SDK
path=(~/develop/flutter/bin(N-/) $path)

# LM Studio
path=(~/.lmstudio/bin(N-/) $path)

# Obsidian
path=(/Applications/Obsidian.app/Contents/MacOS(N-/) $path)

# vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
