# vim: ft=sh
# https://github.com/m4i/cdd

if [ -z "$CDD_FILE" ]; then
  CDD_FILE=~/.cdd
fi
export CDD_FILE

if [ -z "$CDD_AUTO" ]; then
  CDD_AUTO=1
fi
export CDD_AUTO

CDD_SESSION=
CDD_WINDOW=
CDD_PANE=

if [ -n "$TMUX" ]; then
  _cdd_key="$(tmux display -p '#S,#I.#P')"
  _cdd_window_pane="${_cdd_key##*,}"
  CDD_SESSION="${_cdd_key%,*}"
  CDD_WINDOW="${_cdd_window_pane%%.*}"
  CDD_PANE="${_cdd_window_pane#*.}"
  if [[ $CDD_SESSION != *[^0-9]* ]]; then
    CDD_SESSION=_
  fi
  unset _cdd_key _cdd_window_pane

elif [ -n "$STY" ]; then
  _cdd_host="$(hostname)"
  CDD_SESSION="${STY#*.}"
  if echo "$CDD_SESSION" | grep "^[^.]\+\.${_cdd_host%%.*}$" >/dev/null; then
    CDD_SESSION=_
  fi
  CDD_WINDOW="$WINDOW"
  CDD_PANE=0
  unset _cdd_host
fi

CDD_SESSION="$(echo "$CDD_SESSION" | sed 's/:/_/g')"
export CDD_SESSION CDD_WINDOW CDD_PANE


cdd() {
  if [ $# -eq 0 ]; then
    _cdd_cd last
    return $?
  fi

  case "$1" in
    help|--help|-h)
      _cdd_help
      return
      ;;
    add)
      if [ $# -eq 2 -o $# -eq 3 ]; then
        _cdd_add "$2" "$3"
        return $?
      fi
      ;;
    delete)
      if [ $# -eq 2 ]; then
        _cdd_delete "$2"
        return $?
      fi
      ;;
    *)
      if [ $# -eq 1 ]; then
        _cdd_cd "$1"
        return $?
      fi
  esac

  _cdd_help
  return 1
}


_cdd_chpwd() {
  (($CDD_AUTO)) || return

  if [ -n "$CDD_WINDOW" ]; then
    _cdd_register "$CDD_SESSION,$CDD_WINDOW.$CDD_PANE" "$PWD"
  fi
  _cdd_register last "$PWD"
}

# for compatibility with original cdd
alias _reg_pwd_screennum=_cdd_chpwd


_cdd_help() {
  cat <<'__EOT__' >&2
Usage:
  cdd [last]                    move to the last directory
  cdd <key>                     move to the <key> directory
  cdd add <key> [directory]     add the directory to $CDD_FILE
  cdd delete <key>              delete the directory from $CDD_FILE
  cdd help|--help|-h            print this help message

__EOT__
  if [ -f "$CDD_FILE" ]; then
    sort "$CDD_FILE" >&2
  fi
}


_cdd_cd() {
  if [ ! -f "$CDD_FILE" ]; then
    echo "cdd: $CDD_FILE: No such file" >&2
    return 2
  fi

  local key="$(_cdd_canonicalize_key "$1")"

  local match="$(grep "^$key:" "$CDD_FILE")"
  if [ -n "$match" ]; then
    local dir="${match##*:}"
    echo "cd $dir"
    cd "$(echo "$dir" | sed "s;^~;$HOME;")"

  else
    echo "cdd: $key: No such key"$'\n' >&2
    _cdd_help
    return 3
  fi
}


_cdd_add() {
  local key="${1%%:*}"
  local dir="$2"

  local _dir
  if [ -n "$dir" ]; then
    local _cdd_auto="$CDD_AUTO"
    CDD_AUTO=0
    _dir="$(cd "$dir" >/dev/null 2>&1 && pwd)"; result=$?
    CDD_AUTO="$_cdd_auto"
    if [ "$result" -ne 0 ]; then
      echo "cdd: can not cd $dir"$'\n' >&2
      _cdd_help
      return 4
    fi
  else
    _dir="$PWD"
  fi

  _cdd_register "$key" "$_dir"
}


_cdd_delete() {
  if [ ! -f "$CDD_FILE" ]; then
    echo "cdd: $CDD_FILE: No such file" >&2
    return 2
  fi

  local key="$(_cdd_canonicalize_key "$1")"

  if grep "^$key:" "$CDD_FILE" >/dev/null; then
    sed -i.tmp -e "/^$key\:/d" "$CDD_FILE"
    rm -f "$CDD_FILE.tmp"
  else
    echo "cdd: $key: No such key"$'\n' >&2
    _cdd_help
    return 3
  fi
}


_cdd_canonicalize_key() {
  local key="${1%%:*}"

  if echo "$key" | grep '^\(.\+,\)\?[0-9]\+\.\?$' >/dev/null; then
    if [[ $key != *. ]]; then
      key="$key."
    fi
    key="${key}0"
  fi
  if echo "$key" | grep '^[0-9]\+.[0-9]\+$' >/dev/null; then
    key="${CDD_SESSION:-_},$key"
  fi

  echo "$key"
}


_cdd_register() {
  local key="$1"
  local dir="$2"

  if [ -f "$CDD_FILE" ]; then
    sed -i.tmp -e "/^$key\:/d" "$CDD_FILE"
    rm -f "$CDD_FILE.tmp"
  else
    touch "$CDD_FILE"
  fi

  dir="$(echo "$dir" | sed "s;^$HOME;~;")"
  echo "$key:$dir" >>"$CDD_FILE"
}


_cdd_comp() {
  local mode="$1"
  local -i CURRENT="$2"
  local command="$3"

  [ -f "$CDD_FILE" ] || return

  if (( CURRENT == 3 )) && [[ $command = delete ]] || (( CURRENT == 2 )); then
    _cdd_opts="$(sed "s/^${CDD_SESSION:-_},//" "$CDD_FILE")"
    _cdd_descr='cdd directory'

    if [ "$mode" = zsh ]; then
      _cdd_opts="$(echo "$_cdd_opts" | sed 's/\.0:/:/')"
    fi

  elif (( CURRENT == 3 )) && [[ $command = add ]]; then
    _cdd_opts="$(grep -v '^[^:]\+,[0-9]\+\.[0-9]\+:\|^last:' "$CDD_FILE")"
    _cdd_descr='cdd key'
  fi
}


if [ -n "$ZSH_VERSION" ]; then

  _cdd() {
    typeset -A opt_args
    local context state line

    _arguments '*: :->args' && return
    [[ $state = args ]] || return

    local command="$line[1]"
    local _cdd_opts= _cdd_descr= ret=1
    local -a opts

    _cdd_comp zsh "$CURRENT" "$command"
    if [ -n "$_cdd_opts" ]; then
      local _ifs="$IFS"
      IFS=$'\n'
      opts=($(echo "$_cdd_opts"))
      IFS="$_ifs"
      _describe "$_cdd_descr" opts && ret=0
    fi

    if (( CURRENT == 2 )); then
      local _cdd_file="$(echo "$CDD_FILE" | sed "s;^$HOME;~;")"
      opts=(
        "add:add the directory to $_cdd_file"
        "delete:delete the directory from $_cdd_file"
      )
      _describe -t commands 'cdd command' opts && ret=0

    elif (( CURRENT == 4 )) && [[ $command = add ]]; then
      _path_files -/ 'directory' && ret=0
    fi

    return ret
  }
  compdef _cdd cdd

elif [ -n "$BASH_VERSION" ]; then

  _cdd() {
    COMPREPLY=()
    local -i CURRENT=$(($COMP_CWORD + 1))
    local command="${COMP_WORDS[1]}"
    local _cdd_opts= _cdd_descr=
    local cur="${COMP_WORDS[COMP_CWORD]}"

    _cdd_comp bash "$CURRENT" "$command"
    if [ -n "$_cdd_opts" ]; then
      _cdd_opts="$(echo "$_cdd_opts" | sed -e 's/ /\\\\ /g' -e 's/$/ /')"
    fi

    if (( CURRENT == 2 )); then
      _cdd_opts="$_cdd_opts"$'\n''add '$'\n''delete '

    elif [[ $command = add ]]; then
      # cdd add foo:/foo =>
      #   "cdd" "add" "foo" ":" "/foo" ||
      #   "cdd" "add" "foo:/foo"
      if (( CURRENT == 6 )) && [[ ${COMP_WORDS[3]} = : ]] || \
         (( CURRENT == 4 )); then
        cur="$(echo "$cur" | sed "s;^~;$HOME;")"
        _cdd_opts="$(compgen -d "$cur" | sed -e 's/ /\\\\ /g' -e 's;$;/;')"
      fi
    fi

    if [ -n "$_cdd_opts" ]; then
      local IFS=$'\n'
      COMPREPLY=($(compgen -W "$_cdd_opts" -- "$cur"))
    fi
  }
  complete -F _cdd -o nospace cdd

fi
