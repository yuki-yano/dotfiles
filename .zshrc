#! /usr/local/bin/zsh

# Zgen {{{

source ~/dotfiles/.zsh/zgen/zgen.zsh

if ! zgen saved; then
  zgen load 39e/zsh-completions-anyenv
  zgen load Tarrasch/zsh-autoenv
  zgen load greymd/docker-zsh-completion
  zgen load knu/zsh-git-escape-magic
  zgen load mafredri/zsh-async
  zgen load mollifier/anyframe
  zgen load sindresorhus/pure
  zgen load tarruda/zsh-autosuggestions
  zgen load yuki-ycino/cdd
  zgen load yuki-ycino/fancy-ctrl-z
  zgen load zdharma/fast-syntax-highlighting
  zgen load zsh-users/zsh-completions src
  zgen load zsh-users/zsh-history-substring-search
  zgen load zuxfoucault/colored-man-pages_mod

  zgen save

  # compile
  # shellcheck disable=SC2044
  for f in $(find ~/.zgen/ -name "*.zsh"); do zcompile "$f"; done
fi

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

chpwd_functions+=_cdd_chpwd

# }}}

# Basic {{{

# ls
alias ls="ls -GF"
alias gls="gls --color"

# cd
typeset -U chpwd_functions
CD_HISTORY_FILE=${HOME}/.cd_history_file
function chpwd_record_history() {
  echo "$PWD" >> "${CD_HISTORY_FILE}"
}
chpwd_functions+=("$chpwd_functions" chpwd_record_history)

## dircolors
if [ -f ~/.dircolors ]; then
  if type dircolors > /dev/null 2>&1; then
    eval "$(dircolors ~/.dircolors)"
  elif type gdircolors > /dev/null 2>&1; then
    eval "$(gdircolors ~/.dircolors)"
  fi
fi

# 各種機能
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt list_packed
setopt noautoremoveslash
setopt nolistbeep
setopt histignorealldups histsavenodups
setopt sharehistory
setopt no_nomatch
setopt magic_equal_subst

# コマンド履歴設定
HISTFILE=${HOME}/.zsh_history
HISTSIZE=50000
export SAVEHIST=50000
setopt hist_ignore_dups
setopt share_history
setopt hist_ignore_space
setopt hist_ignore_all_dups

# C-w
export WORDCHARS="*?_-[]~=&!#$%^(){}<>"

# add-zsh-hookの読み込み
autoload -Uz add-zsh-hook

# smart-insert-last-word
autoload -Uz smart-insert-last-word
zstyle :insert-last-word match '*([[:alpha:]/\\]?|?[[:alpha:]/\\])*'
zle -N insert-last-word smart-insert-last-word

# }}}

# Completion {{{

# zgenが実行している
# autoload -Uz compinit
# compinit -C

zstyle ':completion:*' verbose true
zstyle ':completion:*' remote-access false
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' group-name ''
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' '+r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' completer _oldlist _complete _match _ignored
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:default:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:kill:*' list-colors '=(#b) #([0-9]#)*( *[a-z])*=34=31=33'
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-separator ' ==> '
zstyle ':completion:*:messages' format '%F{YELLOW}%d'"$DEFAULT"
zstyle ':completion:*:warnings' format '%F{RED}No matches for:''%F{YELLOW} %d'"$DEFAULT"
zstyle ':completion:*:descriptions' format $'%{\e[38;5;147m%}%B[%d%B]%b%{\e[m%}'
zstyle ':completion:*:corrections' format $'%{\e[38;5;147m%}%B[%d%B]%b%{\e[m%}'
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# }}}

# Alias {{{

alias -g  CB='$(git rev-parse --abbrev-ref HEAD)'
alias -g RCB='origin/$(git rev-parse --abbrev-ref HEAD)'

# }}}

# Fuzzy Finder {{{

f() {
  local dir
  dir="$(ghq list > /dev/null | fzf --reverse)" && cd "$(ghq root)/$dir"
}

alias -g  B='$(git branch -a | fzf --multi --prompt "All Branches>"    | sed -e "s/^\*\s*//g")'
alias -g RB='$(git branch -r | fzf --multi --prompt "Remote Branches>" | sed -e "s/^\*\s*//g")'
alias -g LB='$(git branch    | fzf --multi --prompt "Local Branches>"  | sed -e "s/^\*\s*//g")'

alias -g S='$(git status -s           | cut -b 4- | uniq | fzf --multi --prompt "Changed File>")'
alias -g U='$(git ls-files --unmerged | cut -f2   | uniq | fzf --multi --prompt "Unmerged File>")'

function agvim () {
  vi "$(ag "$@" | peco --query "$LBUFFER" | awk -F : '{print $1 ":" $2}')"
}

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

# Misc {{{

# zptyを読み込み
# https://github.com/zchee/deoplete-zsh
zmodload zsh/zpty

# abbrev
# http://d.hatena.ne.jp/keno_ss/20140214/1392330322
typeset -A myabbrev
myabbrev=(
"gci" "gci -m '_|_'"
)

function my-expand-abbrev() {
  if [ -z "$RBUFFER" ] ; then
    my-expand-abbrev-aux
  else
    zle end-of-line
  fi
}

function my-expand-abbrev-aux() {
  local init last value addleft addright
  init=$(echo -nE "$LBUFFER" | sed -e "s/[_a-zA-Z0-9]*$//")
  last=$(echo -nE "$LBUFFER" | sed -e "s/.*[^_a-zA-Z0-9]\\([_a-zA-Z0-9]*\\)$/\\1/")
  value=${myabbrev[$last]}
  if [[ $value = *_\|_* ]] ; then
    addleft=${value%%_\|_*}
    addright=${value#*_\|_}
  else
    addleft=$value
    addright=""
  fi
  if [ "$last" = "PWD" ] ; then
    LBUFFER=""
    RBUFFER="$PWD"
  else
    LBUFFER=$init${addleft:-$last }
    RBUFFER=$addright$RBUFFER
  fi
}

zle -N my-expand-abbrev

function neovim_autocd() {
  [[ $NVIM_LISTEN_ADDRESS ]] && neovim-autocd
}
chpwd_functions+=( neovim_autocd )

function up-line-or-history-ignoring() {
  zle up-line-or-history
  case "$LBUFFER" in
    fg|bg)
      zle up-line-or-history
      ;;
  esac
}
zle -N up-line-or-history-ignoring

# tmuxにカレントディレクトリ名を設定
autoload -Uz add-zsh-hook
add-zsh-hook preexec env_rehash
add-zsh-hook precmd  env_rehash
add-zsh-hook precmd  rename_tmux_window

function env_rehash() {
  if echo "$1" | grep rbenv > /dev/null ; then
    rbenv rehash
  elif echo "$1" | grep pyenv > /dev/null ; then
    pyenv rehash
  elif echo "$1" | grep nodenv > /dev/null ; then
    nodenv rehash
  fi
}

function rename_tmux_window() {
  if [[ -n "$TMUX" ]] ; then
    local current_path=$(pwd | sed -e s/\ /_/g)
    local current_dir=$(basename "$current_path")
    tmux rename-window "$current_dir"
  fi
}

# typo時にヒストリに記録しない
function command_not_found_handler() {
  tail -1 "$HISTFILE" |
    grep -F "$*" > /dev/null 2>&1 &&
    sed -i '$d' "$HISTFILE"
  return 127
}

# }}}

# Bindkey {{{

bindkey -e
bindkey "^ "   my-expand-abbrev
bindkey "^q"   show_buffer_stack
bindkey '^[n'  history-substring-search-down
bindkey '^[p'  history-substring-search-up
bindkey '^e'   end-of-line
bindkey '^r'   anyframe-widget-put-history
bindkey '^xk'  anyframe-widget-kill
bindkey '^z'   fancy-ctrl-z
bindkey '^p'   up-line-or-history-ignoring

# }}}

# Local File {{{

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# }}}

# Loading fzf {{{

[ -f /usr/local/opt/fzf/shell/completion.zsh ] && source /usr/local/opt/fzf/shell/completion.zsh
export FZF_DEFAULT_COMMAND='ag -g ""'
export FZF_DEFAULT_OPTS='--reverse'

# }}}

# Profile {{{

if (which zprof > /dev/null) ;then
  zprof | less
fi

# }}}

# zcompile {{{

if [ ! -f ~/.zshrc.zwc ] || [ $(readlink ~/.zshrc) -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

if [ ! -f ~/.zsh/zgen/zgen.zsh.zwc ] || [ ~/.zsh/zgen/zgen.zsh -nt ~/.zsh/zgen/zgen.zsh.zwc ]; then
  zcompile  ~/.zsh/zgen/zgen.zsh
fi

# }}}

# vim:set expandtab shiftwidth=2 softtabstop=2 tabstop=2 foldenable foldmethod=marker:
