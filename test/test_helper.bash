unset PYENV_VERSION
unset PYENV_DIR

# guard against executing this block twice due to bats internals
if [ -z "$PYENV_TEST_DIR" ]; then
  PYENV_TEST_DIR="${BATS_TMPDIR}/pyenv"
  export PYENV_TEST_DIR="$(mktemp -d "${PYENV_TEST_DIR}.XXX" 2>/dev/null || echo "$PYENV_TEST_DIR")"

  if enable -f "${BATS_TEST_DIRNAME}"/../libexec/pyenv-realpath.dylib realpath 2>/dev/null; then
    export PYENV_TEST_DIR="$(realpath "$PYENV_TEST_DIR")"
  else
    if [ -n "$PYENV_NATIVE_EXT" ]; then
      echo "pyenv: failed to load \`realpath' builtin" >&2
      exit 1
    fi
  fi

  export PYENV_ROOT="${PYENV_TEST_DIR}/root"
  export HOME="${PYENV_TEST_DIR}/home"
  export PYENV_HOOK_PATH="${PYENV_ROOT}/pyenv.d"

  PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
  PATH="${PYENV_TEST_DIR}/bin:$PATH"
  PATH="${BATS_TEST_DIRNAME%/*}/libexec:$PATH"
  PATH="${BATS_TEST_DIRNAME}/libexec:$PATH"
  PATH="${PYENV_ROOT}/shims:$PATH"
  export PATH

  for xdg_var in `env 2>/dev/null | grep ^XDG_ | cut -d= -f1`; do unset "$xdg_var"; done
  unset xdg_var
fi

teardown() {
  rm -rf "$PYENV_TEST_DIR"
}

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed "s:${PYENV_TEST_DIR}:TEST_DIR:g" >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status" $'\n'\
    "output: $output"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status" $'\n'\
    "output: $output"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_equal "$expected" "$output"
}

assert_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    assert_equal "$2" "${lines[$1]}"
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then return 0; fi
    done
    flunk "expected line \`$1'" $'\n'\
    "output: $output"
  fi
}

refute_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    local num_lines="${#lines[@]}"
    if [ "$1" -lt "$num_lines" ]; then
      flunk "output has $num_lines lines"
    fi
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then
        flunk "expected to not find line \`$line'" $'\n'\
        "output: $output"
      fi
    done
  fi
}

assert() {
  if ! "$@"; then
    flunk "failed: $@"
  fi
}

# Output a modified PATH that ensures that the given executable is not present,
# but in which system utils necessary for pyenv operation are still available.
path_without() {
  local path=":${PATH}:"
  for exe; do 
    local found alt util
    for found in $(PATH="$path" type -aP "$exe"); do
      found="${found%/*}"
      if [ "$found" != "${PYENV_ROOT}/shims" ]; then
        alt="${PYENV_TEST_DIR}/$(echo "${found#/}" | tr '/' '-')"
        mkdir -p "$alt"
        for util in bash head cut readlink greadlink; do
          if [ -x "${found}/$util" ]; then
            ln -s "${found}/$util" "${alt}/$util"
          fi
        done
        path="${path/:${found}:/:${alt}:}"
      fi
    done
  done
  path="${path#:}"
  path="${path%:}"
  echo "$path"
}

create_hook() {
  mkdir -p "${PYENV_HOOK_PATH}/$1"
  touch "${PYENV_HOOK_PATH}/$1/$2"
  if [ ! -t 0 ]; then
    cat > "${PYENV_HOOK_PATH}/$1/$2"
  fi
}
