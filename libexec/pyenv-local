#!/usr/bin/env bash
#
# Summary: Set or show the local application-specific Python version(s)
#
# Usage: pyenv local [-f|--force] [<version> [...]]
#        pyenv local --unset
#
#   -f/--force    Do not verify that the versions being set exist
#
# Sets the local application-specific Python version(s) by writing the
# version name to a file named `.python-version'.
#
# When you run a Python command, pyenv will look for a `.python-version'
# file in the current directory and each parent directory. If no such
# file is found in the tree, pyenv will use the global Python version
# specified with `pyenv global'. A version specified with the
# `PYENV_VERSION' environment variable takes precedence over local
# and global versions.
#
# <version> can be specified multiple times and should be a version
# tag known to pyenv.  The special version string `system' will use
# your default system Python.  Run `pyenv versions' for a list of
# available Python versions.
#
# Example: To enable the python2.7 and python3.7 shims to find their
#          respective executables you could set both versions with:
#
# 'pyenv local 3.7.0 2.7.15'


set -e
[ -n "$PYENV_DEBUG" ] && set -x

# Provide pyenv completions
if [ "$1" = "--complete" ]; then
  echo --unset
  echo system
  exec pyenv-versions --bare
fi

while [[ $# -gt 0 ]]
do
    case "$1" in
        -f|--force)
            FORCE=1
            shift
            ;;
        *)
            break
            ;;
    esac
done

versions=("$@")

if [ "$versions" = "--unset" ]; then
  rm -f .python-version
elif [ -n "$versions" ]; then
  pyenv-version-file-write ${FORCE:+-f }.python-version "${versions[@]}"
else
  if version_file="$(pyenv-version-file "$PWD")"; then
    IFS=: versions=($(pyenv-version-file-read "$version_file"))
    for version in "${versions[@]}"; do
      echo "$version"
    done
  else
    echo "pyenv: no local version configured for this directory" >&2
    exit 1
  fi
fi
