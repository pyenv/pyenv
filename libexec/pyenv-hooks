#!/usr/bin/env bash
# Summary: List hook scripts for a given pyenv command
# Usage: pyenv hooks <command>

set -e
[ -n "$PYENV_DEBUG" ] && set -x

# Provide pyenv completions
if [ "$1" = "--complete" ]; then
  echo exec
  echo rehash
  echo version-name
  echo version-origin
  echo which
  exit
fi

PYENV_COMMAND="$1"
if [ -z "$PYENV_COMMAND" ]; then
  pyenv-help --usage hooks >&2
  exit 1
fi

if ! enable -f "${BASH_SOURCE%/*}"/pyenv-realpath.dylib realpath 2>/dev/null; then
  if [ -n "$PYENV_NATIVE_EXT" ]; then
    echo "pyenv: failed to load \`realpath' builtin" >&2
    exit 1
  fi
READLINK=$(type -P readlink)
if [ -z "$READLINK" ]; then
  echo "pyenv: cannot find readlink - are you missing GNU coreutils?" >&2
  exit 1
fi

resolve_link() {
  $READLINK "$1"
}

realpath() {
  local path="$1"
  local name
  # Use a subshell to avoid changing the current path
  (
  while [ -n "$path" ]; do
    name="${path##*/}"
    [ "$name" = "$path" ] || cd "${path%/*}"
    path="$(resolve_link "$name" || true)"
  done

  echo "${PWD}/$name"
  )
}
fi

IFS=: hook_paths=($PYENV_HOOK_PATH)

shopt -s nullglob
for path in "${hook_paths[@]}"; do
  for script in "$path/$PYENV_COMMAND"/*.bash; do
    realpath "$script"
  done
done
shopt -u nullglob
