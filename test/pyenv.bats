#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run pyenv
  assert_success
  assert [ "${lines[0]}" == "pyenv 20141127" ]
}

@test "invalid command" {
  run pyenv does-not-exist
  assert_failure
  assert_output "pyenv: no such command \`does-not-exist'"
}

@test "default PYENV_ROOT" {
  PYENV_ROOT="" HOME=/home/mislav run pyenv root
  assert_success
  assert_output "/home/mislav/.pyenv"
}

@test "inherited PYENV_ROOT" {
  PYENV_ROOT=/opt/pyenv run pyenv root
  assert_success
  assert_output "/opt/pyenv"
}

@test "default PYENV_DIR" {
  run pyenv echo PYENV_DIR
  assert_output "$(pwd)"
}

@test "inherited PYENV_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  PYENV_DIR="$dir" run pyenv echo PYENV_DIR
  assert_output "$dir"
}

@test "invalid PYENV_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  PYENV_DIR="$dir" run pyenv echo PYENV_DIR
  assert_failure
  assert_output "pyenv: cannot change working directory to \`$dir'"
}
