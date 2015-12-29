#!/usr/bin/env bash
#
# Summary: Set or show the local application-specific Ruby version
#
# Usage: rbenv local <version>
#        rbenv local --unset
#
# Sets the local application-specific Ruby version by writing the
# version name to a file named `.ruby-version'.
#
# When you run a Ruby command, rbenv will look for a `.ruby-version'
# file in the current directory and each parent directory. If no such
# file is found in the tree, rbenv will use the global Ruby version
# specified with `rbenv global'. A version specified with the
# `RBENV_VERSION' environment variable takes precedence over local
# and global versions.
#
# <version> should be a string matching a Ruby version known to rbenv.
# The special version string `system' will use your default system Ruby.
# Run `rbenv versions' for a list of available Ruby versions.

set -e
[ -n "$RBENV_DEBUG" ] && set -x

# Provide rbenv completions
if [ "$1" = "--complete" ]; then
  echo --unset
  echo system
  exec rbenv-versions --bare
fi

RBENV_VERSION="$1"

if [ "$RBENV_VERSION" = "--unset" ]; then
  rm -f .ruby-version
elif [ -n "$RBENV_VERSION" ]; then
  rbenv-version-file-write .ruby-version "$RBENV_VERSION"
else
  if version_file="$(rbenv-version-file "$PWD")"; then
    rbenv-version-file-read "$version_file"
  else
    echo "rbenv: no local version configured for this directory" >&2
    exit 1
  fi
fi
