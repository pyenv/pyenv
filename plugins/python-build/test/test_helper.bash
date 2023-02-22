export TMP="$BATS_TEST_DIRNAME/tmp"
export PYTHON_BUILD_CURL_OPTS=
export PYTHON_BUILD_HTTP_CLIENT="curl"

if [ "$FIXTURE_ROOT" != "$BATS_TEST_DIRNAME/fixtures" ]; then
  export FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures"
  export INSTALL_ROOT="$TMP/install"
  PATH="/usr/bin:/bin:/usr/sbin:/sbin"
  if [ "FreeBSD" = "$(uname -s)" ]; then
    PATH="/usr/local/bin:$PATH"
  fi
  PATH="$BATS_TEST_DIRNAME/../bin:$PATH"
  PATH="$TMP/bin:$PATH"
  export PATH
fi

teardown() {
  rm -fr "${TMP:?}"/*
}

stub() {
  local program="$1"
  local prefix="$(echo "$program" | tr a-z- A-Z_)"
  shift

  export "${prefix}_STUB_PLAN"="${TMP}/${program}-stub-plan"
  export "${prefix}_STUB_RUN"="${TMP}/${program}-stub-run"
  export "${prefix}_STUB_LOG"="${TMP}/${program}-stub-log"
  export "${prefix}_STUB_END"=

  mkdir -p "${TMP}/bin"
  ln -sf "${BATS_TEST_DIRNAME}/stubs/stub" "${TMP}/bin/${program}"

  touch "${TMP}/${program}-stub-plan"
  for arg in "$@"; do printf "%s\n" "$arg" >> "${TMP}/${program}-stub-plan"; done
}

unstub() {
  local program="$1"
  local prefix="$(echo "$program" | tr a-z- A-Z_)"
  local path="${TMP}/bin/${program}"

  export "${prefix}_STUB_END"=1

  local STATUS=0
  "$path" || STATUS="$?"

  rm -f "$path"
  rm -f "${TMP}/${program}-stub-plan" "${TMP}/${program}-stub-run"
  return "$STATUS"
}

run_inline_definition() {
  local definition="${TMP}/build-definition"
  cat > "$definition"
  run python-build "$definition" "${1:-$INSTALL_ROOT}"
}

install_fixture() {
  local args

  while [ "${1#-}" != "$1" ]; do
    args="$args $1"
    shift 1
  done

  local name="$1"
  local destination="$2"
  [ -n "$destination" ] || destination="$INSTALL_ROOT"

  run python-build $args "$FIXTURE_ROOT/$name" "$destination"
}

assert() {
  if ! "$@"; then
    flunk "failed: $@"
  fi
}

refute() {
  if "$@"; then
    flunk "expected to fail: $@"
  fi
}

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed "s:${TMP}:\${TMP}:g" >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    { echo "command failed with exit status $status"
      echo "output: $output"
    } | flunk
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected:"
      echo "$1"
      echo "actual:"
      echo "$2"
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

assert_output_contains() {
  local expected="$1"
  if [ -z "$expected" ]; then
    echo "assert_output_contains needs an argument" >&2
    return 1
  fi
  echo "$output" | $(type -P ggrep grep | head -n1) -F "$expected" >/dev/null || {
    { echo "expected output to contain $expected"
      echo "actual: $output"
    } | flunk
  }
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

