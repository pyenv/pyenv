#!/usr/bin/env bash
# Usage: rbenv completions <command> [<args>...]

set -e
[ -n "$RBENV_DEBUG" ] && set -x

COMMAND="$1"
if [ -z "$COMMAND" ]; then
  rbenv-help --usage completions >&2
  exit 1
fi

# Provide rbenv completions
if [ "$COMMAND" = "--complete" ]; then
  exec rbenv-commands
fi

COMMAND_PATH="$(type -P "rbenv-$COMMAND" "rbenv-sh-$COMMAND" | head -n1)"

# --help is provided automatically
echo --help

if grep -iE "^([#%]|--|//) provide rbenv completions" "$COMMAND_PATH" >/dev/null; then
  shift
  exec "$COMMAND_PATH" --complete "$@"
fi
