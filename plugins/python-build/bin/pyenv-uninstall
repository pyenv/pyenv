#!/usr/bin/env bash
#
# Summary: Uninstall Python versions
#
# Usage: pyenv uninstall [-f|--force] <version> ...
#
#    -f  Attempt to remove the specified version without prompting
#        for confirmation. If the version does not exist, do not
#        display an error message.
#
# See `pyenv versions` for a complete list of installed versions.
#
set -e
[ -n "$PYENV_DEBUG" ] && set -x

# Provide pyenv completions
if [ "$1" = "--complete" ]; then
  echo --force
  exec pyenv versions --bare
fi

usage() {
  pyenv-help uninstall 2>/dev/null
  [ -z "$1" ] || exit "$1"
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage 0
fi

unset FORCE
if [ "$1" = "-f" ] || [ "$1" = "--force" ]; then
  FORCE=true
  shift
fi

[ "$#" -gt 0 ] || usage 1 >&2

versions=("$@")

for version in "${versions[@]}"; do
  case "$version" in
  "" | -* )
    usage 1 >&2
    ;;
  esac
done

declare -a before_hooks after_hooks

before_uninstall() {
  local hook="$1"
  before_hooks["${#before_hooks[@]}"]="$hook"
}

after_uninstall() {
  local hook="$1"
  after_hooks["${#after_hooks[@]}"]="$hook"
}

OLDIFS="$IFS"
IFS=$'\n' scripts=(`pyenv-hooks uninstall`)
IFS="$OLDIFS"
for script in "${scripts[@]}"; do source "$script"; done

uninstall-python() {
  local DEFINITION="$1"

  local VERSION_NAME="${DEFINITION##*/}"
  local PREFIX="${PYENV_ROOT}/versions/${VERSION_NAME}"

  if [ -z "$FORCE" ]; then
    if [ ! -d "$PREFIX" ]; then
      echo "pyenv: version \`$VERSION_NAME' not installed" >&2
      exit 1
    fi

    read -p "pyenv: remove $PREFIX? (y/N) "
    case "$REPLY" in
    y | Y | yes | YES ) ;;
    * ) exit 1 ;;
    esac
  fi

  for hook in "${before_hooks[@]}"; do eval "$hook"; done

  if [ -d "$PREFIX" ]; then
    rm -rf "$PREFIX"
    pyenv-rehash
    echo "pyenv: $VERSION_NAME uninstalled"
  fi

  for hook in "${after_hooks[@]}"; do eval "$hook"; done
}

for version in "${versions[@]}"; do
  uninstall-python "$version"
done
