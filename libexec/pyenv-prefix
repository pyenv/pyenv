#!/usr/bin/env bash
# Summary: Display prefixes for Python versions
# Usage: pyenv prefix [<version>...]
#
# Displays the directories where the given Python versions are installed,
# separated by colons. If no version is given, `pyenv prefix' displays the
# locations of the currently selected versions.

set -e
[ -n "$PYENV_DEBUG" ] && set -x

# Provide pyenv completions
if [ "$1" = "--complete" ]; then
  echo system
  exec pyenv-versions --bare
fi

if [ -n "$1" ]; then
  OLDIFS="$IFS"
  { IFS=:
    export PYENV_VERSION="$*"
  }
  IFS="$OLDIFS"
elif [ -z "$PYENV_VERSION" ]; then
  PYENV_VERSION="$(pyenv-version-name)"
fi

PYENV_PREFIX_PATHS=()
OLDIFS="$IFS"
{ IFS=:
  for version in ${PYENV_VERSION}; do
    if [ "$version" = "system" ]; then
      if PYTHON_PATH="$(PYENV_VERSION="${version}" pyenv-which python --skip-advice 2>/dev/null)" || \
          PYTHON_PATH="$(PYENV_VERSION="${version}" pyenv-which python3 --skip-advice 2>/dev/null)" || \
          PYTHON_PATH="$(PYENV_VERSION="${version}" pyenv-which python2 --skip-advice 2>/dev/null)"; then
        shopt -s extglob
        # In some distros (Arch), Python can be found in sbin as well as bin
        PYENV_PREFIX_PATH="${PYTHON_PATH%/?(s)bin/*}"
        PYENV_PREFIX_PATH="${PYENV_PREFIX_PATH:-/}"
      else
        echo "pyenv: system version not found in PATH" >&2
        exit 1
      fi
    else
      version="$(pyenv-latest -f "$version")"
      PYENV_PREFIX_PATH="${PYENV_ROOT}/versions/${version}"
    fi
    if [ -d "$PYENV_PREFIX_PATH" ]; then
      PYENV_PREFIX_PATHS=("${PYENV_PREFIX_PATHS[@]}" "$PYENV_PREFIX_PATH")
    else
      echo "pyenv: version \`${version}' not installed" >&2
      exit 1
    fi
  done
}
IFS="$OLDIFS"

OLDIFS="$IFS"
{ IFS=:
  echo "${PYENV_PREFIX_PATHS[*]}"
}
IFS="$OLDIFS"
