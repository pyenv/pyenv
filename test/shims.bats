#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run pyenv-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${PYENV_ROOT}/shims"
  touch "${PYENV_ROOT}/shims/python"
  touch "${PYENV_ROOT}/shims/irb"
  run pyenv-shims
  assert_success
  assert_line "${PYENV_ROOT}/shims/python"
  assert_line "${PYENV_ROOT}/shims/irb"
}

@test "shims --short" {
  mkdir -p "${PYENV_ROOT}/shims"
  touch "${PYENV_ROOT}/shims/python"
  touch "${PYENV_ROOT}/shims/irb"
  run pyenv-shims --short
  assert_success
  assert_line "irb"
  assert_line "python"
}
