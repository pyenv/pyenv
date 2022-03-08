#!/usr/bin/env bash
# Usage: pyenv version-file-read <file>
set -e
[ -n "$PYENV_DEBUG" ] && set -x

VERSION_FILE="$1"

if [ -s "$VERSION_FILE" ]; then
  # Read the first non-whitespace word from the specified version file.
  # Be careful not to load it whole in case there's something crazy in it.
  IFS="${IFS}"$'\r'
  sep=
  while read -n 1024 -r version _ || [[ $version ]]; do
      [[ -z $version || $version == \#* ]] && continue
      printf "%s%s" "$sep" "$version"
      sep=:
  done <"$VERSION_FILE"
  [[ $sep ]] && { echo; exit; }
fi

exit 1
