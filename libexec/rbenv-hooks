#!/usr/bin/env bash
# Summary: List hook scripts for a given rbenv command
# Usage: rbenv hooks <command>

set -e
[ -n "$RBENV_DEBUG" ] && set -x

# Provide rbenv completions
if [ "$1" = "--complete" ]; then
  echo exec
  echo rehash
  echo version-name
  echo version-origin
  echo which
  exit
fi

RBENV_COMMAND="$1"
if [ -z "$RBENV_COMMAND" ]; then
  rbenv-help --usage hooks >&2
  exit 1
fi

IFS=: read -r -a hook_paths <<<"$RBENV_HOOK_PATH"

shopt -s nullglob
for path in "${hook_paths[@]}"; do
  for script in "$path/$RBENV_COMMAND"/*.bash; do
    echo "$script"
  done
done
shopt -u nullglob
