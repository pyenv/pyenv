#!/usr/bin/env bash
#
# Summary: Run an executable with the selected Python version
#
# Usage: pyenv exec <command> [arg1 arg2...]
#
# Runs an executable by first preparing PATH so that the selected Python
# version's `bin' directory is at the front.
#
# For example, if the currently selected Python version is 2.7.6:
#   pyenv exec pip install -r requirements.txt
#
# is equivalent to:
#   PATH="$PYENV_ROOT/versions/2.7.6/bin:$PATH" pip install -r requirements.txt

set -e
[ -n "$PYENV_DEBUG" ] && set -x

# Provide pyenv completions
if [ "$1" = "--complete" ]; then
  exec pyenv-shims --short
fi

PYENV_VERSION="$(pyenv-version-name -f)"
PYENV_COMMAND="$1"

if [ -z "$PYENV_COMMAND" ]; then
  pyenv-help --usage exec >&2
  exit 1
fi

PYENV_COMMAND_PATH="$(pyenv-which "$PYENV_COMMAND")"
PYENV_BIN_PATH="${PYENV_COMMAND_PATH%/*}"
export PYENV_VERSION

OLDIFS="$IFS"
IFS=$'\n' scripts=(`pyenv-hooks exec`)
IFS="$OLDIFS"
for script in "${scripts[@]}"; do
  source "$script"
done

shift 1
if [ "${PYENV_BIN_PATH#${PYENV_ROOT}}" != "${PYENV_BIN_PATH}" ]; then
  # Only add to $PATH for non-system version.
  export PATH="${PYENV_BIN_PATH}:${PATH}"
fi
exec "$PYENV_COMMAND_PATH" "$@"
