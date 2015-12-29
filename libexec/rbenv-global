#!/usr/bin/env bash
#
# Summary: Set or show the global Ruby version
#
# Usage: rbenv global <version>
#
# Sets the global Ruby version. You can override the global version at
# any time by setting a directory-specific version with `rbenv local'
# or by setting the `RBENV_VERSION' environment variable.
#
# <version> should be a string matching a Ruby version known to rbenv.
# The special version string `system' will use your default system Ruby.
# Run `rbenv versions' for a list of available Ruby versions.

set -e
[ -n "$RBENV_DEBUG" ] && set -x

# Provide rbenv completions
if [ "$1" = "--complete" ]; then
  echo system
  exec rbenv-versions --bare
fi

RBENV_VERSION="$1"
RBENV_VERSION_FILE="${RBENV_ROOT}/version"

if [ -n "$RBENV_VERSION" ]; then
  rbenv-version-file-write "$RBENV_VERSION_FILE" "$RBENV_VERSION"
else
  rbenv-version-file-read "$RBENV_VERSION_FILE" || echo system
fi
