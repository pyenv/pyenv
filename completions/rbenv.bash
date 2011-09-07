_rbenv_commands() {
  COMPREPLY=()
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $( compgen -W "$(rbenv commands)" -- $cur ) )
}

_rbenv_versions() {
  COMPREPLY=()
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local versions="$(echo system; rbenv versions --bare)"
  COMPREPLY=( $( compgen -W "$versions" -- $cur ) )
}

_rbenv() {
  COMPREPLY=()
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  case "$prev" in
  set-* | global | local | shell | prefix )
    _rbenv_versions
    ;;
  * )
    _rbenv_commands
    ;;
  esac
}

complete -F _rbenv rbenv
