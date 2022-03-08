#!/usr/bin/env bash
# Usage: rbenv version-file-read <file>
set -e
[ -n "$RBENV_DEBUG" ] && set -x

VERSION_FILE="$1"

if [ -s "$VERSION_FILE" ]; then
  # Read the first word from the specified version file. Avoid reading it whole.
  IFS="${IFS}"$'\r'
  read -n 1024 -d "" -r version _ <"$VERSION_FILE" || :

  if [ "$version" = ".." ] || [[ $version == */* ]]; then
    echo "rbenv: invalid version in \`$VERSION_FILE'" >&2
  elif [ -n "$version" ]; then
    echo "$version"
    exit
  fi
fi

exit 1
