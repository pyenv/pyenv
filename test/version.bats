#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${RBENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${RBENV_ROOT}/versions" ]
  run rbenv-version
  assert_success "system (set by ${RBENV_ROOT}/version)"
}

@test "set by RBENV_VERSION" {
  create_version "1.9.3"
  RBENV_VERSION=1.9.3 run rbenv-version
  assert_success "1.9.3 (set by RBENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "1.9.3"
  cat > ".ruby-version" <<<"1.9.3"
  run rbenv-version
  assert_success "1.9.3 (set by ${PWD}/.ruby-version)"
}

@test "set by global file" {
  create_version "1.9.3"
  cat > "${RBENV_ROOT}/version" <<<"1.9.3"
  run rbenv-version
  assert_success "1.9.3 (set by ${RBENV_ROOT}/version)"
}
