unset PYENV_VERSION
unset PYENV_DIR

setup() {
  export _PYENV_INSTALL_PREFIX="${BATS_TEST_DIRNAME%/*}"
  export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
  if ! enable -f "${_PYENV_INSTALL_PREFIX}"/libexec/pyenv-realpath.dylib realpath 2>/dev/null; then
    if [ -n "$PYENV_NATIVE_EXT" ]; then
      echo "pyenv: failed to load \`realpath' builtin" >&2
      exit 1
    fi
  fi

  local bats_test_tmpdir="$(realpath "${BATS_TEST_TMPDIR}")"
  if [ -z "${bats_test_tmpdir}" ];then
    # Use readlink if running in a container instead of realpath lib
    bats_test_tmpdir="$(readlink -f "${BATS_TEST_TMPDIR}")"
  fi

  # update BATS_TEST_TMPDIR discover by realpath/readlink to avoid "//"
  export BATS_TEST_TMPDIR="${bats_test_tmpdir}"
  export PYENV_TEST_DIR="${BATS_TEST_TMPDIR}/pyenv"
  export PYENV_ROOT="${PYENV_TEST_DIR}/root"
  export HOME="${PYENV_TEST_DIR}/home"
  export PYENV_HOOK_PATH="${PYENV_ROOT}/pyenv.d"

  PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
  PATH="${PYENV_TEST_DIR}/bin:$PATH"
  PATH="${_PYENV_INSTALL_PREFIX}/libexec:$PATH"
  PATH="${BATS_TEST_DIRNAME}/libexec:$PATH"
  PATH="${PYENV_ROOT}/shims:$PATH"
  PATH="${BATS_TEST_TMPDIR}/stubs:$PATH"

  for xdg_var in `env 2>/dev/null | grep ^XDG_ | cut -d= -f1`; do unset "$xdg_var"; done
  unset xdg_var

  # Workaround for Powershell. When tests are run from a terminal,
  # and running a script from a here-document,
  # Powershell 7.5.4 erroneously prints ANSI escape sequences
  # even if its output is redirected, breaking the comparison logic
  export NO_COLOR=1

  # If test specific setup exist, run it
  if [[ $(type -t _setup) == function ]];then
    _setup
  fi
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
  fi
  _assert_output_if_provided "$@"
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status" $'\n'\
    "output: $output"
  fi
  _assert_output_if_provided "$@"
}

assert_equal() {
  _assert_equal_as text "$@"
}

_assert_equal_as() {
  if case "$1" in
    text)
      [[ "$2" != "$3" ]];;
    glob)
      [[ "$3" != $2 ]];;
    *)
      echo "invalid comparison type: \`$1'" >&2; return 1;;
    esac
  then
    { diff -u --label expected --label actual <(echo "$2") <(echo "$3") | cat -te
    } | flunk
  fi
}

_assert_output_if_provided() {
  if [ "$#" -gt 0 ]; then
    assert_output "$1"
  elif [ ! -t 0 ]; then
    local expected=$(cat -)
    if [[ -n $expected ]]; then
      assert_output "$expected"
    fi
  fi
}

assert_output() {
  _assert_output_as text "$@"
}

assert_output_glob() {
  _assert_output_as glob "$@"
}

_assert_output_as() {
  local kind="${1:?}"; shift
  local expected
  if [ $# -eq 0 ]
    then expected="$(cat -)"
    else expected="$1"
  fi
  _assert_equal_as "$kind" "$expected" "$output"
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
        for util in basename bash cut dirname find greadlink gzip head mkdir readlink sed sort tar tr xargs; do
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

create_path_executable() {
  create_executable "${PYENV_TEST_DIR}/bin" "$@"
}

create_alt_executable() {
  create_alt_executable_in_version "${PYENV_VERSION}" "$@"
}

create_alt_executable_in_version() {
  local version="${1:?}"
  shift 1
  create_executable "${PYENV_ROOT}/versions/$version/bin" "$@"
}

create_stub() {
  create_executable "${BATS_TEST_TMPDIR}/stubs" "$@"
}

create_executable() {
  local bin="${1:?}"
  local name="${2:?}"
  shift 2
  mkdir -p "$bin"
  local payload
  # Bats doesn't redirect stdin
  if [[ $# -eq 0 && ! -t 0 ]]; then
    payload="$(cat -)"
  else
    payload="$(printf '%s\n' "$@")"
  fi
  if [[ $payload != "#!/"* ]]; then
    payload="#!$BASH"$'\n'"$payload"
  fi
  echo "$payload" > "${bin}/$name"
  chmod +x "${bin}/$name"
}

create_hook() {
  mkdir -p "${PYENV_HOOK_PATH}/$1"
  touch "${PYENV_HOOK_PATH}/$1/$2"
  if [ ! -t 0 ]; then
    cat > "${PYENV_HOOK_PATH}/$1/$2"
  fi
}

skip_if_nonposix_security() {
  true "${1:?}" "${2:?}"
  test "$@" && skip "UNIX permission bits are being overridden" || true
}
