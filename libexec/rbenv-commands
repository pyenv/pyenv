#!/usr/bin/env bash
# Summary: List all available rbenv commands
# Usage: rbenv commands [--sh|--no-sh]
#
# List names of all rbenv commands, including 3rd-party ones found in the
# PATH or in rbenv plugins. With `--sh`, list only shell commands.
#
# This functionality is mainly meant for scripting. To see usage help for
# rbenv, run `rbenv help`.

set -e
[ -n "$RBENV_DEBUG" ] && set -x

# Provide rbenv completions
if [ "$1" = "--complete" ]; then
  echo --sh
  echo --no-sh
  exit
fi

exclude_shell=
command_prefix="rbenv-"

if [ "$1" = "--sh" ]; then
  command_prefix="rbenv-sh-"
  shift
elif [ "$1" = "--no-sh" ]; then
  exclude_shell=1
  shift
fi

shopt -s nullglob

{
  PATH_remain="$PATH"
  # traverse PATH to find "rbenv-" prefixed commands
  while true; do
    path="${PATH_remain%%:*}"
    if [ -n "$path" ]; then
      for rbenv_command in "${path}/${command_prefix}"*; do
        rbenv_command="${rbenv_command##*rbenv-}"
        if [[ -z $exclude_shell || $rbenv_command != sh-* ]]; then
          echo "${rbenv_command##sh-}"
        fi
      done
    fi
    [[ $PATH_remain == *:* ]] || break
    PATH_remain="${PATH_remain#*:}"
  done
} | sort | uniq
