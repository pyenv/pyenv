#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${RBENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
}

@test "no versions installed" {
  assert [ ! -d "${RBENV_ROOT}/versions" ]
  run rbenv-versions
  assert_success "* system (set by ${RBENV_ROOT}/version)"
}

@test "bare output no versions installed" {
  assert [ ! -d "${RBENV_ROOT}/versions" ]
  run rbenv-versions --bare
  assert_success ""
}

@test "single version installed" {
  create_version "1.9"
  run rbenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${RBENV_ROOT}/version)
  1.9
OUT
}

@test "single version bare" {
  create_version "1.9"
  run rbenv-versions --bare
  assert_success "1.9"
}

@test "multiple versions" {
  create_version "1.8.7"
  create_version "1.9.3"
  create_version "2.0.0"
  run rbenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${RBENV_ROOT}/version)
  1.8.7
  1.9.3
  2.0.0
OUT
}

@test "indicates current version" {
  create_version "1.9.3"
  create_version "2.0.0"
  RBENV_VERSION=1.9.3 run rbenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by RBENV_VERSION environment variable)
  2.0.0
OUT
}

@test "bare doesn't indicate current version" {
  create_version "1.9.3"
  create_version "2.0.0"
  RBENV_VERSION=1.9.3 run rbenv-versions --bare
  assert_success
  assert_output <<OUT
1.9.3
2.0.0
OUT
}

@test "globally selected version" {
  create_version "1.9.3"
  create_version "2.0.0"
  cat > "${RBENV_ROOT}/version" <<<"1.9.3"
  run rbenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by ${RBENV_ROOT}/version)
  2.0.0
OUT
}

@test "per-project version" {
  create_version "1.9.3"
  create_version "2.0.0"
  cat > ".ruby-version" <<<"1.9.3"
  run rbenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by ${RBENV_TEST_DIR}/.ruby-version)
  2.0.0
OUT
}
