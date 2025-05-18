#!/usr/bin/env bash
set -e

if [ "$1" = "--debug" ]; then
  export PYENV_DEBUG=1
  shift
fi

if [ -n "$PYENV_DEBUG" ]; then
  # https://wiki-dev.bash-hackers.org/scripting/debuggingtips#making_xtrace_more_useful
  export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
  set -x
fi

abort() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "pyenv: $*"
    fi
  } >&2
  exit 1
}

if enable -f "${BASH_SOURCE%/*}"/../libexec/pyenv-realpath.dylib realpath 2>/dev/null; then
  abs_dirname() {
    local path
    path="$(realpath "$1")"
    echo "${path%/*}"
  }
else
  [ -z "$PYENV_NATIVE_EXT" ] || abort "failed to load \`realpath' builtin"

  READLINK=$(type -P readlink)
  [ -n "$READLINK" ] || abort "cannot find readlink - are you missing GNU coreutils?"

  resolve_link() {
    $READLINK "$1"
  }

  abs_dirname() {
    local path="$1"

    # Use a subshell to avoid changing the current path
    (
    while [ -n "$path" ]; do
      cd_path="${path%/*}"
      if [[ "$cd_path" != "$path" ]]; then
        cd "$cd_path"
      fi
      name="${path##*/}"
      path="$(resolve_link "$name" || true)"
    done

    echo "$PWD"
    )
  }
fi

if [ -z "${PYENV_ROOT}" ]; then
  PYENV_ROOT="${HOME}/.pyenv"
else
  PYENV_ROOT="${PYENV_ROOT%/}"
fi
export PYENV_ROOT

if [ -z "${PYENV_DIR}" ]; then
  PYENV_DIR="$PWD"
fi

if [ ! -d "$PYENV_DIR" ] || [ ! -e "$PYENV_DIR" ]; then
  abort "cannot change working directory to \`$PYENV_DIR'"
fi

PYENV_DIR=$(cd "$PYENV_DIR" && echo "$PWD")
export PYENV_DIR


shopt -s nullglob

bin_path="$(abs_dirname "$0")"
for plugin_bin in "${bin_path%/*}"/plugins/*/bin; do
  PATH="${plugin_bin}:${PATH}"
done
# PYENV_ROOT can be set to anything, so it may happen to be equal to the base path above,
# resulting in duplicate PATH entries
if [ "${bin_path%/*}" != "$PYENV_ROOT" ]; then
  for plugin_bin in "${PYENV_ROOT}"/plugins/*/bin; do
    PATH="${plugin_bin}:${PATH}"
  done
fi
export PATH="${bin_path}:${PATH}"

PYENV_HOOK_PATH="${PYENV_HOOK_PATH}:${PYENV_ROOT}/pyenv.d"
if [ "${bin_path%/*}" != "$PYENV_ROOT" ]; then
  # Add pyenv's own `pyenv.d` unless pyenv was cloned to PYENV_ROOT
  PYENV_HOOK_PATH="${PYENV_HOOK_PATH}:${bin_path%/*}/pyenv.d"
fi
PYENV_HOOK_PATH="${PYENV_HOOK_PATH}:/usr/etc/pyenv.d:/usr/local/etc/pyenv.d:/etc/pyenv.d:/usr/lib/pyenv/hooks"
for plugin_hook in "${PYENV_ROOT}/plugins/"*/etc/pyenv.d; do
  PYENV_HOOK_PATH="${PYENV_HOOK_PATH}:${plugin_hook}"
done
PYENV_HOOK_PATH="${PYENV_HOOK_PATH#:}"
export PYENV_HOOK_PATH

shopt -u nullglob


command="$1"
case "$command" in
"" )
  { pyenv---version
    pyenv-help
  } | abort
  ;;
-v | --version )
  exec pyenv---version
  ;;
-h | --help )
  exec pyenv-help
  ;;
* )
  command_path="$(command -v "pyenv-$command" || true)"
  if [ -z "$command_path" ]; then
    if [ "$command" == "shell" ]; then
      abort "shell integration not enabled. Run \`pyenv init' for instructions."
    else
      abort "no such command \`$command'"
    fi
  fi

  shift 1
  if [ "$1" = --help ]; then
    if [[ "$command" == "sh-"* ]]; then
      echo "pyenv help \"$command\""
    else
      exec pyenv-help "$command"
    fi
  else
    exec "$command_path" "$@"
  fi
  ;;
esac
