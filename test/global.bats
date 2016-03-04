#!/usr/bin/env bats

load test_helper

@test "default" {
  run pyenv-global
  assert_success
  assert_output "system"
}

@test "read PYENV_ROOT/version" {
  mkdir -p "$PYENV_ROOT"
  echo "1.2.3" > "$PYENV_ROOT/version"
  run pyenv-global
  assert_success
  assert_output "1.2.3"
}

@test "set PYENV_ROOT/version" {
  mkdir -p "$PYENV_ROOT/versions/1.2.3"
  run pyenv-global "1.2.3"
  assert_success
  run pyenv-global
  assert_success "1.2.3"
}

@test "fail setting invalid PYENV_ROOT/version" {
  mkdir -p "$PYENV_ROOT"
  run pyenv-global "1.2.3"
  assert_failure "pyenv: version \`1.2.3' not installed"
}
