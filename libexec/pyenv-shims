#!/usr/bin/env bash
# Summary: List existing pyenv shims
# Usage: pyenv shims [--short]

set -e
[ -n "$PYENV_DEBUG" ] && set -x

# Provide pyenv completions
if [ "$1" = "--complete" ]; then
  echo --short
  exit
fi

shopt -s nullglob

for command in "${PYENV_ROOT}/shims/"*; do
  if [ "$1" = "--short" ]; then
    echo "${command##*/}"
  else
    echo "$command"
  fi
done | sort
