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
  RBENV_VERSION="1.2.3" run rbenv-sh-shell
  assert_success 'echo "$RBENV_VERSION"'
}

@test "shell unset" {
  run rbenv-sh-shell --unset
  assert_success "unset RBENV_VERSION"
}

@test "shell change invalid version" {
  run rbenv-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
rbenv: version \`1.2.3' not installed
return 1
SH
}

@test "shell change version" {
  mkdir -p "${RBENV_ROOT}/versions/1.2.3"
  run rbenv-sh-shell 1.2.3
  assert_success 'export RBENV_VERSION="1.2.3"'
}
