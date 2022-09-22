#!/usr/bin/env bash
# Summary: List installed Ruby versions
# Usage: rbenv versions [--bare] [--skip-aliases]
#
# Lists all Ruby versions found in `$RBENV_ROOT/versions/*'.

set -e
[ -n "$RBENV_DEBUG" ] && set -x

unset bare
unset skip_aliases
# Provide rbenv completions
for arg; do
  case "$arg" in
  --complete )
    echo --bare
    echo --skip-aliases
    exit ;;
  --bare ) bare=1 ;;
  --skip-aliases ) skip_aliases=1 ;;
  * )
    rbenv-help --usage versions >&2
    exit 1
    ;;
  esac
done

canonicalize_dir() {
  { cd "$1" && pwd -P
  } 2>/dev/null || echo "$1"
}

versions_dir="${RBENV_ROOT}/versions"
if [ -n "$skip_aliases" ]; then
  versions_dir="$(canonicalize_dir "$versions_dir")"
fi

list_versions() {
  local path
  local target
  shopt -s nullglob
  for path in "$versions_dir"/*; do
    if [ -d "$path" ]; then
      if [ -n "$skip_aliases" ] && [ -L "$path" ]; then
        target="$(canonicalize_dir "$path")"
        [ "${target%/*}" != "$versions_dir" ] || continue
      fi
      echo "${path##*/}"
    fi
  done
  shopt -u nullglob
}

if [ -n "$bare" ]; then
  list_versions
  exit 0
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z.\1/; s/$/.z/; G; s/\n/ /' | \
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

versions="$(
  if RBENV_VERSION=system rbenv-which ruby >/dev/null 2>&1; then
    echo system
  fi
  list_versions | sort_versions
)"

if [ -z "$versions" ]; then
  echo "Warning: no Ruby detected on the system" >&2
  exit 1
fi

current_version="$(rbenv-version-name || true)"
while read -r version; do
  if [ "$version" == "$current_version" ]; then
    echo "* $(rbenv-version 2>/dev/null)"
  else
    echo "  $version"
  fi
done <<<"$versions"
