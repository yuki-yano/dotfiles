# zplugin {{{

if [[ ! -d $ZPLG_HOME ]]; then
  if whence git > /dev/null; then
    git clone --depth 10 https://github.com/zdharma/zplugin.git $ZPLG_HOME/bin
  fi
fi

if [[ ! -d $ZPFX ]]; then
  mkdir -p $ZPFX/bin
fi

if [[ ! -d $ZPLG_HOME/misc ]]; then
  mkdir -p $ZPLG_HOME/misc
fi

source $ZPLG_HOME/bin/zplugin.zsh

# sync loading {{{
zplugin light b4b4r07/zsh-vimode-visual
zplugin light yukiycino-dotfiles/zsh-abbreviations
zplugin light yukiycino-dotfiles/zsh-extra-abbrev
zplugin light yukiycino-dotfiles/zsh-show-buffer-stack

zplugin ice from"gh-r" as"program" bpick"*darwin*" mv"*darwin*/ccat -> ${ZPFX}/bin/ccat"
zplugin light jingweno/ccat

zplugin ice from"gh-r" as"program" bpick"*macos*" mv"exa-macos-x86_64 -> ${ZPFX}/bin/exa"
zplugin light ogham/exa

zplugin ice from"gh-r" as"program" bpick"*apple-darwin*" mv"ripgrep*/rg -> ${ZPFX}/bin/rg"
zplugin light BurntSushi/ripgrep

zplugin ice as"program" depth"1" atclone'./build.sh && mv ag ${ZPFX}/bin/ag' atpull'%atclone'
zplugin light ggreer/the_silver_searcher

zplugin ice as"program" depth"1" atclone'perl Makefile.PL; make' atpull'%atclone' pick"tmuximum"
zplugin light beyondgrep/ack2

zplugin ice from"gh-r" as"program" bpick"*darwin_amd*" mv"*darwin*/ghq -> ${ZPFX}/bin/ghq"
zplugin light motemen/ghq

zplugin ice as"program" depth"1" make"prefix=$ZPFX install" atpull'%atclone'
zplugin light jonas/tig

zplugin ice from"gh-r" as"program" bpick"*darwin*" mv"*darwin*/bin/hub -> ${ZPFX}/bin/hub"
zplugin light github/hub

zplugin ice from"gh-r" as"program" bpick"*osx*" mv"jq-osx-amd64 -> ${ZPFX}/bin/jq"
zplugin light stedolan/jq

zplugin ice from"gh-r" as"program" bpick"*darwin-amd64*" mv"gron -> ${ZPFX}/bin/gron"
zplugin light tomnomnom/gron
# }}}

# async loading {{{

# PROMPT
zplugin ice lucid wait"!0" depth"1" atinit"zpcompinit; zpcdreplay" atload"set_fast_theme"
zplugin light zdharma/fast-syntax-highlighting

zplugin ice lucid wait"!0" depth"1" atload'set_autosuggest'
zplugin light zsh-users/zsh-autosuggestions

zplugin ice lucid wait"0" atload"set_async"
zplugin light mafredri/zsh-async

# completion
zplugin ice lucid wait"0" depth"1" blockf
zplugin light zsh-users/zsh-completions

zplugin ice lucid depth"1" wait'[[ -n ${ZLAST_COMMANDS[(r)rbe*]} ]] || [[ -n ${ZLAST_COMMANDS[(r)pye*]} ]] || [[ -n ${ZLAST_COMMANDS[(r)node*]} ]]'
zplugin light 39e/zsh-completions-anyenv

# fuzzy finder
zplugin ice lucid wait"0" from"gh-r" as"program" mv"fzf -> ${ZPFX}/bin/fzf"
zplugin light junegunn/fzf-bin

zplugin ice lucid wait"0" depth"1" as"program" mv"bin/fzf-tmux -> ${ZPFX}/bin/fzf-tmux"
zplugin light junegunn/fzf

zplugin ice lucid wait"0" from"gh-r" as"program" mv"peco_darwin_amd64/peco -> ${ZPFX}/bin/peco"
zplugin light peco/peco

# command
zplugin ice lucid wait"0" depth"1" as"program" src"tmuximum.plugin.zsh" atload"set_tmuximum" pick"tmuximum"
zplugin light yuki-ycino/tmuximum

zplugin ice lucid wait'0' depth"1" as"program" atclone'go build -o memo' atpull'%atclone' src="misc/completion.zsh" mv"memo -> ${ZPFX}/bin/memo"
zplugin light mattn/memo

zplugin ice lucid wait'0' depth"1" as"program" atclone'go build -o recc' atpull'%atclone' mv"recc -> ${ZPFX}/bin/memo"
zplugin light pocke/recc

zplugin ice lucid wait'0' depth"1" as"program" atclone'go build -o ptmux' atpull'%atclone' mv"ptmux -> ${ZPFX}/bin/memo"
zplugin light pocke/ptmux

zplugin ice wait"2" depth"1" lucid as"program" pick"bin/git-dsf"
zplugin light zdharma/zsh-diff-so-fancy

zplugin ice lucid wait"2" depth"1" as"program" src"git-sync.sh"
zplugin light caarlos0/zsh-git-sync

zplugin ice lucid wait"2" depth"1" as"program" atclone'perl Makefile.PL PREFIX=$ZPFX' atpull'%atclone' make'install' pick"$ZPFX/bin/git-cal"
zplugin light k4rthik/git-cal

zplugin ice lucid wait"2" depth"1" as"program" mv"docker-clean -> ${ZPFX}/bin/docker-clean"
zplugin light ZZROTDesign/docker-clean

zplugin ice lucid depth"1" wait'[[ -n ${ZLAST_COMMANDS[(r)extr*]} ]]'
zplugin snippet OMZ::plugins/extract/extract.plugin.zsh

zplugin ice lucid depth"1" wait'[[ -n ${ZLAST_COMMANDS[(r)genc*]} ]]'
zplugin light RobSis/zsh-completion-generator

# util
zplugin ice lucid depth"1" wait"2"
zplugin light yukiycino-dotfiles/fancy-ctrl-z

zplugin ice lucid wait"2"
zplugin snippet 'https://github.com/knu/zsh-git-escape-magic/blob/master/git-escape-magic'

# zplugin ice lucid wait'[[ -n ${ZLAST_COMMANDS[(r)cdd*]} ]]'
# zplugin light yukiycino-dotfiles/cdd
# }}}

# async
function set_async() {
#   async_init
#
#   Async update git prompt
#   async_start_worker git_prompt_worker -n
#   function git_prompt_callback() {
#     GIT_STATUS=$(git-prompt zsh)
#     async_stop_worker async_start_worker
#     async_unregister_callback async_start_worker
#   }
#   function kick_git_prompt_worker() {
#     async_job git_prompt_worker true
#   }
#   async_register_callback git_prompt_worker git_prompt_callback
#   add-zsh-hook precmd kick_git_prompt_worker
#   cd $current_dir; kick_git_prompt_worker
#
#   Update tmux window title to directory name
#   async_start_worker tmux_dir_worker -n
#   function set_current_dir_to_tmux() {
#     tmux rename-window "${PWD:t} " > /dev/null
#   }
#   function kick_tmux_dir_worker() {
#     if [[ ! -z ${TMUX} ]]; then
#       async_flush_jobs tmux_dir_worker
#       async_job tmux_dir_worker true
#     fi
#   }
#   async_register_callback tmux_dir_worker set_current_dir_to_tmux
#   add-zsh-hook chpwd kick_tmux_dir_worker
#   kick_tmux_dir_worker
}
# current_dir=$(pwd)

# fast-syntax-highlighting
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

  bindkey -M viins '^p' history-search-backward
  bindkey -M viins '^n' history-search-forward
  bindkey -M vicmd 'k'  history-search-backward
  bindkey -M vicmd 'j'  history-search-forward
}

# abbreviations
typeset -A abbreviations

abbreviations=(
"ga"     "git add"
"gaa"    "git add --all"
"gre"    "git reset"
"gref"   "git reset --"
"gun"    "git unstage"
"grec"   "git recover"
"grm"    "git rm"
"gs"     "git status --short --branch"
"gb"     "git branch"
"gbd"    "git branch -d"
"gd"     "git dsf"
"gdw"    "git dsf --color-words"
"gdc"    "git dsf --cached"
"gdcw"   "git dsf --cached --color-words"
"gco"    "git checkout"
"gcof"   "git checkout --"
"gfo"    "git forget"
"gci"    "git commit"
"gcia"   "git commit --amend --no-edit"
"gp"     "git push"
"gst"    "git stash"
"gstp"   "git stash pop"
"gq"     "git qsave"
"gca"    "git cancel"
"g"      "rg"
"dco"    "docker-compose"
"t"      "tmuximum"
"tl"     "tmux list-sessions"
"ta"     "tmux attach-session"
"ts"     "tmux swap-pane -t"
"ch"     "cheat"
"chs"    "cheat --shell"
)

function _magic-abbrev-expand-and-accept-line() {
  zle magic-abbrev-expand
  zle accept-line
}
zle -N magic-abbrev-expand-and-accept-line _magic-abbrev-expand-and-accept-line

# extra-abbrev
EXTRA_ABBREV=(
  "gci" "git commit -m '_|_'"
)

# show-buffer-stack
add-zsh-hook precmd check-buffer-stack

# autosuggestions
function set_autosuggest() {
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(magic-abbrev-expand-and-accept-line magic-abbrev-expand-and-fzf-direct-completion $ZSH_AUTOSUGGEST_CLEAR_WIDGETS)
  _zsh_autosuggest_start
}

# exa
if whence exa > /dev/null; then
  alias ls="exa"
  alias ll="exa -lh  --git"
  alias la="exa -alh --git"
  alias lt="exa -alh --git"
elif whence gls > /dev/null; then
  alias ls='gls --color=auto'
  alias ll='ls -lh'
  alias la='ls -alh'
else
  alias ll='ls -lh'
  alias la='ls -alh'
fi

function set_tmuximum() {
  bindkey -M viins '^[t' tmuximum
  bindkey -M vicmd '^[t' tmuximum
  bindkey -M vivis '^[t' tmuximum
}

# cdd
# chpwd_functions+=_cdd_chpwd

# }}}

# autoload {{{

autoload -Uz add-zsh-hook
autoload -Uz colors; colors
autoload -Uz edit-command-line
autoload -Uz history-search-end
autoload -Uz select-bracketed
autoload -Uz select-quoted
autoload -Uz smart-insert-last-word
autoload -Uz surround
autoload -Uz terminfo
autoload -Uz zed

# }}}

# Color Definition {{{

DEFAULT="${reset_color}"
RED="${fg[red]}"
GREEN="${fg[green]}"
YELLOW="${fg[yellow]}"
BLUE="${fg[blue]}"
PURPLE="${fg[purple]}"
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

## dircolors
if [[ -f ~/.dircolors ]] && whence gdircolors > /dev/null; then
  eval "$(gdircolors ~/.dircolors)"
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

# Funcion & Alias {{{

function rg() {
  if [[ -t 1 ]]; then
    command rg --smart-case --pretty "$@" | less -RFX
  else
    command rg --smart-case --pretty "$@"
  fi
}

alias -g  CB='$(git rev-parse --abbrev-ref HEAD)'
alias -g RCB='origin/$(git rev-parse --abbrev-ref HEAD)'

# }}}

# fzf {{{
for f in $(find ~/.zsh/fzf_completions/ -name "*.zsh"); do
  source "${f}"
done

function fzf-direct-completion() {
  local tokens cmd lastcmd
  setopt localoptions noshwordsplit

  if [[ $BUFFER[-1] == $FZF_COMPLETION_TRIGGER ]]; then
    zle fzf-completion
    return
  fi

  if [[ $BUFFER[-1] != " " ]]; then
    zle expand-or-complete
    return
  fi

  tokens=(${(z)BUFFER})
  cmd=${tokens[1]}
  lastcmd=${tokens[-1]}

  if [[ $cmd == "git" ]]; then
    zle fzf-git-completion
  elif [[ $cmd == "rbenv" || $cmd == "pyenv" || $cmd == "nodenv" ]]; then
    zle fzf-anyenv-completion
  elif [[ $cmd == "tmux" ]]; then
    zle fzf-tmux-completion
  elif [[ $lastcmd == "rspec" || $lastcmd == "grspec" ]]; then
    zle fzf-rspec-completion
  else
    zle expand-or-complete
  fi
}
zle -N fzf-direct-completion

# Project
function f() {
  local dir repository session current_session
  dir=$(ghq root)/$(ghq list | fzf --prompt='Project >')

  if [[ $dir != "$(ghq root)/" ]]; then
    if [[ ! -z ${TMUX} ]]; then
      repository=${dir##*/}
      session=${repository//./-}
      current_session=$(tmux list-sessions | grep 'attached' | cut -d":" -f1)

      if [[ $current_session =~ ^[0-9]+$ ]]; then
        cd $dir
        tmux rename-session $session
      else
        tmux list-sessions | cut -d":" -f1 | grep $session > /dev/null
        if [[ $? != 0 ]]; then
          tmux new-session -d -c $dir -s $session
        fi
        tmux switch-client -t $session
      fi
    else
      cd $dir
    fi
  fi
}

# Global Alias

## Git
alias -g  B='$(git branch -a | fzf-branch | fzf --multi --preview="git fzflog {}" --prompt "All Branches>"    | sed -e "s/^\*\s*//g")'
alias -g RB='$(git branch -r | fzf-branch | fzf --multi --preview="git fzflog {}" --prompt "Remote Branches>" | sed -e "s/^\*\s*//g")'
alias -g LB='$(git branch    | fzf-branch | fzf --multi --preview="git fzflog {}" --prompt "Local Branches>"  | sed -e "s/^\*\s*//g")'

## RSpec
alias -g RS='$(git status --short | fzf-git-rspec | fzf --multi --preview="git diff --color=always {}" --prompt "Changed RSpec>")'

# }}}

# peco {{{

# history
function peco-history-selection() {
  BUFFER=$(\history -n -r 1 | peco --query "$BUFFER")
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N peco-history-selection

function peco-process-selection() {
  local pids
  pids=$(\ps -u $USER -o 'pid,stat,%cpu,%mem,cputime,command' | peco | awk '{ print $1 }' | tr '\n' ' ' )

  if [[ $pids != "" ]]; then
    BUFFER="kill $pids"
    CURSOR=$#BUFFER
  fi
  zle reset-prompt
}
zle -N peco-process-selection

# nicovideo
function peco-nico-ranking() {
  ruby -r rss -e 'RSS::Parser.parse("http://www.nicovideo.jp/ranking/fav/daily/all?rss=2.0").channel.items.each {|item| puts item.link + "\t" + item.title}' | peco | while read -r line; do
    echo "$line"
    echo "$line" | awk '{print $1}' | nicovideo-dump | mplayer -
  done
}

function peco-nico-tag() {
  TAG=$(url-encode "$*")
  ruby -r rss -e "RSS::Parser.parse(\"http://www.nicovideo.jp/tag/$TAG?rss=2.0\").channel.items.each {|item| puts item.link + \"\\t\" + item.title}" | peco | while read -r line; do
    echo "$line"
    echo "$line" | awk '{print $1}' | nicovideo-dump | mplayer -
  done
}

function peco-nico-bgm() {
  TAG=$(url-encode "作業用BGM $*")
  ruby -r rss -e "RSS::Parser.parse(\"http://www.nicovideo.jp/tag/$TAG?rss=2.0\").channel.items.each {|item| puts item.link + \"\\t\" + item.title}" | peco | while read -r line; do
    echo "$line"
    echo "$line" | awk '{print $1}' | nicovideo-dump | mplayer - -novideo
  done
}

# }}}

# Prompt {{{

# pure prompt
# PROMPT='${VIM_PROMPT}%{$DEFAULT%} %F{246}${PYTHON_VIRTUAL_ENV_STRING}%f%(?.%{$WHITE%}.%{$RED%})$ %{$DEFAULT%}'

# Command Buffer Stack
RPROMPT='${COMMAND_BUFFER_STACK}'

PROMPT='
%F{blue}%~%f $GIT_STATUS
${VIM_PROMPT}%{$DEFAULT%} %F{246}${PYTHON_VIRTUAL_ENV_STRING}%f%(?.%{$WHITE%}.%{$RED%})$ %{$DEFAULT%}'

function update_git_prompt() {
  GIT_STATUS=$(git-prompt zsh)
}
add-zsh-hook precmd update_git_prompt

# TMOUT=1
# TRAPALRM() {
#   if [[ "${WIDGET}" != "fzf-completion" ]] && [[ "${WIDGET}" != "magic-abbrev-expand-and-fzf-direct-completion" ]]; then
#     zle reset-prompt
#   fi
# }

function prompt_update_vim_prompt() {
  VIM_NORMAL="%{$GREEN%}-- NORMAL --%{$DEFAULT%}"
  VIM_INSERT="%{$YELLOW%}-- INSERT --%{$DEFAULT%}"
  VIM_VISUAL="%{$CYAN%}-- VISUAL --%{$DEFAULT%}"
  VIM_PROMPT="${${${KEYMAP/vicmd/$VIM_NORMAL}/(main|viins)/$VIM_INSERT}/(vivis)/$VIM_VISUAL}"
  zle reset-prompt
}

function _zle-line-init {
  prompt_update_vim_prompt
}

function _zle-keymap-select {
  prompt_update_vim_prompt
}

zle -N zle-line-init _zle-line-init
zle -N zle-keymap-select _zle-keymap-select

function venv_name () {
  PYTHON_VIRTUAL_ENV_STRING=""
  if [[ -n "$VIRTUAL_ENV" ]]; then
    PYTHON_VIRTUAL_ENV_STRING="venv:$(basename $VIRTUAL_ENV) "
  fi
}

add-zsh-hook precmd venv_name

# }}}

# tmux {{{

function _left-pane() {
  tmux select-pane -L
}
zle -N left-pane _left-pane

function _down-pane() {
  tmux select-pane -D
}
zle -N down-pane _down-pane

function _up-pane() {
  tmux select-pane -U
}
zle -N up-pane _up-pane

function _right-pane() {
  tmux select-pane -R
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

# zed {{{

function _zed_page_up() {
  integer count=$(( LINES / 2 - 1 ))
  while (( count -- )); do
    zle up-line
  done
}

function _zed_page_down() {
  integer count=$(( LINES / 2 - 1 ))
  while (( count -- )); do
    zle down-line
  done
}

zle -N zed-page-up   _zed_page_up
zle -N zed-page-down _zed_page_down

# }}}

# Bindkey {{{

function _magic-abbrev-expand-and-fzf-direct-completion() {
  local buf
  buf="$BUFFER"
  zle magic-abbrev-expand

  if [[ $buf != $BUFFER ]]; then
    BUFFER="$BUFFER "
    CURSOR=$#BUFFER
    zle reset-prompt
  fi

  zle fzf-direct-completion
}
zle -N magic-abbrev-expand-and-fzf-direct-completion _magic-abbrev-expand-and-fzf-direct-completion

# Default bind
# bindkey -e
bindkey -v

# Wait for next key input for 0.15 seconds (Default 0.4s)
KEYTIMEOUT=15

bindkey -M viins '^i'  magic-abbrev-expand-and-fzf-direct-completion
bindkey -M viins ' '   magic-abbrev-expand-and-space
bindkey -M viins '^x ' no-magic-abbrev-expand
bindkey -M viins '^ '  extra-abbrev
bindkey -M viins '^m'  magic-abbrev-expand-and-accept-line
bindkey -M viins '^]'  insert-last-word
bindkey -M viins '^u'  undo
bindkey -M viins "^[u" redo
bindkey -M viins '^[f' vi-forward-blank-word
bindkey -M viins "^[b" vi-backward-blank-word

bindkey -M viins '^a' beginning-of-line
bindkey -M viins '^b' backward-char
bindkey -M viins '^d' delete-char-or-list
bindkey -M viins '^e' end-of-line
bindkey -M viins '^f' forward-char
bindkey -M viins '^g' send-break
bindkey -M viins '^k' kill-line-or-up-pane
bindkey -M viins '^w' backward-kill-word
bindkey -M viins '^p' up-line-or-history
bindkey -M viins '^n' down-line-or-history
bindkey -M viins '^y' yank
bindkey -M viins '^q' show-buffer-stack

# mapping undo and redo
# bindkey -M viins '^u' backward-kill-line

bindkey -M viins "$terminfo[kcbt]" reverse-menu-complete

# Add vim bind
bindkey -M vicmd 'k'  up-line-or-history
bindkey -M vicmd 'j'  down-line-or-history
bindkey -M vicmd '/'  vi-history-search-forward
bindkey -M vicmd '?'  vi-history-search-backward
bindkey -M vicmd 'gg' beginning-of-line
bindkey -M vicmd 'G'  end-of-line
bindkey -M vicmd 'q'  show-buffer-stack
bindkey -M vicmd '^m' magic-abbrev-expand-and-accept-line

# Add tmux bind
bindkey -M viins '^h' backspace-or-left-pane
bindkey -M vicmd '^h' left-pane
bindkey -M vivis '^h' left-pane
bindkey -M vicmd '^k' up-pane
bindkey -M vivis '^k' up-pane
bindkey -M viins '^j' accept-line-or-down-pane

# Completion bind
zmodload zsh/complist
bindkey -M menuselect '^g' .send-break
bindkey -M menuselect '^i' forward-char
bindkey -M menuselect '^j' .accept-line
bindkey -M menuselect '^k' accept-and-infer-next-history
bindkey -M menuselect '^n' down-line-or-history
bindkey -M menuselect '^p' up-line-or-history
bindkey -M menuselect '^h' undo

# All Mode bind
bindkey -M viins '^r'   peco-history-selection
bindkey -M vicmd '^r'   peco-history-selection
bindkey -M vivis '^r'   peco-history-selection
bindkey -M viins '^xk'  peco-process-selection
bindkey -M vicmd '^xk'  peco-process-selection
bindkey -M vivis '^xk'  peco-process-selection
bindkey -M viins '^x^k' peco-process-selection
bindkey -M vicmd '^x^k' peco-process-selection
bindkey -M vivis '^x^k' peco-process-selection

# Command Line Edit
zle -N edit-command-line
bindkey -M viins '^xe'  edit-command-line
bindkey -M vicmd '^xe'  edit-command-line
bindkey -M viins '^x^e' edit-command-line
bindkey -M vicmd '^x^e' edit-command-line

# Surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -M vicmd  'sr' change-surround
bindkey -M vicmd  'sd' delete-surround
bindkey -M vicmd  'sa' add-surround
bindkey -M visual 'S'  add-surround

zle -N select-bracketed
for m in visual vivis viopp; do
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M "$m" "$c" select-bracketed
  done
done

zle -N select-quoted
for m in visual vivis viopp; do
  for c in {a,i}{\',\",\`}; do
    bindkey -M "$m" "$c" select-quoted
  done
done

# zed
# zed -b
# bindkey -N zed viins
#
# bindkey -M zed       '^n' down-line-or-search
# bindkey -M zed       '^p' up-line-or-search
# bindkey -M zed       '^m' self-insert-unmeta
# bindkey -M zed       '^s' history-incremental-search-forward
# bindkey -M zed       '^r' history-incremental-search-backward
# bindkey -M zed-vicmd 'j'  down-line-or-search
# bindkey -M zed-vicmd 'k'  up-line-or-search
# bindkey -M zed-vicmd 'gg' vi-goto-first-line
# bindkey -M zed-vicmd 'G'  end-of-buffer
# bindkey -M zed-vicmd '^r' redo
# bindkey -M zed-vicmd '/'  history-incremental-search-forward
# bindkey -M zed-vicmd '?'  history-incremental-search-backward
# bindkey -M zed-vicmd 'n'  vi-repeat-search
# bindkey -M zed-vicmd 'N'  vi-rev-repeat-search
# bindkey -M zed-vicmd 'ZZ' accept-line
# bindkey -M zed-vicmd '^u' zed-page-up
# bindkey -M zed-vicmd '^d' zed-page-down

# }}}

# Misc {{{

# Loading zpty
# https://github.com/zchee/deoplete-zsh
zmodload zsh/zpty

# neovim_remote
function neovim_autocd() {
  [[ $NVIM_LISTEN_ADDRESS ]] && neovim-autocd
}
chpwd_functions+=( neovim_autocd )

# Auto execute rehash when executing anyenv command
add-zsh-hook preexec env_rehash
add-zsh-hook precmd  env_rehash

function env_rehash() {
  if   echo "$1" | grep rbenv  > /dev/null ; then
    rbenv rehash
  elif echo "$1" | grep pyenv  > /dev/null ; then
    pyenv rehash
  elif echo "$1" | grep nodenv > /dev/null ; then
    nodenv rehash
  fi
}

# }}}

# Local File {{{

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# }}}

# Loading fzf {{{

source ~/.zsh/misc/fzf_completion.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS='--reverse'
export FZF_COMPLETION_TRIGGER=';'

# }}}

# Profile {{{

if (which zprof > /dev/null) ;then
  zprof | less
fi

# }}}

# zcompile {{{

# .zshrc
if [[ ! -f ~/.zshrc.zwc ]] || [[ "$(readlink ~/.zshrc)" -nt ~/.zshrc.zwc ]]; then
  zcompile ~/.zshrc
fi

# zgen
if [[ ! -f ~/.zsh/zgen/zgen.zsh.zwc ]] || [[ ~/.zsh/zgen/zgen.zsh -nt ~/.zsh/zgen/zgen.zsh.zwc ]]; then
  zcompile  ~/.zsh/zgen/zgen.zsh
fi

# fzf_completions
for f in $(find ~/.zsh/fzf_completions/ -name "*.zsh")
do
  if [[ ! -f "$f.zwc" ]] || [[ $f -nt "$f.zwc" ]]; then
    zcompile "$f"
  fi
done
# }}}

# vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
