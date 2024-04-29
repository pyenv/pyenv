#!/usr/bin/env bash
# Summary: Regenerate rbenv shims
#
# Regenerate shims for every Ruby executable in `$RBENV_ROOT/versions/*/bin'
# and write them to the `$RBENV_ROOT/shims' directory. A shell environment
# properly set up for rbenv will have this shims directory in PATH, which is
# the core mechanism for Ruby version switching.
#
# Running rbenv rehash should only be necessary after installing new Ruby
# versions or gems. Note that this is sometimes done automatically: the
# `rbenv install' command from the ruby-build plugin runs rehash after
# every successful installation, and a RubyGems plugin that ships with
# rbenv runs rehash after every `gem install' command.

set -e
[ -n "$RBENV_DEBUG" ] && set -x

SHIM_PATH="${RBENV_ROOT}/shims"
PROTOTYPE_SHIM_PATH="${SHIM_PATH}/.rbenv-shim"

# Create the shims directory if it doesn't already exist.
mkdir -p "$SHIM_PATH"

# Ensure only one instance of rbenv-rehash is running at a time by
# setting the shell's `noclobber` option and attempting to write to
# the prototype shim file. If the file already exists, print a warning
# to stderr and exit with a non-zero status.
set -o noclobber
{ echo > "$PROTOTYPE_SHIM_PATH"
} 2>| /dev/null ||
{ if [ -w "$SHIM_PATH" ]; then
    echo "rbenv: cannot rehash: $PROTOTYPE_SHIM_PATH exists"
  else
    echo "rbenv: cannot rehash: $SHIM_PATH isn't writable"
  fi
  exit 1
} >&2
set +o noclobber

# If we were able to obtain a lock, register a trap to clean up the
# prototype shim when the process exits.
trap remove_prototype_shim EXIT

remove_prototype_shim() {
  rm -f "$PROTOTYPE_SHIM_PATH"
}

# Locates rbenv as found in the user's PATH. Otherwise, returns an
# absolute path to the rbenv executable itself.
rbenv_path() {
  local found
  found="$(PATH="$RBENV_ORIG_PATH" type -P rbenv)"
  if [[ $found == /* ]]; then
    echo "$found"
  elif [[ -n "$found" ]]; then
    echo "$PWD/${found#./}"
  else
    # Assume rbenv isn't in PATH.
    echo "${BASH_SOURCE%/*}/rbenv"
  fi
}

# The prototype shim file is a script that re-execs itself, passing
# its filename and any arguments to `rbenv exec`. This file is
# hard-linked for every executable and then removed. The linking
# technique is fast, uses less disk space than unique files, and also
# serves as a locking mechanism.
create_prototype_shim() {
  cat > "$PROTOTYPE_SHIM_PATH" <<SH
#!/usr/bin/env bash
set -e
[ -n "\$RBENV_DEBUG" ] && set -x

program="\${0##*/}"
if [ "\$program" = "ruby" ]; then
  for arg; do
    case "\$arg" in
    -e* | -- ) break ;;
    */* )
      if [ -f "\$arg" ]; then
        export RBENV_DIR="\${arg%/*}"
        break
      fi
      ;;
    esac
  done
fi

export RBENV_ROOT="$RBENV_ROOT"
exec "$(rbenv_path)" exec "\$program" "\$@"
SH
  chmod +x "$PROTOTYPE_SHIM_PATH"
}

# If the contents of the prototype shim file differ from the contents
# of the first shim in the shims directory, assume rbenv has been
# upgraded and the existing shims need to be removed.
remove_outdated_shims() {
  local shim
  for shim in "$SHIM_PATH"/*; do
    if ! diff "$PROTOTYPE_SHIM_PATH" "$shim" >/dev/null 2>&1; then
      rm -f "$SHIM_PATH"/*
    fi
    break
  done
}

# List basenames of executables for every Ruby version
list_executable_names() {
  local version file
  rbenv-versions --bare --skip-aliases | \
  while read -r version; do
    for file in "${RBENV_ROOT}/versions/${version}/bin/"*; do
      echo "${file##*/}"
    done
  done
  if [ -n "$GEM_HOME" ]; then
    for file in "$GEM_HOME"/bin/*; do
      echo "${file##*/}"
    done
  fi
}

# The basename of each argument passed to `make_shims` will be
# registered for installation as a shim. In this way, plugins may call
# `make_shims` with a glob to register many shims at once.
make_shims() {
  local file shim
  for file; do
    shim="${file##*/}"
    registered_shims+=("$shim")
  done
}

# Registers the name of a shim to be generated.
register_shim() {
  registered_shims+=("$1")
}

# Install all the shims registered via `make_shims` or `register_shim` directly.
install_registered_shims() {
  local shim file
  for shim in "${registered_shims[@]}"; do
    file="${SHIM_PATH}/${shim}"
    [ -e "$file" ] || cp "$PROTOTYPE_SHIM_PATH" "$file"
  done
}

# Once the registered shims have been installed, we make a second pass
# over the contents of the shims directory. Any file that is present
# in the directory but has not been registered as a shim should be
# removed.
remove_stale_shims() {
  local shim
  local known_shims=" ${registered_shims[*]} "
  for shim in "$SHIM_PATH"/*; do
    if [[ "$known_shims" != *" ${shim##*/} "* ]]; then
      rm -f "$shim"
    fi
  done
}

shopt -s nullglob

# Create the prototype shim, then register shims for all known
# executables.
create_prototype_shim
remove_outdated_shims
# shellcheck disable=SC2207
registered_shims=( $(list_executable_names | sort -u) )

# Allow plugins to register shims.
IFS=$'\n' read -d '' -r -a scripts <<<"$(rbenv-hooks rehash)" || true
for script in "${scripts[@]}"; do
  # shellcheck disable=SC1090
  source "$script"
done

install_registered_shims
remove_stale_shims
