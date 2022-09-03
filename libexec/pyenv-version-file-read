#!/usr/bin/env bash
# Usage: pyenv version-file-read <file>
set -e
[ -n "$PYENV_DEBUG" ] && set -x

VERSION_FILE="$1"

function is_version_safe() {
  # As needed, check that the constructed path exists as a child path of PYENV_ROOT/versions
  version="$1"
  if [[ "$version" == ".." || "$version" == */* ]]; then
    # Sanity check the value of version to prevent malicious path-traversal
    (
      cd "$PYENV_ROOT/versions/$version" &>/dev/null || exit 1
      [[ "$PWD" == "$PYENV_ROOT/versions/"* ]]
    )
    return $?
  else
    return 0
  fi
}

if [ -s "$VERSION_FILE" ]; then
  # Read the first non-whitespace word from the specified version file.
  # Be careful not to load it whole in case there's something crazy in it.
  IFS="$IFS"$'\r'
  sep=
  while read -n 1024 -r version _ || [[ $version ]]; do
    if [[ -z "$version" || "$version" == \#* ]]; then
      # Skip empty lines and comments
      continue
    elif ! is_version_safe "$version"; then
      # CVE-2022-35861 allowed arbitrary code execution in some contexts and is mitigated by is_version_safe.
      echo "pyenv: invalid version \`$version' ignored in \`$VERSION_FILE'" >&2
      continue
    fi
    printf "%s%s" "$sep" "$version"
    sep=:
  done <"$VERSION_FILE"
  [[ $sep ]] && { echo; exit; }
fi

exit 1
