#!/usr/bin/env bash
# Summary: Show the current Python version
#
#   -f/--force    (Internal) If a version doesn't exist, print it as is rather than produce an error

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


if [ -z "$PYENV_VERSION" ]; then
  PYENV_VERSION_FILE="$(pyenv-version-file)"
  PYENV_VERSION="$(pyenv-version-file-read "$PYENV_VERSION_FILE" || true)"
fi

OLDIFS="$IFS"
IFS=$'\n' scripts=(`pyenv-hooks version-name`)
IFS="$OLDIFS"
for script in "${scripts[@]}"; do
  source "$script"
done

if [ -z "$PYENV_VERSION" ] || [ "$PYENV_VERSION" = "system" ]; then
  echo "system"
  exit
fi

version_exists() {
  local version="$1"
  [ -d "${PYENV_ROOT}/versions/${version}" ]
}

versions=()
OLDIFS="$IFS"
{ IFS=:
  any_not_installed=0
  for version in ${PYENV_VERSION}; do
    # Remove the explicit 'python-' prefix from versions like 'python-3.12'.
    normalised_version="${version#python-}"
    if version_exists "${version}" || [ "$version" = "system" ]; then
      versions+=("${version}")
    elif version_exists "${normalised_version}"; then
      versions+=("${normalised_version}")
    elif resolved_version="$(pyenv-latest -b "${version}")"; then
      versions+=("${resolved_version}")
    elif resolved_version="$(pyenv-latest -b "${normalised_version}")"; then
      versions+=("${resolved_version}")
    else
      if [[ -n $FORCE ]]; then
        versions+=("${normalised_version}")
      else
        echo "pyenv: version \`$version' is not installed (set by $(pyenv-version-origin))" >&2
        any_not_installed=1
      fi
    fi
  done
}
IFS="$OLDIFS"

OLDIFS="$IFS"
{ IFS=:
  echo "${versions[*]}"
}
IFS="$OLDIFS"

if [ "$any_not_installed" = 1 ]; then
  exit 1
fi
