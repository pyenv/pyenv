#!/usr/bin/env bash
# Usage: pyenv version-file-write [-f|--force] <file> <version> [...]
#
#   -f/--force    Don't verify that the versions exist

set -e
[ -n "$PYENV_DEBUG" ] && set -x

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


PYENV_VERSION_FILE="$1"
shift || true
versions=("$@")

if [ -z "$versions" ] || [ -z "$PYENV_VERSION_FILE" ]; then
  pyenv-help --usage version-file-write >&2
  exit 1
fi

# Make sure the specified version is installed.
[[ -z $FORCE ]] && pyenv-prefix "${versions[@]}" >/dev/null

# Write the version out to disk.
# Create an empty file. Using "rm" might cause a permission error.
> "$PYENV_VERSION_FILE"
for version in "${versions[@]}"; do
  echo "$version" >> "$PYENV_VERSION_FILE"
done
