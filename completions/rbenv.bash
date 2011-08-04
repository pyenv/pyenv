_rbenv_commands() {
  COMPREPLY=()
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $( compgen -W "$(rbenv commands)" -- $cur ) )
}

_rbenv_versions() {
  COMPREPLY=()
  local cur=${COMP_WORDS[COMP_CWORD]}
  local versions=(system $(rbenv versions --bare))
  versions="${versions[@]}"

  COMPREPLY=( $( compgen -W "$versions" -- $cur ) )
}

_rbenv() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [ "$prev" = "set-default" ]; then
    _rbenv_versions
  else
    _rbenv_commands
  fi
}

complete -F _rbenv rbenv
