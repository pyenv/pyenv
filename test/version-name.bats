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
  create_version "2.7.6"
  create_version "3.3.3"

  cat > ".python-version" <<<"2.7.6"
  run pyenv-version-name
  assert_success "2.7.6"

  PYENV_VERSION=3.3.3 run pyenv-version-name
  assert_success "3.3.3"
}

@test "local file has precedence over global" {
  create_version "2.7.6"
  create_version "3.3.3"

  cat > "${PYENV_ROOT}/version" <<<"2.7.6"
  run pyenv-version-name
  assert_success "2.7.6"

  cat > ".python-version" <<<"3.3.3"
  run pyenv-version-name
  assert_success "3.3.3"
}

@test "missing version" {
  PYENV_VERSION=1.2 run pyenv-version-name
  assert_failure "pyenv: version \`1.2' is not installed (set by PYENV_VERSION environment variable)"
}

@test "one missing version (second missing)" {
  create_version "3.4.2"
  PYENV_VERSION="3.4.2:1.2" run pyenv-version-name
  assert_failure
  assert_output <<OUT
pyenv: version \`1.2' is not installed (set by PYENV_VERSION environment variable)
3.4.2
OUT
}

@test "one missing version (first missing)" {
  create_version "3.4.2"
  PYENV_VERSION="1.2:3.4.2" run pyenv-version-name
  assert_failure
  assert_output <<OUT
pyenv: version \`1.2' is not installed (set by PYENV_VERSION environment variable)
3.4.2
OUT
}

pyenv-version-name-without-stderr() {
  pyenv-version-name 2>/dev/null
}

@test "one missing version (without stderr)" {
  create_version "3.4.2"
  PYENV_VERSION="1.2:3.4.2" run pyenv-version-name-without-stderr
  assert_failure
  assert_output <<OUT
3.4.2
OUT
}

@test "version with prefix in name" {
  create_version "2.7.6"
  cat > ".python-version" <<<"python-2.7.6"
  run pyenv-version-name
  assert_success
  assert_output "2.7.6"
}
