if [[ -z $IN_CAGE ]]; then
  export HOMEBREW_PREFIX=/opt/homebrew
  export HOMEBREW_CELLAR=/opt/homebrew/Cellar
  export HOMEBREW_REPOSITORY=/opt/homebrew
fi

source ~/.orbstack/shell/init.zsh 2>/dev/null || :
