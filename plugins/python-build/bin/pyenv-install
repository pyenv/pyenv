#!/usr/bin/env bash
#
# Summary: Install a Python version using python-build
#
# Usage: pyenv install [-f] [-kvp] <version>...
#        pyenv install [-f] [-kvp] <definition-file>
#        pyenv install -l|--list
#        pyenv install --version
#
#   -l/--list          List all available versions
#   -f/--force         Install even if the version appears to be installed already
#   -s/--skip-existing Skip if the version appears to be installed already
#
#   python-build options:
#
#   -k/--keep          Keep source tree in $PYENV_BUILD_ROOT after installation
#                      (defaults to $PYENV_ROOT/sources)
#   -p/--patch         Apply a patch from stdin before building
#   -v/--verbose       Verbose mode: print compilation status to stdout
#   --version          Show version of python-build
#   -g/--debug         Build a debug version
#
# For detailed information on installing Python versions with
# python-build, including a list of environment variables for adjusting
# compilation, see: https://github.com/pyenv/pyenv#readme
#
set -e
[ -n "$PYENV_DEBUG" ] && set -x

# Add `share/python-build/` directory from each pyenv plugin to the list of
# paths where build definitions are looked up.
shopt -s nullglob
for plugin_path in "$PYENV_ROOT"/plugins/*/share/python-build; do
  PYTHON_BUILD_DEFINITIONS="${PYTHON_BUILD_DEFINITIONS}:${plugin_path}"
done
export PYTHON_BUILD_DEFINITIONS
shopt -u nullglob

# Provide pyenv completions
if [ "$1" = "--complete" ]; then
  echo --list
  echo --force
  echo --skip-existing
  echo --keep
  echo --patch
  echo --verbose
  echo --version
  echo --debug
  exec python-build --definitions
fi

# Load shared library functions
eval "$(python-build --lib)"

usage() {
  pyenv-help install 2>/dev/null
  [ -z "$1" ] || exit "$1"
}

definitions() {
  local query="$1"
  python-build --definitions | $(type -P ggrep grep | head -n1) -F "$query" || true
}

indent() {
  sed 's/^/  /'
}

unset FORCE
unset SKIP_EXISTING
unset KEEP
unset VERBOSE
unset HAS_PATCH
unset DEBUG

[ -n "$PYENV_DEBUG" ] && VERBOSE="-v"

parse_options "$@"
for option in "${OPTIONS[@]}"; do
  case "$option" in
  "h" | "help" )
    usage 0
    ;;
  "l" | "list" )
    echo "Available versions:"
    definitions | indent
    exit
    ;;
  "f" | "force" )
    FORCE=true
    ;;
  "s" | "skip-existing" )
    SKIP_EXISTING=true
    ;;
  "k" | "keep" )
    [ -n "${PYENV_BUILD_ROOT}" ] || PYENV_BUILD_ROOT="${PYENV_ROOT}/sources"
    ;;
  "v" | "verbose" )
    VERBOSE="-v"
    ;;
  "p" | "patch" )
    HAS_PATCH="-p"
    ;;
  "g" | "debug" )
    DEBUG="-g"
    ;;
  "version" )
    exec python-build --version
    ;;
  * )
    usage 1 >&2
    ;;
  esac
done

unset VERSION_NAME

# The first argument contains the definition to install. If the
# argument is missing, try to install whatever local app-specific
# version is specified by pyenv. Show usage instructions if a local
# version is not specified.
DEFINITIONS=("${ARGUMENTS[@]}")
[[ "${#DEFINITIONS[*]}" -eq 0 ]] && DEFINITIONS=($(pyenv-local 2>/dev/null || true))
[[ "${#DEFINITIONS[*]}" -eq 0 ]] && usage 1 >&2

# Define `before_install` and `after_install` functions that allow
# plugin hooks to register a string of code for execution before or
# after the installation process.
declare -a before_hooks after_hooks

before_install() {
  local hook="$1"
  before_hooks["${#before_hooks[@]}"]="$hook"
}

after_install() {
  local hook="$1"
  after_hooks["${#after_hooks[@]}"]="$hook"
}

# Plan cleanup on unsuccessful installation.
cleanup() {
  [ -z "${PREFIX_EXISTS}" ] && rm -rf "$PREFIX"
}

trap cleanup SIGINT


OLDIFS="$IFS"
IFS=$'\n' scripts=(`pyenv-hooks install`)
IFS="$OLDIFS"
for script in "${scripts[@]}"; do source "$script"; done

COMBINED_STATUS=0
for DEFINITION in "${DEFINITIONS[@]}"; do
  STATUS=0

  # Try to resolve a prefix if user indeed gave a prefix.
  # We install the version under the resolved name
  # and hooks also see the resolved name
  DEFINITION="$(pyenv-latest -f -k "$DEFINITION")"

  # Set VERSION_NAME from $DEFINITION. Then compute the installation prefix.
  VERSION_NAME="${DEFINITION##*/}"
  [ -n "$DEBUG" ] && VERSION_NAME="${VERSION_NAME}-debug"
  PREFIX="${PYENV_ROOT}/versions/${VERSION_NAME}"

  [ -d "${PREFIX}" ] && PREFIX_EXISTS=1

  # If the installation prefix exists, prompt for confirmation unless
  # the --force option was specified.
  if [ -d "${PREFIX}/bin" ]; then
    if [ -z "$FORCE" ] && [ -z "$SKIP_EXISTING" ]; then
      echo "pyenv: $PREFIX already exists" >&2
      read -p "continue with installation? (y/N) "

      case "$REPLY" in
      y | Y | yes | YES ) ;;
      * ) { STATUS=1; [[ $STATUS -gt $COMBINED_STATUS ]] && COMBINED_STATUS=$STATUS; }; continue ;;
      esac
    elif [ -n "$SKIP_EXISTING" ]; then
      # Since we know the python version is already installed, and are opting to
      # not force installation of existing versions, we just `exit 0` here to
      # leave things happy
      continue
    fi
  fi

  # If PYENV_BUILD_ROOT is set, always pass keep options to python-build.
  if [ -n "${PYENV_BUILD_ROOT}" ]; then
    export PYTHON_BUILD_BUILD_PATH="${PYENV_BUILD_ROOT}/${VERSION_NAME}"
    KEEP="-k"
  fi

  # Set PYTHON_BUILD_CACHE_PATH to $PYENV_ROOT/cache, if the directory
  # exists and the variable is not already set.
  if [ -z "${PYTHON_BUILD_CACHE_PATH}" ] && [ -d "${PYENV_ROOT}/cache" ]; then
    export PYTHON_BUILD_CACHE_PATH="${PYENV_ROOT}/cache"
  fi

  if [ -z "${PYENV_BOOTSTRAP_VERSION}" ]; then
    case "${VERSION_NAME}" in
    [23]"."* )
      # Default PYENV_VERSION to the friendly Python version. (The
      # CPython installer requires an existing Python installation to run. An
      # unsatisfied local .python-version file can cause the installer to
      # fail.)
      for version_info in "${VERSION_NAME%-dev}" "${VERSION_NAME%.*}" "${VERSION_NAME%%.*}"; do
        # Anaconda's `curl` doesn't work on platform where `/etc/pki/tls/certs/ca-bundle.crt` isn't available (e.g. Debian)
        for version in $(pyenv-whence "python${version_info}" 2>/dev/null || true); do
          if [[ "${version}" != "anaconda"* ]] && [[ "${version}" != "miniconda"* ]]; then
            PYENV_BOOTSTRAP_VERSION="${version}"
            break 2
          fi
        done
      done
      ;;
    "pypy"*"-dev" | "pypy"*"-src" )
      # PyPy/PyPy3 requires existing Python 2.7 to build
      if [ -n "${PYENV_RPYTHON_VERSION}" ]; then
        PYENV_BOOTSTRAP_VERSION="${PYENV_RPYTHON_VERSION}"
      else
        for version in $(pyenv-versions --bare | sort -r); do
          if [[ "${version}" == "2.7"* ]]; then
            PYENV_BOOTSTRAP_VERSION="$version"
            break
          fi
        done
      fi
      if [ -n "$PYENV_BOOTSTRAP_VERSION" ]; then
        for dep in pycparser; do
          if ! PYENV_VERSION="$PYENV_BOOTSTRAP_VERSION" pyenv-exec python -c "import ${dep}" 1>/dev/null 2>&1; then
            echo "pyenv-install: $VERSION_NAME: PyPy requires \`${dep}' in $PYENV_BOOTSTRAP_VERSION to build from source." >&2
            exit 1
          fi
        done
      else
        echo "pyenv-install: $VERSION_NAME: PyPy requires Python 2.7 to build from source." >&2
        exit 1
      fi
      ;;
    esac
  fi

  if [ -n "${PYENV_BOOTSTRAP_VERSION}" ]; then
    export PYENV_VERSION="${PYENV_BOOTSTRAP_VERSION}"
  fi

  # Execute `before_install` hooks.
  for hook in "${before_hooks[@]}"; do eval "$hook"; done

  # Invoke `python-build` and record the exit status in $STATUS.
  python-build $KEEP $VERBOSE $HAS_PATCH $DEBUG "$DEFINITION" "$PREFIX" || \
      { STATUS=$?; [[ $STATUS -gt $COMBINED_STATUS ]] && COMBINED_STATUS=$STATUS; }

  # Display a more helpful message if the definition wasn't found.
  if [ "$STATUS" == "2" ]; then
    { candidates="$(definitions "$DEFINITION")"
      here="$(dirname "${0%/*}")/../.."
      if [ -n "$candidates" ]; then
        echo
        echo "The following versions contain \`$DEFINITION' in the name:"
        echo "$candidates" | indent
      fi
      echo
      echo "See all available versions with \`pyenv install --list'."
      echo
      echo -n "If the version you need is missing, try upgrading pyenv"
      if [ "$here" != "${here#$(brew --prefix 2>/dev/null)}" ]; then
        printf ":\n\n"
        echo "  brew update && brew upgrade pyenv"
      elif [ -d "${here}/.git" ]; then
        printf ":\n\n"
        echo "  cd ${here} && git pull && cd -"
      else
        printf ".\n"
      fi
    } >&2
  fi

  # Execute `after_install` hooks.
  for hook in "${after_hooks[@]}"; do eval "$hook"; done

  # Run `pyenv-rehash` after a successful installation.
  if [[ $STATUS -eq 0 ]]; then
    pyenv-rehash
  else
    cleanup
    break
  fi

done


exit "${COMBINED_STATUS}"
