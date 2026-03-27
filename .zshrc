# sheldon {{{
SHELDON_CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.cache}/sheldon
SHELDON_PRE_CACHE=${SHELDON_CACHE_DIR}/pre.zsh
SHELDON_POST_CACHE=${SHELDON_CACHE_DIR}/post.zsh
NI_ZSH_PLUGIN=${NI_ZSH_PLUGIN_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/profile/ni.zsh}

dot_zsh_zcompile_if_stale() {
  local script_path=$1

  if [[ -r $script_path ]] && [[ ! -r ${script_path}.zwc || $script_path -nt ${script_path}.zwc ]]; then
    zcompile "$script_path"
  fi
}

dot_zsh_zcompile_if_stale "$SHELDON_PRE_CACHE"
dot_zsh_zcompile_if_stale "$SHELDON_POST_CACHE"

[[ -r $SHELDON_PRE_CACHE ]] && source "$SHELDON_PRE_CACHE"

[[ -r $SHELDON_POST_CACHE ]] && source "$SHELDON_POST_CACHE"

dot_zsh_load_completion_scripts() {
  [[ -r $NI_ZSH_PLUGIN ]] && source "$NI_ZSH_PLUGIN"
  [[ -r ${PNPM_ZSH_COMPLETION_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/profile/pnpm-completion.zsh} ]] && source "${PNPM_ZSH_COMPLETION_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/profile/pnpm-completion.zsh}"
  [[ -r ${NPM_ZSH_COMPLETION_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/profile/npm-completion.zsh} ]] && source "${NPM_ZSH_COMPLETION_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/profile/npm-completion.zsh}"
  [[ -r ${BUN_ZSH_COMPLETION_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/profile/bun-completion.zsh} ]] && source "${BUN_ZSH_COMPLETION_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/profile/bun-completion.zsh}"
  [[ -r ${MISE_ZSH_COMPLETION_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/profile/mise-completion.zsh} ]] && source "${MISE_ZSH_COMPLETION_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/profile/mise-completion.zsh}"
}

if (( $+functions[zsh-defer] )); then
  zsh-defer -c '
    autoload -Uz compinit
    ZSH_COMPDUMP=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}
    mkdir -p ${ZSH_COMPDUMP:h}
    if [[ -s $ZSH_COMPDUMP ]]; then
      compinit -C -d "$ZSH_COMPDUMP"
    else
      compinit -d "$ZSH_COMPDUMP"
    fi
    (( $+functions[compdef] )) && [[ -n ${ZENO_ROOT-} ]] && compdef _zeno zeno zeno-history-client zeno-server
    dot_zsh_load_completion_scripts
  '
else
  autoload -Uz compinit
  ZSH_COMPDUMP=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}
  mkdir -p ${ZSH_COMPDUMP:h}
  if [[ -s $ZSH_COMPDUMP ]]; then
    compinit -C -d "$ZSH_COMPDUMP"
  else
    compinit -d "$ZSH_COMPDUMP"
  fi
  (( $+functions[compdef] )) && [[ -n ${ZENO_ROOT-} ]] && compdef _zeno zeno zeno-history-client zeno-server
  dot_zsh_load_completion_scripts
fi
# }}}

# mise {{{
if [[ -r ${MISE_ACTIVATE_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/profile/mise.zsh} ]]; then
  if (( $+functions[zsh-defer] )); then
    zsh-defer source "${MISE_ACTIVATE_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/profile/mise.zsh}"
  else
    source "${MISE_ACTIVATE_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh/profile/mise.zsh}"
  fi
fi
# }}}

# zsh-autosuggestions {{{
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(accept-line zeno-auto-snippet-and-accept-line)
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(dot-prompt-accept-line-or-restore-buffer-stack)
# }}}

# fast-syntax-highlighting {{{
function set_fast_theme() {
  FAST_HIGHLIGHT_STYLES[alias]='fg=blue'
  FAST_HIGHLIGHT_STYLES[suffix-alias]='fg=blue'
  FAST_HIGHLIGHT_STYLES[builtin]='fg=blue'
  FAST_HIGHLIGHT_STYLES[function]='fg=blue'
  FAST_HIGHLIGHT_STYLES[command]='fg=blue'
  FAST_HIGHLIGHT_STYLES[precommand]='fg=blue,underline'
  FAST_HIGHLIGHT_STYLES[hashed-command]='fg=blue'
  FAST_HIGHLIGHT_STYLES[path]='fg=green'
  FAST_HIGHLIGHT_STYLES[globbing]='fg=green,bold'
  FAST_HIGHLIGHT_STYLES[history-expansion]='fg=green,bold'
}
# }}}

# alias {{{

# eza {{{
if whence eza > /dev/null; then
  alias ls="eza"
  alias ll="eza -lh  --git --time-style long-iso"
  alias la="eza -alh --git --time-style long-iso"
elif whence gls > /dev/null; then
  alias ls='gls --color=auto'
  alias ll='ls -lh'
  alias la='ls -alh'
else
  alias ll='ls -lh'
  alias la='ls -alh'
fi
# }}}

# bat {{{
if whence bat > /dev/null; then
  export BAT_THEME='Catppuccin-mocha'
  alias bat='bat --color=always --style=plain'
fi
# }}}

# sed {{{
# if whence gsed > /dev/null; then
#   alias sed='gsed'
# fi
# }}}

# find {{{
if whence gfind > /dev/null; then
  alias find='gfind'
fi
# }}}

# du {{{
if whence dust > /dev/null; then
  alias du=dust
fi
# }}}

# yq {{{
if whence gojq > /dev/null; then
  alias yq='gojq --yaml-input --yaml-output'
fi
# }}}

# safe-chain {{{
# [[ -f ~/.safe-chain/scripts/init-posix.sh ]] && source ~/.safe-chain/scripts/init-posix.sh
# }}}

# }}}

# }}}

# autoload {{{

autoload -Uz add-zsh-hook
autoload -Uz colors; colors
autoload -Uz edit-command-line
autoload -Uz history-search-end
autoload -Uz smart-insert-last-word
autoload -Uz terminfo

# }}}

# Color Definition {{{

DEFAULT="${reset_color}"
RED="${fg[red]}"
GREEN="${fg[green]}"
YELLOW="${fg[yellow]}"
BLUE="${fg[blue]}"
MAGENTA="${fg[magenta]}"
CYAN="${fg[cyan]}"
WHITE="${fg[white]}"

# }}}

# Basic {{{

# default settings
setopt always_last_prompt
setopt append_history
setopt auto_list
setopt auto_menu
setopt auto_param_keys
setopt auto_param_slash
setopt auto_pushd
setopt brace_ccl
setopt complete_aliases
setopt complete_in_word
setopt extended_glob
setopt extended_history
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_verify
setopt interactive_comments
setopt list_types
setopt long_list_jobs
setopt magic_equal_subst
setopt mark_dirs
setopt menu_complete
setopt multios
setopt no_beep
setopt no_flow_control
setopt no_list_beep
setopt no_no_match
setopt notify
setopt numeric_glob_sort
setopt print_eight_bit
setopt prompt_subst
setopt pushd_ignore_dups
setopt share_history
setopt transient_rprompt

if whence vivid >/dev/null; then
  local theme=$HOME/.config/vivid/themes/catppuccin.yml
  local cache=${XDG_CACHE_HOME:-$HOME/.cache}/vivid/catppuccin.ls_colors
  if [[ ! -s $cache || $cache -ot $theme ]]; then
    mkdir -p ${cache:h}
    vivid generate "$theme" >"$cache"
  fi
  export LS_COLORS="$(<"$cache")"
fi

# history
HISTFILE=${HOME}/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# C-w target chars
WORDCHARS="*?_-[]~=&!#$%^(){}<>"

# smart-insert-last-word
zstyle :insert-last-word match '*([^[:space:]][[:alpha:]/\\]|[[:alpha:]/\\][^[:space:]])*'
zle -N insert-last-word smart-insert-last-word

# Show details automatically
REPORTTIME=10

# }}}

# Prompt {{{
: ${DOT_PROMPT_ENABLE_TRANSIENT:=1}

for prompt_file in \
  "$HOME/.zsh/prompt/vendor/async.zsh" \
  "$HOME/.zsh/prompt/base.zsh" \
  "$HOME/.zsh/prompt/git.zsh" \
  "$HOME/.zsh/prompt/async.zsh" \
  "$HOME/.zsh/prompt/init.zsh"; do
  [[ -r $prompt_file ]] && source "$prompt_file"
done
unset prompt_file

# }}}

# Completion {{{

LISTMAX=1000

# Basic Configuration
zstyle ':completion:*' verbose yes
zstyle ':completion:*' menu select=2
zstyle ':completion:*' group-name ''
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list
zstyle ':completion:*' matcher-list  'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' auto-description 'Specify: %d'
zstyle ':completion:*' select-prompt %SScrolling Active: Current selection at %p%s
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s

zstyle ':completion:*:options'         description 'yes'
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Highlight
zstyle ':completion:*'              list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:messages'     format "$YELLOW" '%d' "$DEFAULT"
zstyle ':completion:*:warnings'     format "$RED" 'No matches for:' "$YELLOW" '%d' "$DEFAULT"
zstyle ':completion:*:descriptions' format "$YELLOW" 'Completing %B%d%b' "$DEFAULT"
zstyle ':completion:*:corrections'  format "$YELLOW" '%B%d% ' "$RED" '(Errors: %e)%b' "$DEFAULT"

# Separator
zstyle ':completion:*'         list-separator ' ==> '
zstyle ':completion:*:manuals' separate-sections true

# Cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

# Others
zstyle ':completion:*' remote-access false
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# }}}

# fzf {{{

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS='--reverse --no-separator --pointer=">" --marker=">"'
export FZF_COMPLETION_TRIGGER=';'

# }}}

# atuin {{{
# eval "$(atuin init zsh)"
# }}}

# tmux {{{

function _left-pane() {
  tmux run-shell 'tmux-smart-switch-pane left'
}
zle -N left-pane _left-pane

function _down-pane() {
  tmux run-shell 'tmux-smart-switch-pane down'
}
zle -N down-pane _down-pane

function _up-pane() {
  tmux run-shell 'tmux-smart-switch-pane up'
}
zle -N up-pane _up-pane

function _right-pane() {
  tmux run-shell 'tmux-smart-switch-pane right'
}
zle -N right-pane _right-pane

function _backspace-or-left-pane() {
  if [[ $#BUFFER -gt 0 ]]; then
    zle backward-delete-char
  elif [[ ! -z ${TMUX} ]]; then
    zle left-pane
  fi
}
zle -N backspace-or-left-pane _backspace-or-left-pane

function _kill-line-or-up-pane() {
  if [[ $#BUFFER -gt 0 ]]; then
    zle kill-line
  elif [[ ! -z ${TMUX} ]]; then
    zle up-pane
  fi
}
zle -N kill-line-or-up-pane _kill-line-or-up-pane

function _accept-line-or-down-pane() {
  if [[ $#BUFFER -gt 0 ]]; then
    zle accept-line
  elif [[ ! -z ${TMUX} ]]; then
    zle down-pane
  fi
}
zle -N accept-line-or-down-pane _accept-line-or-down-pane

# }}}

# Bindkey {{{

bindkey -e

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end  history-search-end

zstyle :zle:edit-command-line editor nvim --cmd 'let g:is_edit_command_line = v:true' -c 'startinsert'

# My ZLE bind
bindkey '^]'  insert-last-word
bindkey "^[u" redo
bindkey '^[f' forward-word
bindkey "^[b" backward-word

# Add tmux bind
bindkey '^h' backspace-or-left-pane
bindkey '^j' accept-line-or-down-pane

# common bind
bindkey '^a' beginning-of-line
bindkey '^b' backward-char
bindkey '^d' delete-char-or-list
bindkey '^e' end-of-line
bindkey '^f' forward-char
bindkey '^g' send-break
bindkey '^k' kill-line-or-up-pane
bindkey '^w' backward-kill-word
bindkey '^p' history-beginning-search-backward
bindkey '^n' history-beginning-search-forward
bindkey '^y' yank

[[ -n $terminfo[kcbt] ]] && bindkey "$terminfo[kcbt]" reverse-menu-complete

# Completion bind
zmodload zsh/complist
bindkey -M menuselect '^g' .send-break
bindkey -M menuselect '^i' forward-char
bindkey -M menuselect '^j' .accept-line
bindkey -M menuselect '^k' accept-and-infer-next-history
bindkey -M menuselect '^n' down-line-or-history
bindkey -M menuselect '^p' up-line-or-history
bindkey -M menuselect '^h' undo

# Command Line Edit
zle -N edit-command-line
bindkey '^xe'  edit-command-line
bindkey '^x^e' edit-command-line

# }}}

# Misc {{{

 if [[ -f $HOME/dotfiles/bin/ghq-project-selector.zsh ]]; then
   source $HOME/dotfiles/bin/ghq-project-selector.zsh
 fi

# Automatically save the current git state to reflog
add-zsh-hook preexec git_auto_save

function git_auto_save() {
  # Get git root directory
  local git_root
  git_root=$(git rev-parse --show-toplevel 2>/dev/null)

  if [[ -n "$git_root" ]] \
    && [[ -f "$git_root/.git/auto-save" ]] \
    && [[ $(find "$git_root/.git/auto-save" -mmin -$((60)) | wc -l) -eq 0 ]]; then
    touch "$git_root/.git/auto-save" &&
      GIT_QUICK_SAVE_LABEL="Git auto save" git-quick-save
  fi
}

# Select from git reflog using fzf and insert at cursor
function _fzf-git-reflog-widget() {
  local git_root
  git_root=$(git rev-parse --show-toplevel 2>/dev/null)

  if [[ -z "$git_root" ]]; then
    zle -M "Not a Git repository."
    return
  fi

  local selected
  selected=$(git reflog --pretty=format:'%h %gD: %gs' | \
    grep -E '(Git quick save:|Git auto save:)' | \
    fzf-tmux -p 70%,70% --reverse --ansi --exact --no-sort \
        --preview 'echo {} | cut -d" " -f1 | xargs git show --color=always' \
        --preview-window=right:70% \
        --bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up')

  if [[ -n "$selected" ]]; then
    # Extract commit hash
    local hash=$(echo "$selected" | awk '{print $1}')
    LBUFFER+="$hash"
  fi

  zle -R
}
zle -N fzf-git-reflog-widget _fzf-git-reflog-widget
bindkey '^gr' fzf-git-reflog-widget
bindkey '^g^r' fzf-git-reflog-widget

# Auto rename tmux session when entering git repository
function tmux_auto_rename_hook() {
  if [[ -n "$TMUX" ]]; then
    # Get current session name
    local session_name=$(tmux display-message -p '#S')

    # Check if session name is numeric
    if [[ $session_name =~ ^[0-9]+$ ]]; then
      # Check if we're in a git repository
      if git_root=$(git rev-parse --show-toplevel 2>/dev/null); then
        # Extract repository name from path
        local repository=$(basename "$git_root")

        # Convert dots to hyphens
        local new_session_name=${repository//./-}

        # Rename the session
        tmux rename-session "$new_session_name" 2>/dev/null || true
      fi
    fi
  fi
}
add-zsh-hook chpwd tmux_auto_rename_hook

# show-suspend-jobs {{{
zmodload -i zsh/parameter

: ${SUSP_JOBS_MAX:=3}
: ${SUSP_JOBS_ICON:=$'\u23F8'}
: ${SUSP_JOBS_COLOR:='%F{yellow}'}

typeset -g SUSP_JOBS_RPROMPT=""

function __susp_jobs_update_rprompt() {
  local -a ids shown
  local k state txt

  for k in ${(k)jobstates}; do
    state=${jobstates[$k]}
    [[ ${state%%:*} == suspended ]] && ids+="$k"
  done

  if (( ${#ids} )); then
    local i
    for i in ${ids}; do
      txt=${jobtexts[$i]}
      shown+="${i}:${${txt%% *}:-${txt}}"
      (( ${#shown} >= SUSP_JOBS_MAX )) && break
    done
    local rest=$(( ${#ids} - ${#shown} ))
    local body="${(j: :)shown}"
    (( rest > 0 )) && body+=" +${rest}"
    typeset -g SUSP_JOBS_RPROMPT="${SUSP_JOBS_COLOR}${SUSP_JOBS_ICON} ${body}%f"
  else
    typeset -g SUSP_JOBS_RPROMPT=""
  fi
}
# }}}

# show-buffer-stack {{{
typeset -g COMMAND_BUFFER_STACK=""
typeset -ga buffer_stack_arr=()
typeset -ga buffer_stack_value_arr=()
typeset -g DOT_BUFFER_STACK_RESTORE_PENDING=0
typeset -g DOT_BUFFER_STACK_RESTORE_BUFFER=""

function make-p-buffer-stack() {
  if (( ${#buffer_stack_arr} == 0 )); then
    typeset -g COMMAND_BUFFER_STACK=""
    return
  fi

  typeset -g COMMAND_BUFFER_STACK="%F{cyan}<Stack:${buffer_stack_arr}>%f"
}

function dot-buffer-stack-push() {
  local buffer_value=$1
  local cmd_str_len=${#buffer_value}
  local preview

  (( cmd_str_len > 10 )) && cmd_str_len=10
  preview="[${buffer_value[1,${cmd_str_len}]}]"

  buffer_stack_value_arr=("$buffer_value" ${buffer_stack_value_arr[@]})
  buffer_stack_arr=("$preview" ${buffer_stack_arr[@]})
  make-p-buffer-stack
}

function dot-buffer-stack-shift() {
  if (( ${#buffer_stack_value_arr} == 0 )); then
    return 1
  fi

  REPLY=$buffer_stack_value_arr[1]
  shift buffer_stack_value_arr
  shift buffer_stack_arr
  make-p-buffer-stack
  return 0
}

function dot-buffer-stack-pop() {
  dot-buffer-stack-shift || return 1

  BUFFER=$REPLY
  CURSOR=${#BUFFER}
  return 0
}

function show-buffer-stack() {
  [[ -z $BUFFER ]] && return 0

  dot-buffer-stack-push "$BUFFER"
  BUFFER=""
  CURSOR=0
  if (( $+functions[dot_prompt_refresh_right] )); then
    dot_prompt_refresh_right
  fi
  zle -R
}
zle -N show-buffer-stack

function dot-prompt-accept-line-or-restore-buffer-stack() {
  if (( $+functions[zeno-auto-snippet-and-accept-line] )); then
    zeno-auto-snippet-and-accept-line
  else
    zle accept-line
  fi
}
zle -N dot-prompt-accept-line-or-restore-buffer-stack

bindkey '^q' show-buffer-stack
# }}}

# fancy-ctrl-z {{{
function fancy-ctrl-z() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER=" fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z
# }}}

# }}}

# zeno {{{
if (( $+functions[zeno-register-lazy-widgets] )); then
  zeno-register-lazy-widgets \
    zeno-auto-snippet \
    zeno-auto-snippet-and-accept-line \
    zeno-insert-snippet \
    zeno-preprompt-snippet \
    zeno-completion \
    zeno-snippet-next-placeholder \
    zeno-insert-space \
    zeno-toggle-auto-snippet \
    zeno-smart-history-selection

  if (( $+functions[zsh-defer] )); then
    zsh-defer zeno-preload
  fi

  bindkey ' '    zeno-auto-snippet
  bindkey '^m'   dot-prompt-accept-line-or-restore-buffer-stack
  bindkey '^xs'  zeno-insert-snippet
  bindkey '^x^s' zeno-insert-snippet
  bindkey '^xp'  zeno-preprompt-snippet
  bindkey '^x^p' zeno-preprompt-snippet
  bindkey '^i'   zeno-completion
  bindkey '\ef'  zeno-snippet-next-placeholder

  bindkey '^x '  zeno-insert-space
  bindkey '^x^m' accept-line
  bindkey '^x^z' zeno-toggle-auto-snippet

  bindkey '^r'   zeno-smart-history-selection

  function by() {
    zeno-ensure-loaded || return 1
    zeno-preprompt "$@"
  }

  function bys() {
    zeno-ensure-loaded || return 1
    zeno-preprompt-snippet "$@"
  }
fi

if (( ! $+functions[zeno-auto-snippet-and-accept-line] )); then
  bindkey '^m' dot-prompt-accept-line-or-restore-buffer-stack
fi

# }}}

# Profile {{{

if whence zprof > /dev/null ;then
  zprof | less
fi

# }}}

# zcompile {{{

# .zshrc
if [[ ! -f ~/.zshrc.zwc ]] || [[ "$(readlink ~/.zshrc)" -nt ~/.zshrc.zwc ]]; then
  zcompile ~/.zshrc
fi

# }}}

# Load local {{{

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# }}}

# vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
