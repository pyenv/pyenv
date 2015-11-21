#!/usr/bin/env bash
# Usage: pyenv completions <command> [arg1 arg2...]

set -e
[ -n "$PYENV_DEBUG" ] && set -x

COMMAND="$1"
if [ -z "$COMMAND" ]; then
  pyenv-help --usage completions >&2
  exit 1
fi

# Provide pyenv completions
if [ "$COMMAND" = "--complete" ]; then
  exec pyenv-commands
fi

COMMAND_PATH="$(command -v "pyenv-$COMMAND" || command -v "pyenv-sh-$COMMAND")"

# --help is provided automatically
echo --help

if grep -iE "^([#%]|--|//) provide pyenv completions" "$COMMAND_PATH" >/dev/null; then
  shift
  exec "$COMMAND_PATH" --complete "$@"
fi
