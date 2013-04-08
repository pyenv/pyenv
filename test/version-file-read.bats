#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${RBENV_TEST_DIR}/myproject"
  cd "${RBENV_TEST_DIR}/myproject"
}

@test "fails without arguments" {
  run rbenv-version-file-read
  assert_failure ""
}

@test "fails for invalid file" {
  run rbenv-version-file-read "non-existent"
  assert_failure ""
}

@test "reads simple version file" {
  cat > my-version <<<"1.9.3"
  run rbenv-version-file-read my-version
  assert_success "1.9.3"
}

@test "reads only the first word from file" {
  cat > my-version <<<"1.9.3-p194@tag 1.8.7 hi"
  run rbenv-version-file-read my-version
  assert_success "1.9.3-p194@tag"
}

@test "loads only the first line in file" {
  cat > my-version <<IN
1.8.7 one
1.9.3 two
IN
  run rbenv-version-file-read my-version
  assert_success "1.8.7"
}
