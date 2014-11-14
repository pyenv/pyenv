#!/usr/bin/env bats

load test_helper

@test "conflicting GREP_OPTIONS" {
  file="${BATS_TMPDIR}/hello"
  echo "hello" > "$file"
  GREP_OPTIONS="-F" run pyenv grep "hell." "$file"
  assert_success
  assert_output "hello"
}
