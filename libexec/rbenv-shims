#!/usr/bin/env bash
# Summary: List existing rbenv shims
# Usage: rbenv shims [--short]

set -e
[ -n "$RBENV_DEBUG" ] && set -x

# Provide rbenv completions
if [ "$1" = "--complete" ]; then
  echo --short
  exit
fi

shopt -s nullglob

for command in "${RBENV_ROOT}/shims/"*; do
  if [ "$1" = "--short" ]; then
    echo "${command##*/}"
  else
    echo "$command"
  fi
done | sort
