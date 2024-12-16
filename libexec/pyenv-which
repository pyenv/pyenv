#!/usr/bin/env bash
#
# Summary: Display the full path to an executable
#
# Usage: pyenv which <command> [--nosystem] [--skip-advice]
#
# Displays the full path to the executable that pyenv will invoke when
# you run the given command.
# Use --nosystem argument in case when you don't need to search command in the 
# system environment.
# Internal switch --skip-advice used to skip printing an error message on a
# failed search.

set -e
[ -n "$PYENV_DEBUG" ] && set -x

# Provide pyenv completions
if [ "$1" = "--complete" ]; then
  exec pyenv-shims --short
fi

system="system"
SKIP_ADVICE=""
PYENV_COMMAND="$1"

while [[ $# -gt 0 ]]
do
  case "$1" in
    --skip-advice)
      SKIP_ADVICE=1
      shift
      ;;
    --nosystem)
      system=""
      shift
      ;;
    *)
      shift
      ;;
  esac
done


remove_from_path() {
  local path_to_remove="$1"
  local path_before
  local result=":${PATH//\~/$HOME}:"
  while [ "$path_before" != "$result" ]; do
    path_before="$result"
    result="${result//:$path_to_remove:/:}"
  done
  result="${result%:}"
  echo "${result#:}"
}

if [ -z "$PYENV_COMMAND" ]; then
  pyenv-help --usage which >&2
  exit 1
fi

OLDIFS="$IFS"
IFS=: versions=(${PYENV_VERSION:-$(pyenv-version-name -f)})
IFS="$OLDIFS"

declare -a nonexistent_versions

for version in "${versions[@]}" "$system"; do
  if [ "$version" = "system" ]; then
    PATH="$(remove_from_path "${PYENV_ROOT}/shims")"
    PYENV_COMMAND_PATH="$(command -v "$PYENV_COMMAND" || true)"
  else
    # $version may be a prefix to be resolved by pyenv-latest
    version_path="$(pyenv-prefix "${version}" 2>/dev/null)" || \
        { nonexistent_versions+=("$version"); continue; }
    # resolve $version for hooks
    version="$(basename "$version_path")"
    PYENV_COMMAND_PATH="$version_path/bin/${PYENV_COMMAND}"
    unset version_path
  fi
  if [ -x "$PYENV_COMMAND_PATH" ]; then
    break
  fi
done

OLDIFS="$IFS"
IFS=$'\n' scripts=(`pyenv-hooks which`)
IFS="$OLDIFS"
for script in "${scripts[@]}"; do
  source "$script"
done

if [ -x "$PYENV_COMMAND_PATH" ]; then
  echo "$PYENV_COMMAND_PATH"
else
  if (( ${#nonexistent_versions[@]} )); then
    for version in "${nonexistent_versions[@]}"; do
      echo "pyenv: version \`$version' is not installed (set by $(pyenv-version-origin))" >&2
    done
  fi

  echo "pyenv: $PYENV_COMMAND: command not found" >&2
  if [ -z "$SKIP_ADVICE" ]; then
    versions="$(pyenv-whence "$PYENV_COMMAND" || true)"
    if [ -n "$versions" ]; then
      { echo
        echo "The \`$PYENV_COMMAND' command exists in these Python versions:"
        echo "$versions" | sed 's/^/  /g'
        echo
        echo "Note: See 'pyenv help global' for tips on allowing both"
        echo "      python2 and python3 to be found."
      } >&2
    fi
  fi

  exit 127
fi
