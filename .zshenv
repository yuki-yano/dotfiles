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

# rbenv
eval "$(rbenv init -)"

# pyenv
export PATH=$HOME/.pyenv/bin:$PATH
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export PYTHON_CONFIGURE_OPTS="--enable-framework"

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

function current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

# gist
alias gist='gist -c -o -p'

# bundle
# alias bundle="nocorrect bundle"
alias be='bundle exec'

# homebrew
alias brew="env PATH=${PATH/${HOME}\/\.pyenv\/shims:/} brew"

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
function e (){
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
