#!/usr/bin/env zsh

# ghq project selector with optional tmux integration
# Can be sourced to use as a shell function

function ghq-project-selector() {
  local from_run_shell=0
  if [[ "$1" == "--from-run-shell" ]]; then
    from_run_shell=1
    shift
  fi

  if (( from_run_shell )); then
    if ! command -v tmux >/dev/null 2>&1; then
      printf '%s\n' "ghq-project-selector: --from-run-shell requires tmux" >&2
      return 1
    fi

    local rerun_args=${(j: :)${(@q)@}}
    if tmux display-popup -E "zsh -ic 'ghq-project-selector ${rerun_args}'" 2>/dev/null; then
      return 0
    fi

    tmux new-window -c "${PWD}" "zsh -ic 'ghq-project-selector ${rerun_args}; exec zsh'" && return 0
    return 1
  fi

  if ! command -v fzf >/dev/null 2>&1; then
    printf '%s\n' "ghq-project-selector: fzf not found" >&2
    return 1
  fi

  local tmux_available=0
  if command -v tmux >/dev/null 2>&1; then
    tmux_available=1
  fi

  local has_bat=0
  if command -v bat >/dev/null 2>&1; then
    has_bat=1
  fi

  local fzf_cmd preview_cmd
  if [[ -n "$TMUX" ]] && [[ "$tmux_available" -eq 1 ]] && command -v fzf-tmux >/dev/null 2>&1; then
    fzf_cmd=(fzf-tmux -p 50%,50%)
  else
    fzf_cmd=(fzf)
  fi

  if [[ "$has_bat" -eq 1 ]]; then
    preview_cmd='bat $(eval echo {})/README.md'
  else
    preview_cmd='cat $(eval echo {})/README.md'
  fi

  local dir
  dir=$(ghq list -p | sed -e "s|${HOME}|~|" | "${fzf_cmd[@]}" --prompt="Project> " --preview="$preview_cmd" --bind ctrl-d:preview-page-down,ctrl-u:preview-page-up --no-separator) || return 0

  if [[ -z "$dir" ]]; then
    return 0
  fi

  local project_dir=$dir
  case "$project_dir" in
    "~"*)
      project_dir=$HOME${project_dir#\~}
      ;;
  esac

  if [[ -n "$TMUX" ]] && [[ "$tmux_available" -eq 1 ]]; then
    local repository=${project_dir##*/}
    local session=$(printf '%s' "$repository" | tr '.' '-')
    local current_session=$(tmux list-sessions 2>/dev/null | grep 'attached' | cut -d":" -f1)

    case "$current_session" in
      ''|*[!0-9]*)
        if ! tmux list-sessions 2>/dev/null | cut -d":" -f1 | grep -F -x -q "$session"; then
          tmux new-session -d -c "$project_dir" -s "$session"
        fi
        tmux switch-client -t "$session"
        ;;
      *)
        cd "$project_dir" || return 1
        tmux rename-session "$session"
        ;;
    esac
  else
    # Outside tmux: cd to the selected directory
    cd "$project_dir" || return 1
  fi
}

# If executed directly (not sourced), run the function
if [[ "${ZSH_EVAL_CONTEXT}" == "toplevel" ]]; then
  ghq-project-selector "$@"
fi
