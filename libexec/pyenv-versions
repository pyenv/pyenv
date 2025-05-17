#!/usr/bin/env bash
# Summary: List all Python versions available to pyenv
# Usage: pyenv versions [--bare] [--skip-aliases] [--skip-envs]
#
# Lists all Python versions found in `$PYENV_ROOT/versions/*'.

set -e
[ -n "$PYENV_DEBUG" ] && set -x

unset bare skip_aliases skip_envs
# Provide pyenv completions
for arg; do
  case "$arg" in
  --complete )
    echo --bare
    echo --skip-aliases
    echo --skip-envs
    exit ;;
  --bare ) bare=1 ;;
  --skip-aliases ) skip_aliases=1 ;;
  --skip-envs ) skip_envs=1 ;;
  * )
    pyenv-help --usage versions >&2
    exit 1
    ;;
  esac
done

versions_dir="${PYENV_ROOT}/versions"

if ! enable -f "${BASH_SOURCE%/*}"/pyenv-realpath.dylib realpath 2>/dev/null; then
  if [ -n "$PYENV_NATIVE_EXT" ]; then
    echo "pyenv: failed to load \`realpath' builtin" >&2
    exit 1
  fi

  READLINK=$(type -P readlink)
  if [ -z "$READLINK" ]; then
    echo "pyenv: cannot find readlink - are you missing GNU coreutils?" >&2
    exit 1
  fi

  resolve_link() {
    $READLINK "$1"
  }

  realpath() {
    local path="$1"
    local name

    # Use a subshell to avoid changing the current path
    (
    while [ -n "$path" ]; do
      name="${path##*/}"
      [ "$name" = "$path" ] || cd "${path%/*}"
      path="$(resolve_link "$name" || true)"
    done

    echo "${PWD}/$name"
    )
  }
fi

if [ -d "$versions_dir" ]; then
  versions_dir="$(realpath "$versions_dir")"
fi

if ((${BASH_VERSINFO[0]} > 3)); then
  declare -A current_versions
else
  current_versions=()
fi
if [ -n "$bare" ]; then
  include_system=""
else
  hit_prefix="* "
  miss_prefix="  "
  OLDIFS="$IFS"
  IFS=:
  if ((${BASH_VERSINFO[0]} > 3)); then
    for i in $(pyenv-version-name || true); do
      current_versions["$i"]="1"
    done
  else
    current_versions=($(pyenv-version-name || true))
  fi
  IFS="$OLDIFS"
  include_system="1"
fi

num_versions=0

exists() {
  local car="$1"
  local cdar
  shift
  for cdar in "$@"; do
    if [ "${car}" == "${cdar}" ]; then
      return 0
    fi
  done
  return 1
}

print_version() {
  local version="${1:?}"
  if [[ -n $bare ]]; then
    echo "$version"
    return
  fi
  local path="${2:?}"
  if [[ -L "$path" ]]; then
    # Only resolve the link itself for printing, do not resolve further.
    # Doing otherwise would misinform the user of what the link contains.
    version_repr="$version --> $(readlink "$path")"
  else
    version_repr="$version"
  fi
  if [[ ${BASH_VERSINFO[0]} -ge 4 && ${current_versions["$1"]} ]]; then
    echo "${hit_prefix}${version_repr} (set by $(pyenv-version-origin))"
  elif (( ${BASH_VERSINFO[0]} <= 3 )) && exists "$1" "${current_versions[@]}"; then
    echo "${hit_prefix}${version_repr} (set by $(pyenv-version-origin))"
  else
    echo "${miss_prefix}${version_repr}"
  fi
  num_versions=$((num_versions + 1))
}

# Include "system" in the non-bare output, if it exists
if [ -n "$include_system" ] && \
    (PYENV_VERSION=system pyenv-which python --skip-advice >/dev/null 2>&1 || \
     PYENV_VERSION=system pyenv-which python3 --skip-advice >/dev/null 2>&1 || \
     PYENV_VERSION=system pyenv-which python2 --skip-advice >/dev/null 2>&1) ; then
  print_version system "/"
fi

shopt -s dotglob nullglob
versions_dir_entries=("$versions_dir"/*)
if sort --version-sort </dev/null >/dev/null 2>&1; then
    # system sort supports version sorting
    OLDIFS="$IFS"
    IFS=$'\n'
    versions_dir_entries=($(
        printf "%s\n" "${versions_dir_entries[@]}" |
        sort --version-sort
    ))
    IFS="$OLDIFS"
fi

for path in "${versions_dir_entries[@]}"; do
  if [ -d "$path" ]; then
    if [ -n "$skip_aliases" ] && [ -L "$path" ]; then
      target="$(realpath "$path")"
      [ "${target%/*}" == "$versions_dir" ] && continue
      [ "${target%/*/envs/*}" == "$versions_dir" ] && continue
    fi
    print_version "${path##*/}" "$path"
    # virtual environments created by anaconda/miniconda/pyenv-virtualenv
    if [[ -z $skip_envs ]]; then
      for env_path in "${path}/envs/"*; do
        if [ -d "${env_path}" ]; then
          print_version "${env_path#${PYENV_ROOT}/versions/}" "${env_path}"
        fi
      done
    fi
  fi
done
shopt -u dotglob nullglob

if [ "$num_versions" -eq 0 ] && [ -n "$include_system" ]; then
  echo "Warning: no Python detected on the system" >&2
  exit 1
fi
