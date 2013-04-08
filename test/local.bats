#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${RBENV_TEST_DIR}/myproject"
  cd "${RBENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.ruby-version" ]
  run rbenv-local
  assert_failure "rbenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .ruby-version
  run rbenv-local
  assert_success "1.2.3"
}

@test "supports legacy .rbenv-version file" {
  echo "1.2.3" > .rbenv-version
  run rbenv-local
  assert_success "1.2.3"
}

@test "local .ruby-version has precedence over .rbenv-version" {
  echo "1.8" > .rbenv-version
  echo "2.0" > .ruby-version
  run rbenv-local
  assert_success "2.0"
}

@test "ignores version in parent directory" {
  echo "1.2.3" > .ruby-version
  mkdir -p "subdir" && cd "subdir"
  run rbenv-local
  assert_failure
}

@test "ignores RBENV_DIR" {
  echo "1.2.3" > .ruby-version
  mkdir -p "$HOME"
  echo "2.0-home" > "${HOME}/.ruby-version"
  RBENV_DIR="$HOME" run rbenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${RBENV_ROOT}/versions/1.2.3"
  run rbenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .ruby-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .ruby-version
  mkdir -p "${RBENV_ROOT}/versions/1.2.3"
  run rbenv-local
  assert_success "1.0-pre"
  run rbenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .ruby-version)" = "1.2.3" ]
}

@test "renames .rbenv-version to .ruby-version" {
  echo "1.8.7" > .rbenv-version
  mkdir -p "${RBENV_ROOT}/versions/1.9.3"
  run rbenv-local
  assert_success "1.8.7"
  run rbenv-local "1.9.3"
  assert_success
  assert_output <<OUT
rbenv: removed existing \`.rbenv-version' file and migrated
       local version specification to \`.ruby-version' file
OUT
  assert [ ! -e .rbenv-version ]
  assert [ "$(cat .ruby-version)" = "1.9.3" ]
}

@test "doesn't rename .rbenv-version if changing the version failed" {
  echo "1.8.7" > .rbenv-version
  assert [ ! -e "${RBENV_ROOT}/versions/1.9.3" ]
  run rbenv-local "1.9.3"
  assert_failure "rbenv: version \`1.9.3' not installed"
  assert [ ! -e .ruby-version ]
  assert [ "$(cat .rbenv-version)" = "1.8.7" ]
}

@test "unsets local version" {
  touch .ruby-version
  run rbenv-local --unset
  assert_success ""
  assert [ ! -e .rbenv-version ]
}

@test "unsets alternate version file" {
  touch .rbenv-version
  run rbenv-local --unset
  assert_success ""
  assert [ ! -e .rbenv-version ]
}
