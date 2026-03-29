if [[ -z $IN_CAGE ]]; then
  export HOMEBREW_PREFIX=/opt/homebrew
  export HOMEBREW_CELLAR=/opt/homebrew/Cellar
  export HOMEBREW_REPOSITORY=/opt/homebrew
fi

typeset -r DOT_ZSH_CACHE_PROFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/profile"
typeset -r DOT_ZSH_NI_SOURCE="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/repos/github.com/azu/ni.zsh/ni.zsh"
typeset -r DOT_ZSH_NI_CACHE="${DOT_ZSH_CACHE_PROFILE}/ni.zsh"
typeset -r DOT_ZSH_PNPM_SOURCE="${XDG_CONFIG_HOME:-$HOME/.config}/tabtab/zsh/pnpm.zsh"
typeset -r DOT_ZSH_PNPM_CACHE="${DOT_ZSH_CACHE_PROFILE}/pnpm-completion.zsh"
typeset -r DOT_ZSH_NPM_SOURCE="/opt/homebrew/share/zsh/site-functions/_npm"
typeset -r DOT_ZSH_NPM_CACHE="${DOT_ZSH_CACHE_PROFILE}/npm-completion.zsh"
typeset -r DOT_ZSH_BUN_CACHE="${DOT_ZSH_CACHE_PROFILE}/bun-completion.zsh"
typeset -r DOT_ZSH_MISE_ACTIVATE_CACHE="${DOT_ZSH_CACHE_PROFILE}/mise.zsh"
typeset -r DOT_ZSH_MISE_COMPLETION_CACHE="${DOT_ZSH_CACHE_PROFILE}/mise-completion.zsh"

dot_zsh_cache_needs_refresh() {
  local cache_file=$1
  shift

  [[ ! -f $cache_file ]] && return 0

  local dep
  for dep in "$@"; do
    [[ -n $dep && -e $dep && $dep -nt $cache_file ]] && return 0
  done

  return 1
}

dot_zsh_refresh_script_cache() {
  local source_file=$1
  local cache_file=$2

  [[ -r $source_file ]] || return 0

  if dot_zsh_cache_needs_refresh "$cache_file" "$source_file"; then
    local tmp_file
    tmp_file=$(mktemp "${cache_file}.XXXXXX") || return 1
    cp "$source_file" "$tmp_file" || {
      rm -f "$tmp_file"
      return 1
    }
    mv "$tmp_file" "$cache_file"
    zcompile "$cache_file"
  fi
}

dot_zsh_refresh_command_cache() {
  local cache_file=$1
  shift

  local -a deps=()
  while [[ $# -gt 0 && $1 != -- ]]; do
    deps+=("$1")
    shift
  done

  [[ $# -gt 0 ]] && shift

  if dot_zsh_cache_needs_refresh "$cache_file" "${deps[@]}"; then
    local tmp_file
    tmp_file=$(mktemp "${cache_file}.XXXXXX") || return 1
    "$@" >| "$tmp_file" || {
      rm -f "$tmp_file"
      return 1
    }
    mv "$tmp_file" "$cache_file"
    zcompile "$cache_file"
  fi
}

mkdir -p "$DOT_ZSH_CACHE_PROFILE"

dot_zsh_refresh_script_cache "$DOT_ZSH_NI_SOURCE" "$DOT_ZSH_NI_CACHE"
dot_zsh_refresh_script_cache "$DOT_ZSH_PNPM_SOURCE" "$DOT_ZSH_PNPM_CACHE"
dot_zsh_refresh_script_cache "$DOT_ZSH_NPM_SOURCE" "$DOT_ZSH_NPM_CACHE"

if whence bun >/dev/null; then
  dot_zsh_refresh_command_cache \
    "$DOT_ZSH_BUN_CACHE" \
    "${commands[bun]}" \
    -- \
    bun completions zsh
fi

if whence mise >/dev/null; then
  typeset -r DOT_ZSH_MISE_BIN="${commands[mise]}"
  typeset -r DOT_ZSH_MISE_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml"
  typeset -r DOT_ZSH_MISE_SHIMS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims"

  dot_zsh_refresh_command_cache \
    "$DOT_ZSH_MISE_ACTIVATE_CACHE" \
    "$HOME/.zshenv" \
    "$HOME/.zprofile" \
    "$DOT_ZSH_MISE_BIN" \
    "$DOT_ZSH_MISE_CONFIG_FILE" \
    -- \
    env PATH="${DOT_ZSH_MISE_SHIMS_DIR}:$PATH" mise activate zsh

  dot_zsh_refresh_command_cache \
    "$DOT_ZSH_MISE_COMPLETION_CACHE" \
    "$HOME/.zprofile" \
    "$DOT_ZSH_MISE_BIN" \
    -- \
    mise completion zsh
fi
