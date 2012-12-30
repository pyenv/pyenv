#!/usr/bin/env bash
# Usage: rbenv version-file-write <file> <version>

set -e
[ -n "$RBENV_DEBUG" ] && set -x

RBENV_VERSION_FILE="$1"
RBENV_VERSION="$2"

if [ -z "$RBENV_VERSION" ] || [ -z "$RBENV_VERSION_FILE" ]; then
  rbenv-help --usage version-file-write >&2
  exit 1
fi

# Make sure the specified version is installed.
rbenv-prefix "$RBENV_VERSION" >/dev/null

# Write the version out to disk.
echo "$RBENV_VERSION" > "$RBENV_VERSION_FILE"
