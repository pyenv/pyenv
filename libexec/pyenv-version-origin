#!/usr/bin/env bash
# Summary: Explain how the current Python version is set
set -e
[ -n "$PYENV_DEBUG" ] && set -x

unset PYENV_VERSION_ORIGIN

OLDIFS="$IFS"
IFS=$'\n' scripts=(`pyenv-hooks version-origin`)
IFS="$OLDIFS"
for script in "${scripts[@]}"; do
  source "$script"
done

if [ -n "$PYENV_VERSION_ORIGIN" ]; then
  echo "$PYENV_VERSION_ORIGIN"
elif [ -n "$PYENV_VERSION" ]; then
  echo "PYENV_VERSION environment variable"
else
  pyenv-version-file
fi
