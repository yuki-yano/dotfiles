# zinit {{{
if [[ ! -d $ZPLG_HOME/bin ]]; then
  if whence git > /dev/null; then
    git clone --depth 10 https://github.com/zdharma-continuum/zinit.git $ZPLG_HOME/bin
  fi
fi

if [[ ! -d $ZPFX ]]; then
  mkdir -p $ZPFX/bin
  mkdir -p $ZPFX/man/man1
fi

if [[ ! -d $ZPLG_HOME/misc ]]; then
  mkdir -p $ZPLG_HOME/misc
fi

source $ZPLG_HOME/bin/zinit.zsh
MANPATH="${ZPFX}/man:${MANPATH}"
# }}}

# sync loading {{{
zinit ice depth=1
zinit light romkatv/powerlevel10k
zinit ice depth=1
zinit light zsh-users/zsh-autosuggestions
zinit ice lucid
zinit light woefe/git-prompt.zsh

# zinit ice lucid
# zinit light romkatv/zsh-prompt-benchmark

# fuzzy finder
zinit ice lucid from"gh-r" as"program" mv"fzf -> ${ZPFX}/bin/fzf"
zinit light junegunn/fzf

zinit ice lucid as"program"
zinit snippet 'https://github.com/junegunn/fzf/blob/master/bin/fzf-tmux'

zinit light yukiycino-dotfiles/zsh-show-buffer-stack

# zinit ice lucid
# zinit snippet ~/.config/tabtab/zsh/__tabtab.zsh

# }}}

# async loading {{{

# PROMPT
zinit ice lucid wait"!0" depth"1" atinit"zpcompinit; zpcdreplay" atload"set_fast_theme"
zinit light zdharma-continuum/fast-syntax-highlighting

# completion
zinit ice lucid wait"0" depth"1" blockf
zinit light zsh-users/zsh-completions

# man
zinit ice lucid wait"0" as"program" mv"fzf* -> ${ZPFX}/man/man1"
zinit snippet 'https://github.com/junegunn/fzf/blob/master/man/man1/fzf.1'

# Node
zinit ice lucid wait"0" as"null" src"ni.zsh" atload"compdef _ni ni"
zinit light azu/ni.zsh

# util

## fancy-ctrl-z
zinit ice lucid wait"0"
zinit snippet https://gist.githubusercontent.com/yuki-yano/f1f0d11db6d1d49180bca7e282599932/raw/394a57effdd6d033677a82437a20cd6d12d45a57/fancy-ctrl-z.zsh

## show-buffer-stack
zinit ice lucid wait"0"
zinit snippet https://gist.githubusercontent.com/yuki-yano/dc4684c65cf2ba0c2f1612b70d120a34/raw/7652e88d7dbb43ed3f3208f7ca023d1757f2d056/show-buffer-stack.zsh

# }}}

# zsh-autosuggestions {{{
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(accept-line)
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

# show-buffer-stack {{{
add-zsh-hook precmd check-buffer-stack
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
[[ -f ~/.safe-chain/scripts/init-posix.sh ]] && source ~/.safe-chain/scripts/init-posix.sh
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

if whence vivid > /dev/null; then
  export LS_COLORS="$(vivid generate ~/.config/vivid/themes/catppuccin.yml)"
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

# Prompt {{{
local grey='246'
local red='1'
local yellow='3'
local blue='4'
local magenta='5'
local cyan='6'
local white='7'

function prompt_anyenv() {
  local ruby_version python_version node_version

  if which rbenv > /dev/null 2>&1; then
    ruby_version="Ruby-$(rbenv version-name)"
  fi
  if which pyenv > /dev/null 2>&1; then
    if [[ -n "$VIRTUAL_ENV" ]]; then
      python_version="Python-venv"
    else
      python_version="Python-$(pyenv version-name)"
    fi
  fi
  if which nodenv > /dev/null 2>&1; then
    node_version="Node-$(nodenv version-name)"
  fi
  p10k segment -f white -t "[%{$MAGENTA%}${ruby_version}%{$DEFAULT%} %{$GREEN%}${python_version}%{$DEFAULT%} %{$BLUE%}${node_version}%{$DEFAULT%}]"
}

function prompt_venv() {
  local venv
  venv=""
  if [[ -n "$VIRTUAL_ENV" ]]; then
    venv="venv:$(basename $VIRTUAL_ENV)"
    p10k segment -f white -t "[%F{72}${venv}%f]"
  fi
}

function prompt_rebasing() {
  if [[ -d ".git/rebase-merge" ]] || [[ -d ".git/rebase-apply" ]]; then
    p10k segment -f red -e -t ' Rebasing '
  fi
}

function prompt_conflicting() {
  if [[ -f ".git/MERGE_HEAD" ]]; then
    p10k segment -f red -e -t ' Conflicting '
  fi
}

function prompt_show_buffer_stack() {
  p10k segment -f white -e -t '$COMMAND_BUFFER_STACK'
}

typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir
  vcs
  conflicting
  rebasing
  newline
  venv
  prompt_char
)

typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  show_buffer_stack
)

function p10k-on-pre-prompt() { p10k display '1'=show }
function p10k-on-post-prompt() { p10k display '1'=hide }

typeset -g POWERLEVEL9K_BACKGROUND=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=

typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=$white
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=$red
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='$'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='$'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='$'
typeset -g POWERLEVEL9K_DIR_FOREGROUND=$blue
typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='$(gitprompt)'

ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=" "
ZSH_THEME_GIT_PROMPT_SEPARATOR="|"
ZSH_THEME_GIT_PROMPT_DETACHED="%{$fg_bold[cyan]%}:"
ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[white]%} "
ZSH_THEME_GIT_PROMPT_UPSTREAM_PREFIX="%{$fg[magenta]%}->%{$fg[cyan]%}"
ZSH_THEME_GIT_PROMPT_UPSTREAM_SUFFIX=" "
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg_bold[cyan]%}↓ "
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[cyan]%}↑ "
ZSH_THEME_GIT_PROMPT_UNMERGED=" %{$fg[red]%}X:"
ZSH_THEME_GIT_PROMPT_STAGED=" %{$fg[green]%}M:"
ZSH_THEME_GIT_PROMPT_UNSTAGED=" %{$fg[red]%}M:"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$fg[red]%}?:"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg_bold[green]%}✔ "
ZSH_THEME_GIT_PROMPT_STASHED=" %{$fg[blue]%}Stash:"
ZSH_GIT_PROMPT_SHOW_UPSTREAM=full
ZSH_GIT_PROMPT_SHOW_STASH=1
ZSH_GIT_PROMPT_FORCE_BLANK=1
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
bindkey '^q' show-buffer-stack

bindkey "$terminfo[kcbt]" reverse-menu-complete

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

# Auto execute rehash when executing anyenv command
# add-zsh-hook preexec env_rehash
#
# function env_rehash() {
#   if   echo "$1" | grep rbenv  > /dev/null ; then
#     rbenv rehash
#   elif echo "$1" | grep pyenv  > /dev/null ; then
#     pyenv rehash
#   elif echo "$1" | grep nodenv > /dev/null ; then
#     nodenv rehash
#   fi
# }

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

  zle reset-prompt
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

# }}}

# zeno {{{
if [[ -d ~/repos/github.com/yuki-yano/zeno.zsh ]]; then
  zinit ice lucid blockf
  zinit light ~/repos/github.com/yuki-yano/zeno.zsh
else
  zinit ice lucid depth"1" blockf
  zinit light yuki-yano/zeno.zsh
fi

export ZENO_GIT_CAT="bat --color=always --plain --number"
export ZENO_ENABLE_FZF_TMUX=1
export ZENO_FZF_TMUX_OPTIONS="-p 50%,50%"
export ZENO_DISABLE_EXECUTE_CACHE_COMMAND=1
# export ZENO_DISABLE_SOCK=1

if [[ -n $ZENO_LOADED ]]; then
  bindkey ' '    zeno-auto-snippet
  bindkey '^m'   zeno-auto-snippet-and-accept-line
  bindkey '^xs'  zeno-insert-snippet
  bindkey '^x^s' zeno-insert-snippet
  bindkey '^i'   zeno-completion
  # Use atuin
  # bindkey '^r'   zeno-history-selection

  bindkey '^x '  zeno-insert-space
  bindkey '^x^m' accept-line
  bindkey '^x^z' zeno-toggle-auto-snippet

  bindkey '^r' zeno-smart-history-selection

  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(zeno-auto-snippet-and-accept-line)
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
