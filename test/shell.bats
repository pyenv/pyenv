#!/usr/bin/env bats

load test_helper

@test "no shell version" {
  mkdir -p "${RBENV_TEST_DIR}/myproject"
  cd "${RBENV_TEST_DIR}/myproject"
  echo "1.2.3" > .ruby-version
  RBENV_VERSION="" run rbenv-sh-shell
  assert_failure "rbenv: no shell-specific version configured"
}

@test "shell version" {
  SHELL=/bin/bash RBENV_VERSION="1.2.3" run rbenv-sh-shell
  assert_success 'echo "$RBENV_VERSION"'
}

@test "shell version (fish)" {
  SHELL=/usr/bin/fish RBENV_VERSION="1.2.3" run rbenv-sh-shell
  assert_success 'echo "$RBENV_VERSION"'
}

@test "shell unset" {
  SHELL=/bin/bash run rbenv-sh-shell --unset
  assert_success "unset RBENV_VERSION"
}

@test "shell unset (fish)" {
  SHELL=/usr/bin/fish run rbenv-sh-shell --unset
  assert_success "set -e RBENV_VERSION"
}

@test "shell change invalid version" {
  run rbenv-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
rbenv: version \`1.2.3' not installed
false
SH
}

@test "shell change version" {
  mkdir -p "${RBENV_ROOT}/versions/1.2.3"
  SHELL=/bin/bash run rbenv-sh-shell 1.2.3
  assert_success 'export RBENV_VERSION="1.2.3"'
}

@test "shell change version (fish)" {
  mkdir -p "${RBENV_ROOT}/versions/1.2.3"
  SHELL=/usr/bin/fish run rbenv-sh-shell 1.2.3
  assert_success 'setenv RBENV_VERSION "1.2.3"'
}
