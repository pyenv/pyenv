#!/usr/bin/env bats

load test_helper

@test "not enough arguments for python-build" {
  # use empty inline definition so nothing gets built anyway
  local definition="${BATS_TEST_TMPDIR}/build-definition"
  echo '' > "$definition"

  run python-build "$definition"
  assert_failure
  assert_output_contains 'Usage: python-build'
}

@test "extra arguments for python-build" {
  # use empty inline definition so nothing gets built anyway
  local definition="${BATS_TEST_TMPDIR}/build-definition"
  echo '' > "$definition"

  run python-build "$definition" "${BATS_TEST_TMPDIR}/install" ""
  assert_failure
  assert_output_contains 'Usage: python-build'
}
