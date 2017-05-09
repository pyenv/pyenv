#!/usr/bin/env bash

set -e
[ -n "$PYENV_DEBUG" ] && set -x

# Remove pyenv-pip-rehash/libexec from PATH to avoid infinite loops in `pyenv-which` (yyuu/pyenv#146)
_PATH=":${PATH}:"
_HERE="$(dirname "${BASH_SOURCE[0]}")" # remove this from PATH
_PATH="${_PATH//:${_HERE}:/:}"
_PATH="${_PATH#:}"
_PATH="${_PATH%:}"
PATH="${_PATH}"

PYENV_COMMAND_PATH="$(pyenv-which "${PYENV_REHASH_REAL_COMMAND}")"
PYENV_BIN_PATH="${PYENV_COMMAND_PATH%/*}"

export PATH="${PYENV_BIN_PATH}:${PATH}"

STATUS=0
"$PYENV_COMMAND_PATH" "$@" || STATUS="$?"

# Run `pyenv-rehash` after a successful installation.
if [ "$STATUS" == "0" ]; then
  for piparg in "$@"; do
    case ${piparg} in
    "install" | "uninstall" ) pyenv-rehash ; break;;
    esac
  done
fi

exit "$STATUS"
