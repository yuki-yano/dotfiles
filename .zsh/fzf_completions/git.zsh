#! /usr/bin/zsh

function _fzf-git-completion() {
  local tokens cmd1 cmd2 cmd3 cmd4 cmd5
  setopt localoptions noshwordsplit
  tokens=(${(z)LBUFFER})
  cmd1=${tokens[1]}
  cmd2=${tokens[2]}
  cmd3=${tokens[3]}
  cmd4=${tokens[4]}
  cmd5=${tokens[5]}

  case "$cmd1" in
    git)
      case "$cmd2" in
        add)
          case "$cmd3" in
            '')
              _fzf_complete_git_add_file
              return
              ;;
          esac
          ;;
        reset)
          case "$cmd3" in
            --soft|--hard)
              case "$cmd4" in
                '')
                  _fzf_complete_git_branch
                  return
                  ;;
                --)
                  case "$cmd5" in
                    '')
                      _fzf_complete_git_reset_file
                  esac
                  ;;
              esac
              ;;
            '')
              _fzf_complete_git_branch
              return
              ;;
            --)
              case "$cmd5" in
                '')
                  _fzf_complete_git_reset_file
              esac
              ;;
            [a-zA-Z]* )
              case "$cmd4" in
                '')
                  _fzf_complete_git_reset_file
                  return
                  ;;
                --)
                  case "$cmd5" in
                    '')
                      _fzf_complete_git_reset_file
                      return
                      ;;
                  esac
                  ;;
              esac
              ;;
          esac
          ;;
        checkout)
          case "$cmd3" in
            -b|-t)
              case "$cmd4" in
                '')
                  _fzf_complete_git_branch
                  return
                  ;;
              esac
              ;;
            --)
              case "$cmd4" in
                '')
                  _fzf_complete_git_file
                  return
                  ;;
              esac
              ;;
            [a-zA-Z]*)
              case "$cmd4" in
                '')
                  _fzf_complete_git_file
                  return
                  ;;
                '--')
                  case "$cmd5" in
                    '')
                      _fzf_complete_git_file
                      return
                      ;;
                  esac
                  ;;
              esac
              ;;
            '')
              _fzf_complete_git_branch
              return
              ;;
          esac
          ;;
        unstage)
          case "$cmd3" in
            '')
              _fzf_complete_git_reset_file
              return
          esac
          ;;
        forget)
          case "$cmd3" in
            '')
              _fzf_complete_git_file
              return
          esac
          ;;
        recover)
          case "$cmd3" in
            '')
              _fzf_complete_git_reset_file
              return
          esac
          ;;
      esac
      ;;
  esac
  zle expand-or-complete
}

zle -N fzf-git-completion _fzf-git-completion

function _fzf_complete_git_file() {
  local files
  files=$(git status --short | awk '{ print $2 }')
  FZF_COMPLETION_OPTS='--multi --height 80% --prompt "Git Files>" --preview "git diff --color=always {}" --bind ctrl-d:preview-page-down,ctrl-u:preview-page-up,?:toggle-preview'
  _fzf_complete '' "$BUFFER" < <(
  echo $files
  )
}

function _fzf_complete_git_add_file() {
  local add_files
  add_files=$(git status --short | awk '{if (substr($0,2,1) !~ / /) print $0}')
  FZF_COMPLETION_OPTS='--multi --height 80% --prompt "Git Add Files>" --preview "git diff --color=always $(echo {} | awk '\''{if (substr($0,2,1) !~ / /) print $2}'\'')" --bind ctrl-d:preview-page-down,ctrl-u:preview-page-up,?:toggle-preview'
  _fzf_complete '' "$BUFFER" < <(
  echo $add_files
  )
}

function _fzf_complete_git_add_file_post() {
  awk '{if (substr($0,2,1) !~ / /) print $2}'
}

function _fzf_complete_git_reset_file() {
  local reset_files
  reset_files=$(git status --short | awk '{if (substr($0,1,1) ~ /M|A|D/) print $0}')
  FZF_COMPLETION_OPTS='--multi --height 80% --prompt "Git Reset Files>" --preview "git diff --cached --color=always $(echo {} | awk '\''{if (substr($0,1,1) ~ /M|A|D/) print $2}'\'')" --bind ctrl-d:preview-page-down,ctrl-u:preview-page-up,?:toggle-preview'
  _fzf_complete '' "$BUFFER" < <(
  echo $reset_files
  )
}

function _fzf_complete_git_reset_file_post() {
  awk '{if (substr($0,1,1) ~ /M|A|D/) print $2}'
}

function _fzf_complete_git_branch() {
  local branches
  branches=$(git branch -vv --all)
  FZF_COMPLETION_OPTS='--reverse --preview="git plog $(echo {} | awk '\''{ if ($1 != \"*\") print $1; else print $2 }'\'') --graph --color=always 2>/dev/null" --bind ctrl-d:preview-page-down,ctrl-u:preview-page-up,?:toggle-preview'
  _fzf_complete '' "$BUFFER" < <(
  echo $branches
  )
}

function _fzf_complete_git_branch_post() {
  awk '{if ($1 == "*") print "HEAD"; else print $1;}'
}
