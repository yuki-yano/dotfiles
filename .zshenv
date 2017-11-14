# profile
# zmodload zsh/zprof && zprof

# 言語
export LANG=ja_JP.UTF-8

# エディタ
export EDITOR=nvim
alias c=ccat
alias ri="richpager -s solarizeddark"
export LESS='-R'
export LESSOPEN='|pygmentize %s'

# path_helperを実行しないようにする
# show: http://qiita.com/t-takaai/items/8574ff312f2caa5177c2
setopt no_global_rcs

# default path
export PATH=$HOME/dotfiles/bin:$HOME/dotfiles/vendor/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin
# Play
export PATH=$PATH:$HOME/.play
# node.js
export PATH=$PATH:$HOME/dotfiles/node_modules/.bin
# powerline
export PATH=$PATH:~/.local/bin

# Lazy Load
# show: https://github.com/xcv58/prezto/tree/master/modules/lazy-load
#       https://gist.github.com/QinMing/364774610afc0e06cc223b467abe83c0
lazy_load() {
  local load_func=${1}
  local lazy_func="lazy_${load_func}"
  shift 1

  local -a names
  names=("${(@s: :)${1}}")

  for i in $names; do
    alias ${i}="${lazy_func} ${i}"
  done

  eval "
  function ${lazy_func}() {
  unset -f ${lazy_func}
  lazy_load_clean $@
  eval ${load_func}
  unset -f ${load_func}
  eval \$@
}
"
}

lazy_load_clean() {
  for i in ${@}; do
    # alias vi='nvim' だけは有効にしておく
    if [ ${i} != 'vi' ]; then
      unalias ${i}
    fi
  done
}

# rbenv
lazy_load rbenv "ruby vi vim nvim $(ls ~/dotfiles/vendor/bin/ | tr '\n' ' ')"
rbenv() {
  eval "$(command rbenv init -)"
}

# python
export PATH=/usr/local/opt/python/libexec/bin:$PATH

# nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# go
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$HOME/.ghg/bin

# heroku
export PATH=$PATH:/usr/local/heroku/bin

# vim
alias vi='nvim'
alias vr='nvr'
alias s='NVIM_LISTEN_ADDRESS=/tmp/nvimsocket$RANDOM nvim +terminal'
export PATH=$PATH:$HOME/.vim/plugged/vim-superman/bin

# eslint-friendly-formatter
export EFF_NO_GRAY=true

# ls
alias ll='ls -l'
alias la='ls -al'

# less
export LESS='-iMRj.5'
export LESS_TERMCAP_mb=$(tput bold)                # begin blinking
export LESS_TERMCAP_md=$(tput bold; tput setaf 4)  # begin bold (blue)
export LESS_TERMCAP_me=$(tput sgr0)                # end mode
export LESS_TERMCAP_se=$(tput sgr0)                # end standout-mode
export LESS_TERMCAP_so=$(tput setaf 3; tput rev)   # begin standout-mode (yellow)
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)     # end underline
export LESS_TERMCAP_us=$(tput smul; tput setaf 2)  # begin underline (green)

# sed
alias sed=gsed

# cd
alias u='cd ..'
alias uu='cd ../..'
alias uuu='cd ../../..'
alias uuuu='cd ../../../..'

# popd
alias p='popd'

# yes
alias y='yes'

# updatedb
alias updatedb=/usr/libexec/locate.updatedb

# ruby
alias be='bundle exec'

# git alias
if whence hub > /dev/null; then
  alias git='nocorrect hub'
fi
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gs='git status -s'
alias gb='git branch'
alias gd='git diff'
alias gdc='git diff --cached'
alias gco='git checkout'
alias gci='git commit'
alias gn='git now --all --stat'
alias agit='vim +Agit'
alias gitt='gittower .'

function gwt() {
  GIT_CDUP_DIR=`git rev-parse --show-cdup`
  git worktree add ${GIT_CDUP_DIR}git-worktrees/$1 -b $1
}

# bundle
# alias bundle="nocorrect bundle"
alias be='bundle exec'

# diff
alias diff='diff -u'
export VIM_TMP=/tmp/vim.tmp
alias -g V="> $VIM_TMP$$; vim $VIM_TMP$$"

# direnv
if whence direnv > /dev/null; then
  _direnv_hook() {
    eval "$(direnv export zsh)";
  }
  typeset -ag precmd_functions;
  if [[ -z ${precmd_functions[(r)_direnv_hook]} ]]; then
    precmd_functions+=_direnv_hook;
  fi
fi

# grep
alias -g G='| grep'

# pbcopy
alias -g C='| pbcopy'

# emacsclient
function e() {
  emacsclient -n $* &
}

# git-foresta
function gifo() {
  git-foresta --style=10 "$@" | less -RSX
}
function gifa() {
  git-foresta --all --style=10 "$@" | less -RSX
}

# config
[ -f ~/.config/nicovideo-dump.zsh ] && source ~/.config/nicovideo-dump.zsh

# vim:set et ts=2 sts=2 sw=2 fen fdm=marker:
