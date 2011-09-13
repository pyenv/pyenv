_rbenv() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(rbenv commands)" -- "$word") )
  else
    local command="${COMP_WORDS[1]}"
    local completions="$(rbenv completions "$command")"
    COMPREPLY=( $(compgen -W "$completions" -- "$word") )
  fi
}

complete -F _rbenv rbenv
