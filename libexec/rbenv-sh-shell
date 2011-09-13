#!/usr/bin/env bash
set -e
[ -n "$RBENV_DEBUG" ] && set -x

# Provide rbenv completions
if [ "$1" = "--complete" ]; then
  echo --unset
  echo system
  exec rbenv-versions --bare
fi

version="$1"

if [ -z "$version" ]; then
  if [ -z "$RBENV_VERSION" ]; then
    echo "rbenv: no shell-specific version configured" >&2
    exit 1
  else
    echo "echo \"\$RBENV_VERSION\""
    exit
  fi
fi

if [ "$version" = "--unset" ]; then
  echo "unset RBENV_VERSION"
  exit 1
fi

# Make sure the specified version is installed.
rbenv-prefix "$version" >/dev/null

echo "export RBENV_VERSION=\"${version}\""
