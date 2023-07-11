#!/usr/bin/env bash
# Usage: rbenv version-file [<dir>]
# Summary: Detect the file that sets the current rbenv version
#
# Detects and prints the location of a `.ruby-version` file that sets the
# version for the current working directory. If no file found, this prints
# the location of the global version file, even if that file does
# not exist.

set -e
[ -n "$RBENV_DEBUG" ] && set -x

target_dir="$1"

find_local_version_file() {
  local root="$1"
  while ! [[ "$root" =~ ^//[^/]*$ ]]; do
    if [ -s "${root}/.ruby-version" ]; then
      echo "${root}/.ruby-version"
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
  find_local_version_file "$RBENV_DIR" || {
    [ "$RBENV_DIR" != "$PWD" ] && find_local_version_file "$PWD"
  } || echo "${RBENV_ROOT}/version"
fi
