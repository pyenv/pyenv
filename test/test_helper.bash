RBENV_TEST_DIR="${BATS_TMPDIR}/rbenv"
export RBENV_ROOT="${RBENV_TEST_DIR}/root"
export HOME="${RBENV_TEST_DIR}/home"

unset RBENV_VERSION
unset RBENV_DIR

export PATH="${RBENV_TEST_DIR}/bin:$PATH"
export PATH="${BATS_TEST_DIRNAME}/../libexec:$PATH"
export PATH="${BATS_TEST_DIRNAME}/libexec:$PATH"
export PATH="${RBENV_ROOT}/shims:$PATH"

teardown() {
  rm -rf "$RBENV_TEST_DIR"
}

flunk() {
  echo "$@" | sed "s:${RBENV_ROOT}:\$RBENV_ROOT:" >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status"
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

assert_output() {
  if [ "$output" != "$1" ]; then
    flunk "expected: $1"      || true
    flunk "got:      $output"
  fi
}

assert_line() {
  for line in "${lines[@]}"; do
    if [ "$line" = "$1" ]; then return 0; fi
  done
  flunk "expected line \`$1'"
}

refute_line() {
  for line in "${lines[@]}"; do
    if [ "$line" = "$1" ]; then flunk "expected to not find line \`$line'"; fi
  done
}

assert() {
  if ! "$@"; then
    flunk "failed: $@"
  fi
}
