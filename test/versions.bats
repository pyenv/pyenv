#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${PYENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$PYENV_TEST_DIR"
  cd "$PYENV_TEST_DIR"
}

stub_system_python() {
  local stub="${PYENV_TEST_DIR}/bin/python"
  mkdir -p "$(dirname "$stub")"
  touch "$stub" && chmod +x "$stub"
}

@test "no versions installed" {
  stub_system_python
  assert [ ! -d "${PYENV_ROOT}/versions" ]
  run pyenv-versions
  assert_success "* system (set by ${PYENV_ROOT}/version)"
}

@test "bare output no versions installed" {
  assert [ ! -d "${PYENV_ROOT}/versions" ]
  run pyenv-versions --bare
  assert_success ""
}

@test "single version installed" {
  stub_system_python
  create_version "1.9"
  run pyenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${PYENV_ROOT}/version)
  1.9
OUT
}

@test "single version bare" {
  create_version "1.9"
  run pyenv-versions --bare
  assert_success "1.9"
}

@test "multiple versions" {
  stub_system_python
  create_version "1.8.7"
  create_version "1.9.3"
  create_version "2.0.0"
  run pyenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${PYENV_ROOT}/version)
  1.8.7
  1.9.3
  2.0.0
OUT
}

@test "indicates current version" {
  stub_system_python
  create_version "1.9.3"
  create_version "2.0.0"
  PYENV_VERSION=1.9.3 run pyenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by PYENV_VERSION environment variable)
  2.0.0
OUT
}

@test "bare doesn't indicate current version" {
  create_version "1.9.3"
  create_version "2.0.0"
  PYENV_VERSION=1.9.3 run pyenv-versions --bare
  assert_success
  assert_output <<OUT
1.9.3
2.0.0
OUT
}

@test "globally selected version" {
  stub_system_python
  create_version "1.9.3"
  create_version "2.0.0"
  cat > "${PYENV_ROOT}/version" <<<"1.9.3"
  run pyenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by ${PYENV_ROOT}/version)
  2.0.0
OUT
}

@test "per-project version" {
  stub_system_python
  create_version "1.9.3"
  create_version "2.0.0"
  cat > ".python-version" <<<"1.9.3"
  run pyenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by ${PYENV_TEST_DIR}/.python-version)
  2.0.0
OUT
}
