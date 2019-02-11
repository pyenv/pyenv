#!/usr/bin/env bash
# Summary: List all Python versions that contain the given executable
# Usage: pyenv whence [--path] <command>

set -e
[ -n "$PYENV_DEBUG" ] && set -x

# Provide pyenv completions
if [ "$1" = "--complete" ]; then
  echo --path
  exec pyenv-shims --short
fi

if [ "$1" = "--path" ]; then
  print_paths="1"
  shift
else
  print_paths=""
fi

whence() {
  local command="$1"
  pyenv-versions --bare | while read -r version; do
    path="$(pyenv-prefix "$version")/bin/${command}"
    if [ -x "$path" ]; then
      [ "$print_paths" ] && echo "$path" || echo "$version"
    fi
  done
}

PYENV_COMMAND="$1"
if [ -z "$PYENV_COMMAND" ]; then
  pyenv-help --usage whence >&2
  exit 1
fi

result="$(whence "$PYENV_COMMAND")"
[ -n "$result" ] && echo "$result"
