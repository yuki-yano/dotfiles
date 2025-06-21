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

zinit ice lucid wait"0" depth"1" blockf
zinit light yuki-yano/zsh-completions-anyenv

# zinit ice lucid wait"0" as"completion"
# zinit snippet OMZ::plugins/docker/_docker

# zinit ice lucid wait"0" as"completion"
# zinit snippet OMZ::plugins/docker-compose/_docker-compose

# git
# zinit ice lucid wait"0" as"program" pick"$ZPFX/bin/git-*" src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX"
# zinit light tj/git-extras
zinit ice lucid wait"0" depth"1" as"program"
zinit light yuki-yano/zsh-git-sync

zinit ice lucid wait"0" depth"1" as"program" src"tms.plugin.zsh" pick"tms"
zinit light yuki-yano/tms

zinit ice lucid wait"0" depth"1" as"program" src"tmk.plugin.zsh" pick"tmk"
zinit light yuki-yano/tmk

# man
zinit ice lucid wait"0" as"program" mv"fzf* -> ${ZPFX}/man/man1"
zinit snippet 'https://github.com/junegunn/fzf/blob/master/man/man1/fzf.1'

# Node
zinit ice lucid wait"0" as"null" src"ni.zsh" atload"compdef _ni ni"
zinit light azu/ni.zsh
# zinit ice wait"!0" \
#   silent \
#   atload'compdef _ni ni' \
#   id-as"local/ni" \
#   link"local" \
#   src"${HOME}/repos/github.com/yuki-yano/ni.zsh/ni.zsh"
# zinit light _local/ni

# util
zinit ice lucid wait"0" depth"1"
zinit light yukiycino-dotfiles/fancy-ctrl-z

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
  export BAT_THEME='gruvbox-dark'
  alias bat='bat --color=always --style=plain'
fi
# }}}

# sed {{{
if whence gsed > /dev/null; then
  alias sed='gsed'
fi
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

# Project
function f() {
  local project dir repository session current_session
  dir=$(ghq list -p | sed -e "s|${HOME}|~|" | fzf-tmux -p 70%,70% --prompt='Project> ' --preview "bat \$(eval echo {})/README.md" --bind ctrl-d:preview-page-down,ctrl-u:preview-page-up --no-separator)

  if [[ $dir == "" ]]; then
    return 1
  fi

  if [[ ! -z ${TMUX} ]]; then
    repository=${dir##*/}
    session=${repository//./-}
    current_session=$(tmux list-sessions | grep 'attached' | cut -d":" -f1)

    if [[ $current_session =~ ^[0-9]+$ ]]; then
      eval cd "${dir}"
      tmux rename-session $session
    else
      tmux list-sessions | cut -d":" -f1 | grep -e "^${session}\$" > /dev/null
      if [[ $? != 0 ]]; then
        tmux new-session -d -c $(eval echo "${dir}") -s $session
      fi
      tmux switch-client -t $session
    fi
  else
    eval cd "${dir}"
  fi
}

# }}}

# atuin {{{
eval "$(atuin init zsh)"
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
  tmux run-shell 'tmux-smart-pane-switch left'
}
zle -N left-pane _left-pane

function _down-pane() {
  tmux run-shell 'tmux-smart-pane-switch down'
}
zle -N down-pane _down-pane

function _up-pane() {
  tmux run-shell 'tmux-smart-pane-switch up'
}
zle -N up-pane _up-pane

function _right-pane() {
  tmux run-shell 'tmux-smart-pane-switch right'
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

# My ZLE bind
bindkey '^]'   insert-last-word
bindkey "^[u"  redo
bindkey '^[f'  forward-word
bindkey "^[b"  backward-word

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

# Git quick save
function c() {
  local msg=""
  if [ $# -gt 0 ]; then
    msg=" - $*"
  fi

  if [[ -d .git ]]; then
    if [[ ! -f ".git/MERGE_HEAD" ]] \
      && [[ $(git --no-pager diff --cached | wc -l) -eq 0 ]] \
      && [[ ! -f .git/index.lock ]] \
      && [[ ! -d .git/rebase-merge ]] \
      && [[ ! -d .git/rebase-apply ]]; then

      git add --all \
        && git commit --no-verify --message "Git save: $(date -R)$msg" >/dev/null \
        && git reset HEAD^ >/dev/null

      echo "Git quick save!$msg"
    fi
  else
    echo "Not a Git repository."
  fi
}

# Automatically save the current git state to reflog
add-zsh-hook preexec git_auto_save

function git_auto_save() {
  if [[ -d .git ]] && [[ -f .git/auto-save ]] && [[ $(find .git/auto-save -mmin -$((60)) | wc -l) -eq 0 ]]; then
    if [[ ! -f ".git/MERGE_HEAD" ]] && [[ $(git --no-pager diff --cached | wc -l) -eq 0 ]] && [[ ! -f .git/index.lock ]] && [[ ! -d .git/rebase-merge ]] && [[ ! -d .git/rebase-apply ]]; then
      touch .git/auto-save && git add --all && git commit --no-verify --message "Git auto save: $(date -R)" >/dev/null && git reset HEAD^ >/dev/null
      echo "Git auto save!"
    fi
  fi
}

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

# zinit
# if [[ ! -f ~/.zinit/bin/zinit.zsh.zwc ]] || [[ ~/.zinit/bin/zinit.zsh -nt ~/.zinit/bin/zinit.zsh.zwc ]]; then
#   zcompile ~/.zinit/bin/zinit.zsh
# fi

# }}}

# Load local {{{

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# }}}

# vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
