_rbenv_commands() {
  local cur commands
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  commands="exec prefix rehash set-default set-local version versions\
    whence which"

  COMPREPLY=( $( compgen -W "$commands" -- $cur ) )
}

_rbenv_versions() {
  local cur versions
  local ROOT="${HOME}/.rbenv/versions"
  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  versions=($ROOT/*)
  # remove all but the final part of the name
  versions="${versions[@]##*/}"

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
