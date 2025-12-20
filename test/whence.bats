#!/usr/bin/env bats

load test_helper

@test "finds versions where present" {
  create_alt_executable_in_version "2.7" "python"
  create_alt_executable_in_version "2.7" "fab"
  create_alt_executable_in_version "3.4" "python"
  create_alt_executable_in_version "3.4" "py.test"

  run pyenv-whence python
  assert_success
  assert_output <<OUT
2.7
3.4
OUT

  run pyenv-whence fab
  assert_success "2.7"

  run pyenv-whence py.test
  assert_success "3.4"
}
