#!/usr/bin/env bash
#
# Summary: Set or show the global Python version(s)
#
# Usage: pyenv global <version> <version2> <..>
#
# Sets the global Python version(s). You can override the global version at
# any time by setting a directory-specific version with `pyenv local'
# or by setting the `PYENV_VERSION' environment variable.
#
# <version> can be specified multiple times and should be a version
# tag known to pyenv.  The special version string `system' will use
# your default system Python.  Run `pyenv versions' for a list of
# available Python versions.
#
# Example: To enable the python2.7 and python3.7 shims to find their
#          respective executables you could set both versions with:
#
# 'pyenv global 3.7.0 2.7.15'
#


set -e
[ -n "$PYENV_DEBUG" ] && set -x

# Provide pyenv completions
if [ "$1" = "--complete" ]; then
  echo system
  exec pyenv-versions --bare
fi

versions=("$@")
PYENV_VERSION_FILE="${PYENV_ROOT}/version"

if [ -n "$versions" ]; then
  pyenv-version-file-write "$PYENV_VERSION_FILE" "${versions[@]}"
else
  OLDIFS="$IFS"
  IFS=: versions=($(
    pyenv-version-file-read "$PYENV_VERSION_FILE" ||
    pyenv-version-file-read "${PYENV_ROOT}/global" ||
    pyenv-version-file-read "${PYENV_ROOT}/default" ||
    echo system
  ))
  IFS="$OLDIFS"
  for version in "${versions[@]}"; do
    echo "$version"
  done
fi
