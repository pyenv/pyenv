#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run pyenv
  assert_failure
  assert_line 0 "$(pyenv---version)"
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

@test "adds its own libexec and plugin bin dirs to PATH" {
  mkdir -p "$PYENV_ROOT"/plugins/python-build/bin
  mkdir -p "$PYENV_ROOT"/plugins/pyenv-each/bin
  run pyenv echo -F: "PATH"
  assert_success
  assert_line 0 "${BATS_TEST_DIRNAME%/*}/libexec"
  assert_line 1 "${PYENV_ROOT}/plugins/python-build/bin"
  assert_line 2 "${PYENV_ROOT}/plugins/pyenv-each/bin"
  assert_line 3 "${BATS_TEST_DIRNAME%/*}/plugins/python-build/bin"
}

@test "PYENV_HOOK_PATH preserves value from environment" {
  PYENV_HOOK_PATH=/my/hook/path:/other/hooks run pyenv echo -F: "PYENV_HOOK_PATH"
  assert_success
  assert_line 0 "/my/hook/path"
  assert_line 1 "/other/hooks"
  assert_line 2 "${PYENV_ROOT}/pyenv.d"
}

@test "PYENV_HOOK_PATH includes pyenv built-in plugins" {
  unset PYENV_HOOK_PATH
  run pyenv echo "PYENV_HOOK_PATH"
  assert_success "${PYENV_ROOT}/pyenv.d:${BATS_TEST_DIRNAME%/*}/pyenv.d:/usr/etc/pyenv.d:/usr/local/etc/pyenv.d:/etc/pyenv.d:/usr/lib/pyenv/hooks"
}
