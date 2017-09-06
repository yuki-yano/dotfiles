# zplug {{{

export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug Tarrasch/zsh-autoenv
zplug b4b4r07/cli-finder, as:command, use:bin/finder
zplug b4b4r07/emoji-cli
zplug b4b4r07/enhancd, use:enhancd.sh
zplug b4b4r07/git-br, as:command, use:'git-br'
zplug b4b4r07/git-conflict, as:command
zplug b4b4r07/git-open, as:command
zplug b4b4r07/http_code, as:command, use:bin/http_code
zplug b4b4r07/zsh-gomi, as:command, use:bin/gomi
zplug hchbaw/opp.zsh
zplug hlissner/zsh-autopair
zplug jhawthorn/fzy, as:command, hook-build:'make'
zplug knu/zsh-git-escape-magic
zplug mafredri/zsh-async
zplug mollifier/anyframe
zplug plugins/fancy-ctrl-z, from:oh-my-zsh
zplug sindresorhus/pure, use:pure.zsh, as:theme
zplug supercrabtree/k
zplug tarruda/zsh-autosuggestions
zplug zsh-users/zsh-completions
zplug zsh-users/zsh-history-substring-search
zplug zsh-users/zsh-syntax-highlighting
zplug zuxfoucault/colored-man-pages_mod

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load

ZSH_HIGHLIGHT_STYLES[alias]=fg=blue
ZSH_HIGHLIGHT_STYLES[builtin]=fg=blue
ZSH_HIGHLIGHT_STYLES[function]=fg=blue
ZSH_HIGHLIGHT_STYLES[command]=fg=blue
ZSH_HIGHLIGHT_STYLES[hashed-command]=fg=blue
ZSH_HIGHLIGHT_STYLES[precommand]=fg=blue,underline
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=cyan
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=cyan

# }}}

# Basic {{{

# ls
case "${OSTYPE}" in
  freebsd*|darwin*)
    if [ -d /usr/local/opt/coreutils/libexec/gnubin ]; then
      alias ls='gls --color=auto'
    else
      export LSCOLORS=gxfxcxdxbxegedabagacad
      alias ls='ls -G'
    fi
esac

# cd
typeset -U chpwd_functions
CD_HISTORY_FILE=${HOME}/.cd_history_file
function chpwd_record_history() {
  echo $PWD >> ${CD_HISTORY_FILE}
}
chpwd_functions+=($chpwd_functions chpwd_record_history)

## dircolors
if [ -f ~/.dircolors ]; then
  if type dircolors > /dev/null 2>&1; then
    eval $(dircolors ~/.dircolors)
  elif type gdircolors > /dev/null 2>&1; then
    eval $(gdircolors ~/.dircolors)
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
SAVEHIST=50000
setopt hist_ignore_dups
setopt share_history
setopt hist_ignore_space

# C-w
WORDCHARS="*?_-[]~=&!#$%^(){}<>"

# add-zsh-hookの読み込み
autoload -Uz add-zsh-hook

# smart-insert-last-word
autoload -Uz smart-insert-last-word
zstyle :insert-last-word match '*([[:alpha:]/\\]?|?[[:alpha:]/\\])*'
zle -N insert-last-word smart-insert-last-word

# }}}

# Completion {{{

# 補完
autoload -Uz compinit; compinit -u
zstyle ':completion:*' verbose true
zstyle ':completion:*' remote-access false
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' group-name ''
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(|.|..) ]] && reply=(..)'
zstyle ':completion:*' menu select=2 # menu true select=2
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' '+r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' completer _oldlist _complete _match _ignored
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-separator ' ==> '
zstyle ':completion:*:messages' format "%{${fg[yellow]}%}%d"
zstyle ':completion:*:warnings' format "%{${fg[red]}%}No matches for %{${fg[yellow]}%}%d"
zstyle ':completion:*:descriptions' format $'%{\e[38;5;147m%}%B[%d%B]%b%{\e[m%}'
zstyle ':completion:*:corrections' format $'%{\e[38;5;147m%}%B[%d%B]%b%{\e[m%}'
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
zstyle ':completion:*:(vim|mv|rm|diff|ln):*' ignore-line true
zstyle ':completion:*:cd:*' ignore-parents parent pwd # TODO: 効いてない
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# }}}

# terminal {{{

case "${TERM}" in
  screen)
    TERM=xterm
    ;;
esac

case "${TERM}" in
  xterm|xterm-color)
    export LSCOLORS=exfxcxdxbxegedabagacad
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
    ;;
  kterm-color)
    stty erase '^H'
    export LSCOLORS=exfxcxdxbxegedabagacad
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
    ;;
  kterm)
    stty erase '^H'
    ;;
  cons25)
    unset LANG
    export LSCOLORS=ExFxCxdxBxegedabagacad
    export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=;34;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
    ;;
  jfbterm-color)
    export LSCOLORS=gxFxCxdxBxegedabagacad
    export LS_COLORS='di=01;36:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors 'di=;36;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
    ;;
esac

# }}}

# interactive finder {{{

f() {
  local dir
  dir=$(ghq list > /dev/null | fzf --reverse) && cd $(ghq root)/$dir
}

alias -g  B='`git branch -a  | fzf --prompt "All Branches>"    | head -n 1 | sed -e "s/^\*\s*//g"`'
alias -g RB='`git branch -r  | fzf --prompt "Remote Branches>" | head -n 1 | sed -e "s/^\*\s*//g"`'
alias -g LB='`git branch     | fzf --prompt "Local Branches>"  | head -n 1 | sed -e "s/^\*\s*//g"`'

function agvim () {
  vi $(ag $@ | peco --query "$LBUFFER" | awk -F : '{print $1 ":" $2}')
}

function iag() {
  vi $(ag --nobreak --noheading . | peco | awk -F: '{print $1 ":" $2}')
}

# nicovideo
function peco-nico-ranking() {
  ruby -r rss -e 'RSS::Parser.parse("http://www.nicovideo.jp/ranking/fav/daily/all?rss=2.0").channel.items.each {|item| puts item.link + "\t" + item.title}' | peco | while read line; do
  echo $line
  echo $line | awk '{print $1}' | nicovideo-dump | mplayer -
done
}

function peco-nico-tag() {
  TAG=`url-encode "$*"`
  ruby -r rss -e "RSS::Parser.parse(\"http://www.nicovideo.jp/tag/$TAG?rss=2.0\").channel.items.each {|item| puts item.link + \"\t\" + item.title}" | peco | while read line; do
  echo $line
  echo $line | awk '{print $1}' | nicovideo-dump | mplayer -
done
}

function peco-nico-bgm() {
  TAG=`url-encode "作業用BGM $*"`
  ruby -r rss -e "RSS::Parser.parse(\"http://www.nicovideo.jp/tag/$TAG?rss=2.0\").channel.items.each {|item| puts item.link + \"\t\" + item.title}" | peco | while read line; do
  echo $line
  echo $line | awk '{print $1}' | nicovideo-dump | mplayer - -novideo
done
}

# }}}

# misc {{{

# コマンドラインスタックを表示
show_buffer_stack() {
  POSTDISPLAY="
  stack: $LBUFFER"
  zle push-line
}
zle -N show_buffer_stack

# cdd
source ~/dotfiles/.zsh/cdd
chpwd_functions+=_cdd_chpwd

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
  last=$(echo -nE "$LBUFFER" | sed -e "s/.*[^_a-zA-Z0-9]\([_a-zA-Z0-9]*\)$/\1/")
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

neovim_autocd() {
  [[ $NVIM_LISTEN_ADDRESS ]] && neovim-autocd
}
chpwd_functions+=( neovim_autocd )

up-line-or-history-ignoring() {
zle up-line-or-history
case "$BUFFER" in
  fg|bg)
    zle up-line-or-history
    ;;
esac
}
zle -N up-line-or-history-ignoring

# }}}

# loading fzf {{{

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='ag -g ""'
export FZF_DEFAULT_OPTS='--reverse'

# }}}

# bindkey {{{

bindkey -e
bindkey "^ "   my-expand-abbrev
bindkey "^q"   show_buffer_stack
bindkey '^[n'  history-substring-search-down
bindkey '^[p'  history-substring-search-up
bindkey '^e'   end-of-line
bindkey '^r'   anyframe-widget-put-history
bindkey '^xk'  anyframe-widget-kill
bindkey '^xs'  emoji::cli
bindkey '^xt'  fzf-file-widget
bindkey '^z'   fancy-ctrl-z
bindkey '^p'   up-line-or-history-ignoring

# }}}

# local file {{{

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# }}}

# profile {{{

if (which zprof > /dev/null) ;then
  zprof | less
fi

# }}}

# vim:set et ts=2 sts=2 sw=2 fen fdm=marker:
