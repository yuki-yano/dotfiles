# zgen {{{

source ~/dotfiles/.zsh/zgen/zgen.zsh

if ! zgen saved; then
  zgen load 39e/zsh-completions-anyenv
  zgen load b4b4r07/zsh-vimode-visual
  zgen load knu/zsh-git-escape-magic
  zgen load kutsan/zsh-system-clipboard
  zgen load mafredri/zsh-async
  zgen load mollifier/anyframe
  zgen load sindresorhus/pure
  zgen load yukiycino-dotfiles/cdd
  zgen load yukiycino-dotfiles/fancy-ctrl-z
  zgen load yukiycino-dotfiles/zsh-extra-abbrev
  zgen load zdharma/fast-syntax-highlighting
  zgen load zsh-users/zsh-autosuggestions
  zgen load zsh-users/zsh-completions src

  zgen oh-my-zsh plugins/extract

  zgen save

  # compile
  # shellcheck disable=SC2044
  for f in $(find ~/.zgen/ -name "*.zsh"); do zcompile "$f"; done
fi

# pure settings
export PURE_PROMPT_SYMBOL='$'

# zsh system clipboard
export ZSH_SYSTEM_CLIPBOARD_TMUX_SUPPORT=true

# shellcheck disable=SC2034,SC2154
{
  FAST_HIGHLIGHT_STYLES[alias]=fg=blue
  FAST_HIGHLIGHT_STYLES[suffix-alias]=fg=blue
  FAST_HIGHLIGHT_STYLES[builtin]=fg=blue
  FAST_HIGHLIGHT_STYLES[function]=fg=blue
  FAST_HIGHLIGHT_STYLES[command]=fg=blue
  FAST_HIGHLIGHT_STYLES[precommand]=fg=blue,underline
  FAST_HIGHLIGHT_STYLES[hashed-command]=fg=blue
  FAST_HIGHLIGHT_STYLES[path]=fg=green
  FAST_HIGHLIGHT_STYLES[globbing]=fg=green,bold
  FAST_HIGHLIGHT_STYLES[history-expansion]=fg=green,bold
}

# extra-abbrev
export EXTRA_ABBREV=(
"gci" "gci -m '_|_'"
)

chpwd_functions+=_cdd_chpwd

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

# }}}

# Color Definition {{{

# shellcheck disable=SC2154
{
  export DEFAULT="${reset_color}"
  export RED="${fg[red]}"
  export GREEN="${fg[green]}"
  export YELLOW="${fg[yellow]}"
  export BLUE="${fg[blue]}"
  export PURPLE="${fg[purple]}"
  export CYAN="${fg[cyan]}"
  export WHITE="${fg[white]}"
}

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

## dircolors
if [ -f ~/.dircolors ] && whence gdircolors > /dev/null; then
  eval "$(gdircolors ~/.dircolors)"
fi

# history
HISTFILE=${HOME}/.zsh_history
HISTSIZE=100000
export SAVEHIST=100000

# C-w target chars
export WORDCHARS="*?_-[]~=&!#$%^(){}<>"

# smart-insert-last-word
zstyle :insert-last-word match '*([[:alpha:]/\\]?|?[[:alpha:]/\\])*'
zle -N insert-last-word smart-insert-last-word

# Show details automatically
export REPORTTIME=10

# }}}

# Completion {{{

export LISTMAX=1000

# zstyle
zstyle ':completion:*' menu select=2
zstyle ':completion:*' group-name ''
zstyle ':completion:*'  completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' '+r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s

# Highlight
# shellcheck disable=SC2154
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:messages' format "$YELLOW" '%d' "$DEFAULT"
zstyle ':completion:*:warnings' format "$RED" 'No matches for:' "$YELLOW" ' %d' "$DEFAULT"
zstyle ':completion:*:descriptions' format "$YELLOW" 'completing %B%d%b' "$DEFAULT"
zstyle ':completion:*:corrections' format "$YELLOW" '%B%d% ' "$RED" '(errors: %e)%b' "$DEFAULT"

# Separator
zstyle ':completion:*' list-separator ' ==> '
zstyle ':completion:*:manuals' separate-sections true

# Cache
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

# Others
zstyle ':completion:*' remote-access false
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# }}}

# Alias {{{

alias -g  CB='$(git rev-parse --abbrev-ref HEAD)'
alias -g RCB='origin/$(git rev-parse --abbrev-ref HEAD)'

# }}}

# Fuzzy Finder {{{

# Project
function f() {
  local dir
  dir=$(ghq root)/$(ghq list | fzf)
  cd "$dir"

  if [[ ! -z ${TMUX} ]]; then
    repository=${dir##*/}
    tmux rename-session "${repository//./-}"
  fi
}

# Git
alias -g  B='$(git branch -a | fzf --multi --prompt "All Branches>"    | sed -e "s/^\*\s*//g")'
alias -g RB='$(git branch -r | fzf --multi --prompt "Remote Branches>" | sed -e "s/^\*\s*//g")'
alias -g LB='$(git branch    | fzf --multi --prompt "Local Branches>"  | sed -e "s/^\*\s*//g")'

alias -g S='$(git status -s           | cut -b 4- | uniq | fzf --multi --prompt "Changed File>")'
alias -g U='$(git ls-files --unmerged | cut -f2   | uniq | fzf --multi --prompt "Unmerged File>")'

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

function zle-line-init()  {
  VIM_NORMAL="%F{green}-- NORMAL --%f"
  VIM_INSERT="%F{yellow}-- INSERT --%f"
  VIM_VISUAL="%F{cyan}-- VISUAL --%f"
  RPS1="${${${KEYMAP/vicmd/$VIM_NORMAL}/(main|viins)/$VIM_INSERT}/(vivis)/$VIM_VISUAL}"
  RPS2=$RPS1

  zle reset-prompt
}

# shellcheck disable=SC2034
function zle-keymap-select() {
  VIM_NORMAL="%F{green}-- NORMAL --%f"
  VIM_INSERT="%F{yellow}-- INSERT --%f"
  VIM_VISUAL="%F{cyan}-- VISUAL --%f"
  RPS1="${${${KEYMAP/vicmd/$VIM_NORMAL}/(main|viins)/$VIM_INSERT}/(vivis)/$VIM_VISUAL}"
  RPS2=$RPS1

  zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

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

# Bindkey {{{

# Default bind
# bindkey -e
bindkey -v

# Wait for next key input for 0.15 seconds (Default 0.4s)
export KEYTIMEOUT=15

bindkey -M viins '^ ' extra-abbrev
bindkey -M viins '^]' insert-last-word

# Add emacs bind
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

bindkey -M viins '^a' beginning-of-line
bindkey -M viins '^b' backward-char
bindkey -M viins '^d' delete-char-or-list
bindkey -M viins '^e' end-of-line
bindkey -M viins '^f' forward-char
bindkey -M viins '^g' send-break
bindkey -M viins '^k' kill-line-or-up-pane
bindkey -M viins '^n' history-beginning-search-forward-end
bindkey -M viins '^p' history-beginning-search-backward-end
bindkey -M viins '^u' backward-kill-line
bindkey -M viins '^w' backward-kill-word
bindkey -M viins '^y' yank
bindkey -M viins '^q' push-line-or-edit

# shellcheck disable=SC2154
bindkey -M viins "$terminfo[kcbt]" reverse-menu-complete

# Add vim bind
bindkey -M vicmd 'j'  history-beginning-search-forward-end
bindkey -M vicmd 'k'  history-beginning-search-backward-end
bindkey -M vicmd '/'  vi-history-search-forward
bindkey -M vicmd '?'  vi-history-search-backward
bindkey -M vicmd 'gg' beginning-of-line
bindkey -M vicmd 'G'  end-of-line
bindkey -M vicmd 'q'  push-line-or-edit

# Add tmux bind
bindkey -M viins '^h' backspace-or-left-pane
bindkey -M vicmd '^h' left-pane
bindkey -M vivis '^h' left-pane
bindkey -M vicmd '^k' up-pane
bindkey -M vivis '^k' up-pane
bindkey -M vicmd '^j' accept-line-or-down-pane
bindkey -M viins '^j' accept-line-or-down-pane

# Completion bind
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# All Mode bind
bindkey -M viins '^r'   anyframe-widget-put-history
bindkey -M vicmd '^r'   anyframe-widget-put-history
bindkey -M vivis '^r'   anyframe-widget-put-history
bindkey -M viins '^xk'  anyframe-widget-kill
bindkey -M vicmd '^xk'  anyframe-widget-kill
bindkey -M vivis '^xk'  anyframe-widget-kill
bindkey -M viins '^x^k' anyframe-widget-kill
bindkey -M vicmd '^x^k' anyframe-widget-kill
bindkey -M vivis '^x^k' anyframe-widget-kill
bindkey -M viins '^z'   fancy-ctrl-z
bindkey -M vicmd '^z'   fancy-ctrl-z
bindkey -M vivis '^z'   fancy-ctrl-z

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
  # shellcheck disable=SC2154
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

[ -f /usr/local/opt/fzf/shell/completion.zsh ] && source /usr/local/opt/fzf/shell/completion.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS='--reverse'

# }}}

# Profile {{{

if (which zprof > /dev/null) ;then
  zprof | less
fi

# }}}

# zcompile {{{

if [ ! -f ~/.zshrc.zwc ] || [ "$(readlink ~/.zshrc)" -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

if [ ! -f ~/.zsh/zgen/zgen.zsh.zwc ] || [ ~/.zsh/zgen/zgen.zsh -nt ~/.zsh/zgen/zgen.zsh.zwc ]; then
  zcompile  ~/.zsh/zgen/zgen.zsh
fi

# }}}

# vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
