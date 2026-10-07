#!/usr/local/bin/zsh

# profile
# zmodload zsh/zprof && zprof

export XDG_CONFIG_DIR=$HOME/.config
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share

# language
export LANG=ja_JP.UTF-8

# editor
export EDITOR=nvim
export VISUAL=nvim
export MANPAGER="nvim +Man!"

# ripgrep
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/rc

# runtime paths
export PNPM_HOME=$XDG_DATA_HOME/pnpm
export GOPATH=$HOME/.go
export MISE_SHIMS_DIR=$XDG_DATA_HOME/mise/shims
export VITE_PLUS_HOME=$HOME/.vite-plus

# Disable path_helper
# show: http://qiita.com/t-takaai/items/8574ff312f2caa5177c2
setopt no_global_rcs

typeset -U path

# Preserve absolute environment paths; let mise shims select repo tools.
typeset -a dot_zsh_inherited_path=()
for dot_zsh_directory in "${path[@]}"; do
  [[ $dot_zsh_directory == /* ]] || continue
  while [[ $dot_zsh_directory != / && $dot_zsh_directory == */ ]]; do
    dot_zsh_directory=${dot_zsh_directory%/}
  done
  [[ $dot_zsh_directory != ${XDG_DATA_HOME}/mise/installs/* &&
     $dot_zsh_directory != "$HOME/.nix-profile/bin" &&
     $dot_zsh_directory != "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/bin" ]] || continue
  dot_zsh_inherited_path+=("$dot_zsh_directory")
done
unset dot_zsh_directory

# Global startup files are disabled; initialize Nix's variables once ourselves.
if [[ -z ${__ETC_PROFILE_NIX_SOURCED:-} && -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# default path
# Add only Nix itself globally; repo environments provide their own package paths.
# ^M prevents mark_dirs from appending slashes when this file is sourced again.
path=(
  /nix/var/nix/profiles/default/bin(N-/^M)
  /opt/homebrew/bin(N-/^M) /usr/local/bin(N-/^M)
  /usr/bin(N-/^M) /bin(N-/^M) /sbin(N-/^M) /usr/sbin(N-/^M) /usr/local/sbin(N-/^M)
  ~/dotfiles/bin(N-/^M) ~/.bin(N-/^M)
)

# mise
path=(${MISE_SHIMS_DIR}(N-/^M) $path)

# cargo
path=(~/.cargo/bin(N-/^M) $path)

# pnpm
path=($PNPM_HOME(N-/^M) $path)

# deno
path=(~/.deno/bin(N-/^M) $path)

# bun
path=(~/.bun/bin(N-/^M) $path)
path=(~/.cache/.bun/bin(N-/^M) $path)

# vite-plus
path=(${VITE_PLUS_HOME}/bin(N-/^M) $path)

# Ruby
path=(/opt/homebrew/opt/ruby/bin(N-/^M) $path)

# go
path=($GOPATH/bin(N-/^M) ~/.ghg/bin(N-/^M) $path)

# luarocks
path=(~/.luarocks/bin(N-/^M) $path)

# llvm
# path=(/usr/local/opt/llvm/bin(N-/) $path)

# home bin
path=(~/bin(N-/^M) $path)
path=(~/dotfiles/bin(N-/^M) $path)
path=(~/.local/bin(N-/^M) $path)

# Added by Alacritty
path=(/Applications/Alacritty.app/Contents/MacOS(N-/^M) $path)

# Flutter SDK
path=(~/develop/flutter/bin(N-/^M) $path)

# LM Studio
path=(~/.lmstudio/bin(N-/^M) $path)

# Obsidian
path=(/Applications/Obsidian.app/Contents/MacOS(N-/^M) $path)

# Keep inherited environment paths ahead of the normal host tools.
path=("${(@)dot_zsh_inherited_path:|path}" "${path[@]}")
unset dot_zsh_inherited_path

# vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
