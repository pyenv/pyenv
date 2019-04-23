#!/usr/bin/env bash
# Summary: List all available pyenv commands
# Usage: pyenv commands [--sh|--no-sh]

set -e
[ -n "$PYENV_DEBUG" ] && set -x

# Provide pyenv completions
if [ "$1" = "--complete" ]; then
  echo --sh
  echo --no-sh
  exit
fi

if [ "$1" = "--sh" ]; then
  sh=1
  shift
elif [ "$1" = "--no-sh" ]; then
  nosh=1
  shift
fi

IFS=: paths=($PATH)

shopt -s nullglob

{ for path in "${paths[@]}"; do
    for command in "${path}/pyenv-"*; do
      command="${command##*pyenv-}"
      if [ -n "$sh" ]; then
        if [ "${command:0:3}" = "sh-" ]; then
          echo "${command##sh-}"
        fi
      elif [ -n "$nosh" ]; then
        if [ "${command:0:3}" != "sh-" ]; then
          echo "${command##sh-}"
        fi
      else
        echo "${command##sh-}"
      fi
    done
  done
} | sort | uniq
