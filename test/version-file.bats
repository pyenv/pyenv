#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  echo "system" > "$1"
}

@test "detects global 'version' file" {
  create_file "${RBENV_ROOT}/version"
  run rbenv-version-file
  assert_success "${RBENV_ROOT}/version"
}

@test "prints global file if no version files exist" {
  assert [ ! -e "${RBENV_ROOT}/version" ]
  assert [ ! -e ".ruby-version" ]
  run rbenv-version-file
  assert_success "${RBENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".ruby-version"
  run rbenv-version-file
  assert_success "${RBENV_TEST_DIR}/.ruby-version"
}

@test "in parent directory" {
  create_file ".ruby-version"
  mkdir -p project
  cd project
  run rbenv-version-file
  assert_success "${RBENV_TEST_DIR}/.ruby-version"
}

@test "topmost file has precedence" {
  create_file ".ruby-version"
  create_file "project/.ruby-version"
  cd project
  run rbenv-version-file
  assert_success "${RBENV_TEST_DIR}/project/.ruby-version"
}

@test "RBENV_DIR has precedence over PWD" {
  create_file "widget/.ruby-version"
  create_file "project/.ruby-version"
  cd project
  RBENV_DIR="${RBENV_TEST_DIR}/widget" run rbenv-version-file
  assert_success "${RBENV_TEST_DIR}/widget/.ruby-version"
}

@test "PWD is searched if RBENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.ruby-version"
  cd project
  RBENV_DIR="${RBENV_TEST_DIR}/widget/blank" run rbenv-version-file
  assert_success "${RBENV_TEST_DIR}/project/.ruby-version"
}

@test "finds version file in target directory" {
  create_file "project/.ruby-version"
  run rbenv-version-file "${PWD}/project"
  assert_success "${RBENV_TEST_DIR}/project/.ruby-version"
}

@test "fails when no version file in target directory" {
  run rbenv-version-file "$PWD"
  assert_failure ""
}
