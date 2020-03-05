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

@test "no version with custom name" {
  echo "9.9.9" > .python-version
  assert [ ! -e "${PWD}/.python-version-custom" ]
  PYENV_VERSION_FILENAME=.python-version-custom run pyenv-local
  assert_failure "pyenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .python-version
  run pyenv-local
  assert_success "1.2.3"
}

@test "local version with custom name" {
  echo "9.9.9" > .python-version
  echo "1.2.3" > .python-version-custom
  PYENV_VERSION_FILENAME=.python-version-custom run pyenv-local
  assert_success "1.2.3"
}

@test "discovers version file in parent directory" {
  echo "1.2.3" > .python-version
  mkdir -p "subdir" && cd "subdir"
  run pyenv-local
  assert_success "1.2.3"
}

@test "discovers version file in parent directory with custom name" {
  echo "9.9.9" > .python-version
  echo "1.2.3" > .python-version-custom
  mkdir -p "subdir" && cd "subdir"
  PYENV_VERSION_FILENAME=.python-version-custom run pyenv-local
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

@test "sets local version with custom name" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3"
  PYENV_VERSION_FILENAME=.python-version-custom run pyenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .python-version-custom)" = "1.2.3" ]
  assert [ ! -e "${PWD}/.python-version" ]
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

@test "changes local version with custom name" {
  echo "1.0-pre" > .python-version-custom
  mkdir -p "${PYENV_ROOT}/versions/1.2.3"
  PYENV_VERSION_FILENAME=.python-version-custom run pyenv-local
  assert_success "1.0-pre"
  PYENV_VERSION_FILENAME=.python-version-custom run pyenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .python-version-custom)" = "1.2.3" ]
  assert [ ! -e "${PWD}/.python-version" ]
}

@test "unsets local version" {
  touch .python-version
  run pyenv-local --unset
  assert_success ""
  assert [ ! -e .python-version ]
}

@test "unsets local version with custom name" {
  touch .python-version
  touch .python-version-custom
  PYENV_VERSION_FILENAME=.python-version-custom run pyenv-local --unset
  assert_success ""
  assert [ ! -e .python-version-custom ]
  assert [ -e .python-version ]
}
