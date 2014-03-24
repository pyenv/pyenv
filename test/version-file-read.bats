#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${PYENV_TEST_DIR}/myproject"
  cd "${PYENV_TEST_DIR}/myproject"
}

@test "fails without arguments" {
  run pyenv-version-file-read
  assert_failure ""
}

@test "fails for invalid file" {
  run pyenv-version-file-read "non-existent"
  assert_failure ""
}

@test "fails for blank file" {
  echo > my-version
  run pyenv-version-file-read my-version
  assert_failure ""
}

@test "reads simple version file" {
  cat > my-version <<<"3.3.5"
  run pyenv-version-file-read my-version
  assert_success "3.3.5"
}

@test "ignores leading spaces" {
  cat > my-version <<<"  3.3.5"
  run pyenv-version-file-read my-version
  assert_success "3.3.5"
}

@test "reads only the first word from file" {
  cat > my-version <<<"3.3.5 2.7.6 hi"
  run pyenv-version-file-read my-version
  assert_success "3.3.5"
}

@test "loads *not* only the first line in file" {
  cat > my-version <<IN
2.7.6 one
3.3.5 two
IN
  run pyenv-version-file-read my-version
  assert_success "2.7.6:3.3.5"
}

@test "ignores leading blank lines" {
  cat > my-version <<IN

3.3.5
IN
  run pyenv-version-file-read my-version
  assert_success "3.3.5"
}

@test "handles the file with no trailing newline" {
  echo -n "2.7.6" > my-version
  run pyenv-version-file-read my-version
  assert_success "2.7.6"
}

@test "ignores carriage returns" {
  cat > my-version <<< $'3.3.5\r'
  run pyenv-version-file-read my-version
  assert_success "3.3.5"
}
