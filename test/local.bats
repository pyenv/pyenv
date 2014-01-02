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

@test "supports legacy .pyenv-version file" {
  echo "1.2.3" > .pyenv-version
  run pyenv-local
  assert_success "1.2.3"
}

@test "local .python-version has precedence over .pyenv-version" {
  echo "2.7" > .pyenv-version
  echo "3.4" > .python-version
  run pyenv-local
  assert_success "3.4"
}

@test "ignores version in parent directory" {
  echo "1.2.3" > .python-version
  mkdir -p "subdir" && cd "subdir"
  run pyenv-local
  assert_failure
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

@test "renames .pyenv-version to .python-version" {
  echo "2.7.6" > .pyenv-version
  mkdir -p "${PYENV_ROOT}/versions/3.3.3"
  run pyenv-local
  assert_success "2.7.6"
  run pyenv-local "3.3.3"
  assert_success
  assert_output <<OUT
pyenv: removed existing \`.pyenv-version' file and migrated
       local version specification to \`.python-version' file
OUT
  assert [ ! -e .pyenv-version ]
  assert [ "$(cat .python-version)" = "3.3.3" ]
}

@test "doesn't rename .pyenv-version if changing the version failed" {
  echo "2.7.6" > .pyenv-version
  assert [ ! -e "${PYENV_ROOT}/versions/3.3.3" ]
  run pyenv-local "3.3.3"
  assert_failure "pyenv: version \`3.3.3' not installed"
  assert [ ! -e .python-version ]
  assert [ "$(cat .pyenv-version)" = "2.7.6" ]
}

@test "unsets local version" {
  touch .python-version
  run pyenv-local --unset
  assert_success ""
  assert [ ! -e .pyenv-version ]
}

@test "unsets alternate version file" {
  touch .pyenv-version
  run pyenv-local --unset
  assert_success ""
  assert [ ! -e .pyenv-version ]
}
