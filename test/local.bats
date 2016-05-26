#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${PYENV_TEST_DIR}/myproject"
  cd "${PYENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.python-version" ]
  run pyenv-local
  assert_failure "pyenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .python-version
  run pyenv-local
  assert_success "1.2.3"
}

@test "discovers version file in parent directory" {
  echo "1.2.3" > .python-version
  mkdir -p "subdir" && cd "subdir"
  run pyenv-local
  assert_success "1.2.3"
}

@test "ignores PYENV_DIR" {
  echo "1.2.3" > .python-version
  mkdir -p "$HOME"
  echo "3.4-home" > "${HOME}/.python-version"
  PYENV_DIR="$HOME" run pyenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3"
  run pyenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .python-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .python-version
  mkdir -p "${PYENV_ROOT}/versions/1.2.3"
  run pyenv-local
  assert_success "1.0-pre"
  run pyenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .python-version)" = "1.2.3" ]
}

@test "unsets local version" {
  touch .python-version
  run pyenv-local --unset
  assert_success ""
  assert [ ! -e .python-version ]
}
