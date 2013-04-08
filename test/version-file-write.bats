#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run rbenv-version-file-write
  assert_failure "Usage: rbenv version-file-write <file> <version>"
  run rbenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".ruby-version" ]
  run rbenv-version-file-write ".ruby-version" "1.8.7"
  assert_failure "rbenv: version \`1.8.7' not installed"
  assert [ ! -e ".ruby-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${RBENV_ROOT}/versions/1.8.7"
  assert [ ! -e "my-version" ]
  run rbenv-version-file-write "${PWD}/my-version" "1.8.7"
  assert_success ""
  assert [ "$(cat my-version)" = "1.8.7" ]
}
