#!/usr/bin/env bash
# Usage: pyenv version-file [<dir>]
# Summary: Detect the file that sets the current pyenv version
set -e
[ -n "$PYENV_DEBUG" ] && set -x

target_dir="$1"

find_local_version_file() {
  local root="$1"
  while ! [[ "$root" =~ ^//[^/]*$ ]]; do
    if [ -f "${root}/.python-version" ]; then
      echo "${root}/.python-version"
      return 0
    fi
    [ -n "$root" ] || break
    root="${root%/*}"
  done
  return 1
}

if [ -n "$target_dir" ]; then
  find_local_version_file "$target_dir"
else
  find_local_version_file "$PYENV_DIR" || {
    [ "$PYENV_DIR" != "$PWD" ] && find_local_version_file "$PWD"
  } || echo "${PYENV_ROOT}/version"
fi
