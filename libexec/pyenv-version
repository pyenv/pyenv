#!/usr/bin/env bash
# Summary: Show the current Python version(s) and its origin
# Usage: pyenv version [--bare]
#
#     --bare    show just the version name. An alias to `pyenv version-name'

set -e
[ -n "$PYENV_DEBUG" ] && set -x

exitcode=0
OLDIFS="$IFS"
IFS=: PYENV_VERSION_NAMES=($(pyenv-version-name)) || exitcode=$?
IFS="$OLDIFS"

unset bare
for arg; do
    case "$arg" in
        --complete )
            echo --bare
            exit ;;
        --bare ) bare=1 ;;
        * )
          pyenv-help --usage version >&2
          exit 1
          ;;
    esac
done
for PYENV_VERSION_NAME in "${PYENV_VERSION_NAMES[@]}"; do
  if [[ -n $bare ]]; then
      echo "$PYENV_VERSION_NAME"
  else
      echo "$PYENV_VERSION_NAME (set by $(pyenv-version-origin))"
  fi
done

exit $exitcode
