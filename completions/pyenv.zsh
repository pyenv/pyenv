#compdef pyenv

_pyenv() {
  local -a comples
  if [ "${#words}" -eq 2 ]; then
    comples=($(pyenv commands))
  else
    comples=($(pyenv completions ${words[2,-2]}))
  fi
  _describe -t comples 'comples' comples
}

_pyenv
