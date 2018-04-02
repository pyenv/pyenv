#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$PYENV_TEST_DIR"
  cd "$PYENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  echo "system" > "$1"
}

@test "detects global 'version' file" {
  create_file "${PYENV_ROOT}/version"
  run pyenv-version-file
  assert_success "${PYENV_ROOT}/version"
}

@test "prints global file if no version files exist" {
  assert [ ! -e "${PYENV_ROOT}/version" ]
  assert [ ! -e ".python-version" ]
  run pyenv-version-file
  assert_success "${PYENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".python-version"
  run pyenv-version-file
  assert_success "${PYENV_TEST_DIR}/.python-version"
}

@test "in parent directory" {
  create_file ".python-version"
  mkdir -p project
  cd project
  run pyenv-version-file
  assert_success "${PYENV_TEST_DIR}/.python-version"
}

@test "topmost file has precedence" {
  create_file ".python-version"
  create_file "project/.python-version"
  cd project
  run pyenv-version-file
  assert_success "${PYENV_TEST_DIR}/project/.python-version"
}

@test "PYENV_DIR has precedence over PWD" {
  create_file "widget/.python-version"
  create_file "project/.python-version"
  cd project
  PYENV_DIR="${PYENV_TEST_DIR}/widget" run pyenv-version-file
  assert_success "${PYENV_TEST_DIR}/widget/.python-version"
}

@test "PWD is searched if PYENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.python-version"
  cd project
  PYENV_DIR="${PYENV_TEST_DIR}/widget/blank" run pyenv-version-file
  assert_success "${PYENV_TEST_DIR}/project/.python-version"
}

@test "finds version file in target directory" {
  create_file "project/.python-version"
  run pyenv-version-file "${PWD}/project"
  assert_success "${PYENV_TEST_DIR}/project/.python-version"
}

@test "fails when no version file in target directory" {
  run pyenv-version-file "$PWD"
  assert_failure ""
}
