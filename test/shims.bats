#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run rbenv-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${RBENV_ROOT}/shims"
  touch "${RBENV_ROOT}/shims/ruby"
  touch "${RBENV_ROOT}/shims/irb"
  run rbenv-shims
  assert_success
  assert_line "${RBENV_ROOT}/shims/ruby"
  assert_line "${RBENV_ROOT}/shims/irb"
}

@test "shims --short" {
  mkdir -p "${RBENV_ROOT}/shims"
  touch "${RBENV_ROOT}/shims/ruby"
  touch "${RBENV_ROOT}/shims/irb"
  run rbenv-shims --short
  assert_success
  assert_line "irb"
  assert_line "ruby"
}
