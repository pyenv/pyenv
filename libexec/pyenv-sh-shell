#!/usr/bin/env bash
#
# Summary: Set or show the shell-specific Python version
#
# Usage: pyenv shell <version>...
#        pyenv shell -
#        pyenv shell --unset
#
# Sets a shell-specific Python version by setting the `PYENV_VERSION'
# environment variable in your shell. This version overrides local
# application-specific versions and the global version.
#
# <version> should be a string matching a Python version known to pyenv.
# The special version string `system' will use your default system Python.
# Run `pyenv versions' for a list of available Python versions.
#
# When `-` is passed instead of the version string, the previously set
# version will be restored. With `--unset`, the `PYENV_VERSION`
# environment variable gets unset, restoring the environment to the
# state before the first `pyenv shell` call.

set -e
[ -n "$PYENV_DEBUG" ] && set -x

# Provide pyenv completions
if [ "$1" = "--complete" ]; then
  echo --unset
  echo system
  exec pyenv-versions --bare
fi

versions=("$@")
shell="$(basename "${PYENV_SHELL:-$SHELL}")"

if [ -z "$versions" ]; then
  if [ -z "$PYENV_VERSION" ]; then
    echo "pyenv: no shell-specific version configured" >&2
    exit 1
  else
    echo 'echo "$PYENV_VERSION"'
    exit
  fi
fi

if [ "$versions" = "--unset" ]; then
  case "$shell" in
  fish )
    echo 'set -gu PYENV_VERSION_OLD "$PYENV_VERSION"'
    echo "set -e PYENV_VERSION"
    ;;
  * )
    echo 'PYENV_VERSION_OLD="${PYENV_VERSION-}"'
    echo "unset PYENV_VERSION"
    ;;
  esac
  exit
fi

if [ "$versions" = "-" ]; then
  case "$shell" in
  fish )
    cat <<EOS
if set -q PYENV_VERSION_OLD
  if [ -n "\$PYENV_VERSION_OLD" ]
    set PYENV_VERSION_OLD_ "\$PYENV_VERSION"
    set -gx PYENV_VERSION "\$PYENV_VERSION_OLD"
    set -gu PYENV_VERSION_OLD "\$PYENV_VERSION_OLD_"
    set -e PYENV_VERSION_OLD_
  else
    set -gu PYENV_VERSION_OLD "\$PYENV_VERSION"
    set -e PYENV_VERSION
  end
else
  echo "pyenv: PYENV_VERSION_OLD is not set" >&2
  false
end
EOS
    ;;
  * )
    cat <<EOS
if [ -n "\${PYENV_VERSION_OLD+x}" ]; then
  if [ -n "\$PYENV_VERSION_OLD" ]; then
    PYENV_VERSION_OLD_="\$PYENV_VERSION"
    export PYENV_VERSION="\$PYENV_VERSION_OLD"
    PYENV_VERSION_OLD="\$PYENV_VERSION_OLD_"
    unset PYENV_VERSION_OLD_
  else
    PYENV_VERSION_OLD="\$PYENV_VERSION"
    unset PYENV_VERSION
  fi
else
  echo "pyenv: PYENV_VERSION_OLD is not set" >&2
  false
fi
EOS
    ;;
  esac
  exit
fi

# Make sure the specified version is installed.
if pyenv-prefix "${versions[@]}" >/dev/null; then
  OLDIFS="$IFS"
  IFS=: version="${versions[*]}"
  IFS="$OLDIFS"
  if [ "$version" != "$PYENV_VERSION" ]; then
    case "$shell" in
    fish )
      echo 'set -gu PYENV_VERSION_OLD "$PYENV_VERSION"'
      echo "set -gx PYENV_VERSION \"$version\""
      ;;
    * )
      echo 'PYENV_VERSION_OLD="${PYENV_VERSION-}"'
      echo "export PYENV_VERSION=\"${version}\""
      ;;
    esac
  fi
else
  echo "false"
  exit 1
fi
