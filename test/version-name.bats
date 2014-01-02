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
  run pyenv-version-name
  assert_success "system"
}

@test "system version is not checked for existance" {
  PYENV_VERSION=system run pyenv-version-name
  assert_success "system"
}

@test "PYENV_VERSION has precedence over local" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > ".python-version" <<<"1.8.7"
  run pyenv-version-name
  assert_success "1.8.7"

  PYENV_VERSION=1.9.3 run pyenv-version-name
  assert_success "1.9.3"
}

@test "local file has precedence over global" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > "${PYENV_ROOT}/version" <<<"1.8.7"
  run pyenv-version-name
  assert_success "1.8.7"

  cat > ".python-version" <<<"1.9.3"
  run pyenv-version-name
  assert_success "1.9.3"
}

@test "missing version" {
  PYENV_VERSION=1.2 run pyenv-version-name
  assert_failure "pyenv: version \`1.2' is not installed"
}

@test "version with prefix in name" {
  create_version "1.8.7"
  cat > ".python-version" <<<"python-1.8.7"
  run pyenv-version-name
  assert_success
  assert_output <<OUT
warning: ignoring extraneous \`python-' prefix in version \`python-1.8.7'
         (set by ${PWD}/.python-version)
1.8.7
OUT
}
