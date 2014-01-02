#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$PYENV_TEST_DIR"
  cd "$PYENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${PYENV_ROOT}/version" ]
  run pyenv-version-origin
  assert_success "${PYENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$PYENV_ROOT"
  touch "${PYENV_ROOT}/version"
  run pyenv-version-origin
  assert_success "${PYENV_ROOT}/version"
}

@test "detects PYENV_VERSION" {
  PYENV_VERSION=1 run pyenv-version-origin
  assert_success "PYENV_VERSION environment variable"
}

@test "detects local file" {
  touch .python-version
  run pyenv-version-origin
  assert_success "${PWD}/.python-version"
}

@test "detects alternate version file" {
  touch .pyenv-version
  run pyenv-version-origin
  assert_success "${PWD}/.pyenv-version"
}
