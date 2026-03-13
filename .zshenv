#!/usr/local/bin/zsh

# profile
# zmodload zsh/zprof && zprof

export XDG_CONFIG_DIR=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache

# language
export LANG=ja_JP.UTF-8

# cache profile
export CACHE_PROFILE="${XDG_CACHE_HOME}/zsh/profile"
export NI_ZSH_PLUGIN_SOURCE="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/repos/github.com/azu/ni.zsh/ni.zsh"
export NI_ZSH_PLUGIN_CACHE="${CACHE_PROFILE}/ni.zsh"
export PNPM_ZSH_COMPLETION_SOURCE="${XDG_CONFIG_HOME:-$HOME/.config}/tabtab/zsh/pnpm.zsh"
export PNPM_ZSH_COMPLETION_CACHE="${CACHE_PROFILE}/pnpm-completion.zsh"
export NPM_ZSH_COMPLETION_SOURCE=/opt/homebrew/share/zsh/site-functions/_npm
export NPM_ZSH_COMPLETION_CACHE="${CACHE_PROFILE}/npm-completion.zsh"
export BUN_ZSH_COMPLETION_CACHE="${CACHE_PROFILE}/bun-completion.zsh"
mkdir -p ${CACHE_PROFILE}
cache::clear() {
  rm -rf ${CACHE_PROFILE}
  mkdir -p ${CACHE_PROFILE}
}

cache::refresh_script_cache() {
  local source_file=$1
  local cache_file=$2

  if [[ ! -r $source_file ]]; then
    return 1
  fi

  if [[ ! -f $cache_file || $source_file -nt $cache_file ]]; then
    command cp "$source_file" "$cache_file"
    zcompile "$cache_file"
  fi
}

# editor
export EDITOR=nvim
export VISUAL=nvim
alias vi=nvim

export MANPAGER="nvim +Man!"

# Disable path_helper
# show: http://qiita.com/t-takaai/items/8574ff312f2caa5177c2
setopt no_global_rcs

typeset -U path fpath

# default path
path=(/opt/homebrew/bin(N-/) /usr/local/bin(N-/) /usr/bin(N-/) /bin(N-/) /sbin(N-/) /usr/sbin(N-/) /usr/local/sbin(N-/) ~/dotfiles/bin(N-/) ~/.bin(N-/))
fpath=(~/.zsh/completions(N-/) $fpath)

# homebrew
alias brew="PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin brew"

# popd
alias p=popd

# ripgrep
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/rc

# XDG Base Directory
export XDG_CONFIG_HOME=$HOME/.config

# gtags
# export GTAGSLABEL=pygments

# mise
# eval "$(/opt/homebrew/bin/mise activate zsh)"
if type mise &>/dev/null; then
  export MISE_SHIMS_CACHE=${CACHE_PROFILE}/mise-shims.zsh
  export MISE_ACTIVATE_CACHE=${CACHE_PROFILE}/mise.zsh
  export MISE_SHIMS_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims

  cache::mise() {
    mise activate zsh --shims > ${MISE_SHIMS_CACHE}
    zcompile ${MISE_SHIMS_CACHE}

    PATH="${MISE_SHIMS_DIR}:$PATH" mise activate zsh > ${MISE_ACTIVATE_CACHE}
    zcompile ${MISE_ACTIVATE_CACHE}
  }

  if [[ ! -f ${MISE_SHIMS_CACHE} || ! -f ${MISE_ACTIVATE_CACHE} ]]; then
    cache::mise
  fi

  source ${MISE_SHIMS_CACHE}
fi

cache::refresh_script_cache "${NI_ZSH_PLUGIN_SOURCE}" "${NI_ZSH_PLUGIN_CACHE}"
cache::refresh_script_cache "${PNPM_ZSH_COMPLETION_SOURCE}" "${PNPM_ZSH_COMPLETION_CACHE}"
cache::refresh_script_cache "${NPM_ZSH_COMPLETION_SOURCE}" "${NPM_ZSH_COMPLETION_CACHE}"

# pnpm
export PNPM_HOME=$HOME/Library/pnpm
path=($PNPM_HOME(N-/) $path)

# deno
path=(~/.deno/bin(N-/) $path)

# bun
path=(~/.bun/bin(N-/) $path)
path=(~/.cache/.bun/bin(N-/) $path)

if type bun &>/dev/null; then
  cache::bun_completion() {
    bun completions zsh > ${BUN_ZSH_COMPLETION_CACHE}
    zcompile ${BUN_ZSH_COMPLETION_CACHE}
  }

  if [[ ! -f ${BUN_ZSH_COMPLETION_CACHE} ]]; then
    cache::bun_completion
  fi
fi

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

# luarocks
path=(~/.luarocks/bin(N-/) $path)

# java
# export JAVA_HOME=$(/usr/libexec/java_home -v "14")

# llvm
# path=(/usr/local/opt/llvm/bin(N-/) $path)

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
path=(~/.local/bin(N-/) $path)

# Added by Alacritty
path=(/Applications/Alacritty.app/Contents/MacOS/(N-/) $path)

# Added by Antigravity
path=(~/.antigravity/antigravity/bin(N-/) $path)

# Added by Obsidian
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"

# vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
