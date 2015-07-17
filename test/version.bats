#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${PYENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$PYENV_TEST_DIR"
  cd "$PYENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${PYENV_ROOT}/versions" ]
  run pyenv-version
  assert_success "system (set by ${PYENV_ROOT}/version)"
}

@test "set by PYENV_VERSION" {
  create_version "3.3.3"
  PYENV_VERSION=3.3.3 run pyenv-version
  assert_success "3.3.3 (set by PYENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "3.3.3"
  cat > ".python-version" <<<"3.3.3"
  run pyenv-version
  assert_success "3.3.3 (set by ${PWD}/.python-version)"
}

@test "set by global file" {
  create_version "3.3.3"
  cat > "${PYENV_ROOT}/version" <<<"3.3.3"
  run pyenv-version
  assert_success "3.3.3 (set by ${PYENV_ROOT}/version)"
}

@test "set by PYENV_VERSION, one missing" {
  create_version "3.3.3"
  PYENV_VERSION=3.3.3:1.2 run pyenv-version
  assert_failure
  assert_output <<OUT
pyenv: version \`1.2' is not installed (set by PYENV_VERSION environment variable)
3.3.3 (set by PYENV_VERSION environment variable)
OUT
}

@test "set by PYENV_VERSION, two missing" {
  create_version "3.3.3"
  PYENV_VERSION=3.4.2:3.3.3:1.2 run pyenv-version
  assert_failure
  assert_output <<OUT
pyenv: version \`3.4.2' is not installed (set by PYENV_VERSION environment variable)
pyenv: version \`1.2' is not installed (set by PYENV_VERSION environment variable)
3.3.3 (set by PYENV_VERSION environment variable)
OUT
}

pyenv-version-without-stderr() {
  pyenv-version 2>/dev/null
}

@test "set by PYENV_VERSION, one missing (stderr filtered)" {
  create_version "3.3.3"
  PYENV_VERSION=3.4.2:3.3.3 run pyenv-version-without-stderr
  assert_failure
  assert_output <<OUT
3.3.3 (set by PYENV_VERSION environment variable)
OUT
}
