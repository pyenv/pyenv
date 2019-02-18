#!/usr/bin/env bats

load ../test_helper
export PATH="$BATS_TEST_DIRNAME/../../bin:$PATH"

export PYTHON_BUILD_VERSION="${PYTHON_BUILD_VERSION:-3.8-dev}"

@test "Python build works" {
  run python-build "$PYTHON_BUILD_VERSION" "$BATS_TMPDIR/dist"
  assert_success

  [ -e "$BATS_TMPDIR/dist/bin/python" ]
  run "$BATS_TMPDIR/dist/bin/python" -V
  assert_success
  "$BATS_TMPDIR/dist/bin/python" -V >&3 2>&3

  [ -e "$BATS_TMPDIR/dist/bin/pip" ]
  run "$BATS_TMPDIR/dist/bin/pip" -V
  assert_success
  "$BATS_TMPDIR/dist/bin/pip" -V >&3 2>&3
}
