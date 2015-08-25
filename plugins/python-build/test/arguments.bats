#!/usr/bin/env bats

load test_helper

@test "not enough arguments for python-build" {
  # use empty inline definition so nothing gets built anyway
  local definition="${TMP}/build-definition"
  echo '' > "$definition"

  run python-build "$definition"
  assert_failure
  assert_output_contains 'Usage: python-build'
}

@test "extra arguments for python-build" {
  # use empty inline definition so nothing gets built anyway
  local definition="${TMP}/build-definition"
  echo '' > "$definition"

  run python-build "$definition" "${TMP}/install" ""
  assert_failure
  assert_output_contains 'Usage: python-build'
}
