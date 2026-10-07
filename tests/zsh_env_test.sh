#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
zsh_bin=$(command -v zsh)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/zsh-env-test.XXXXXX")
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/zdotdir" "$test_dir/project/bin" "$test_dir/project with space/bin"
ln -s "$repo_root/.zshenv" "$test_dir/zdotdir/.zshenv"
probe_bin="$test_dir/project/bin"
space_bin="$test_dir/project with space/bin"

cat > "$probe_bin/dotfiles-path-probe" <<'EOF'
#!/bin/sh
printf 'project environment\n'
EOF
chmod +x "$probe_bin/dotfiles-path-probe"

cat > "$test_dir/verify.zsh" <<'EOF'
[[ ${path[1]} == "$1" && ${path[2]} == "$2" ]] || {
  print -u2 -- "Inherited environment paths lost priority: $PATH"
  exit 1
}
[[ $(command -v dotfiles-path-probe) == "$1/dotfiles-path-probe" ]] || exit 1
[[ $(dotfiles-path-probe) == 'project environment' ]] || exit 1
typeset -a unique_path=("${(@u)path}")
[[ ${#unique_path} == ${#path} ]] || {
  print -u2 -- 'PATH contains duplicate entries'
  exit 1
}
for directory in "${path[@]}"; do
  [[ $directory == /* && ( $directory == / || $directory != */ ) ]] || exit 1
  [[ $directory != ${XDG_DATA_HOME}/mise/installs/* ]] || {
    print -u2 -- "Stale mise installation overrides project shims: $directory"
    exit 1
  }
  [[ $directory != "$HOME/.nix-profile/bin" &&
     $directory != "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/bin" ]] || exit 1
done
EOF

test_path=".:./bin:$probe_bin///:$HOME/.local/share/mise/installs/node/latest/bin::$HOME/.nix-profile/bin///:${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/bin:/usr/bin/:$space_bin///:$probe_bin:/bin:/"

for shell_mode in normal login; do
  shell_args=()
  [[ $shell_mode == login ]] && shell_args=(-l)
  env ZDOTDIR="$test_dir/zdotdir" PATH="$test_path" \
    "$zsh_bin" "${shell_args[@]}" "$test_dir/verify.zsh" "$probe_bin" "$space_bin"
  printf '%s shell preserves absolute environment PATH and excludes mise installs and Nix profiles\n' "$shell_mode"
done

env ZDOTDIR="$test_dir/zdotdir" PATH="$test_path" "$zsh_bin" -c \
  'exec "$1" "$2" "$3" "$4"' zsh \
  "$zsh_bin" "$test_dir/verify.zsh" "$probe_bin" "$space_bin"
printf 'nested shell preserves environment PATH\n'

env ZDOTDIR="$test_dir/zdotdir" PATH="$test_path" "$zsh_bin" -c '
  original_path=$PATH
  setopt mark_dirs
  source "$ZDOTDIR/.zshenv"
  [[ $PATH == "$original_path" && $options[markdirs] == on ]] || exit 1
  exec "$1" "$2" "$3" "$4"
' zsh "$zsh_bin" "$test_dir/verify.zsh" "$probe_bin" "$space_bin"
printf 'repeated initialization keeps PATH and mark_dirs stable\n'

if [[ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  env -u __ETC_PROFILE_NIX_SOURCED ZDOTDIR="$test_dir/zdotdir" PATH=/usr/bin:/bin \
    "$zsh_bin" -c '
      [[ $(command -v nix) == /nix/var/nix/profiles/default/bin/nix ]] || exit 1
      (( ${path[(Ie)$HOME/.nix-profile/bin]} == 0 )) || exit 1
      (( ${path[(Ie)${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/bin]} == 0 )) || exit 1
      nix_index=${path[(Ie)/nix/var/nix/profiles/default/bin]}
      if [[ -d $MISE_SHIMS_DIR ]]; then
        [[ $nix_index -gt ${path[(Ie)$MISE_SHIMS_DIR]} ]] || exit 1
      fi
      if [[ -d /opt/homebrew/bin ]]; then
        [[ $nix_index -lt ${path[(Ie)/opt/homebrew/bin]} ]] || exit 1
      fi
      PATH=/usr/bin:/bin "$1" -c '\''
        [[ $(command -v nix) == /nix/var/nix/profiles/default/bin/nix ]] || exit 1
        [[ $XDG_DATA_DIRS == "$1" && $NIX_PROFILES == "$2" ]] || exit 1
      '\'' zsh "$XDG_DATA_DIRS" "$NIX_PROFILES"
    ' zsh "$zsh_bin"
  printf 'Nix initializes once, preserves variables and stays behind mise shims\n'

  env -i HOME="$HOME" PATH=/usr/bin:/bin ZDOTDIR="$test_dir/zdotdir" \
    /bin/bash -l -c 'exec "$1" -c '\''
      [[ $(command -v nix) == /nix/var/nix/profiles/default/bin/nix ]] || exit 1
      (( ${path[(Ie)$HOME/.nix-profile/bin]} == 0 )) || exit 1
      (( ${path[(Ie)${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/bin]} == 0 )) || exit 1
    '\''' bash "$zsh_bin"
  printf 'bash login parent does not enable Nix user profile packages in zsh\n'
fi
