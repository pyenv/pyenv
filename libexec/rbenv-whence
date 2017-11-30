#!/usr/bin/env bash
# Summary: List all Ruby versions that contain the given executable
# Usage: rbenv whence [--path] <command>

set -e
[ -n "$RBENV_DEBUG" ] && set -x

# Provide rbenv completions
if [ "$1" = "--complete" ]; then
  echo --path
  exec rbenv-shims --short
fi

if [ "$1" = "--path" ]; then
  print_paths="1"
  shift
else
  print_paths=""
fi

whence() {
  local command="$1"
  rbenv-versions --bare | while read -r version; do
    path="$(rbenv-prefix "$version")/bin/${command}"
    if [ -x "$path" ]; then
      [ "$print_paths" ] && echo "$path" || echo "$version"
    fi
  done
}

RBENV_COMMAND="$1"
if [ -z "$RBENV_COMMAND" ]; then
  rbenv-help --usage whence >&2
  exit 1
fi

result="$(whence "$RBENV_COMMAND")"
[ -n "$result" ] && echo "$result"
