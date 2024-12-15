#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$PYENV_TEST_DIR"
  cd "$PYENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run pyenv-version-file-write
  assert_failure "Usage: pyenv version-file-write [-f|--force] <file> <version> [...]"
  run pyenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".python-version" ]
  run pyenv-version-file-write ".python-version" "2.7.6"
  assert_failure "pyenv: version \`2.7.6' not installed"
  assert [ ! -e ".python-version" ]
}

@test "setting nonexistent version succeeds with force" {
  assert [ ! -e ".python-version" ]
  run pyenv-version-file-write --force ".python-version" "2.7.6"
  assert_success
  assert [ -e ".python-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${PYENV_ROOT}/versions/2.7.6"
  assert [ ! -e "my-version" ]
  run pyenv-version-file-write "${PWD}/my-version" "2.7.6"
  assert_success ""
  assert [ "$(cat my-version)" = "2.7.6" ]
}
