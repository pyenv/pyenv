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
  RBENV_SHELL=bash RBENV_VERSION="1.2.3" run rbenv-sh-shell
  assert_success 'echo "$RBENV_VERSION"'
}

@test "shell version (fish)" {
  RBENV_SHELL=fish RBENV_VERSION="1.2.3" run rbenv-sh-shell
  assert_success 'echo "$RBENV_VERSION"'
}

@test "shell unset" {
  RBENV_SHELL=bash run rbenv-sh-shell --unset
  assert_output <<OUT
unset OLD_RBENV_VERSION
unset RBENV_VERSION
OUT
}

@test "shell unset (fish)" {
  RBENV_SHELL=fish run rbenv-sh-shell --unset
  assert_output <<OUT
set -e OLD_RBENV_VERSION
set -e RBENV_VERSION
OUT
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
  RBENV_SHELL=bash run rbenv-sh-shell 1.2.3
  assert_output <<OUT
export OLD_RBENV_VERSION=""
export RBENV_VERSION="1.2.3"
OUT
}

@test "shell change version pushes away previous OLD_RBENV_VERSION" {
  mkdir -p "${RBENV_ROOT}/versions/1.2.3"
  mkdir -p "${RBENV_ROOT}/versions/1.2.4"
  mkdir -p "${RBENV_ROOT}/versions/1.2.5"
  export OLD_RBENV_VERSION="1.2.3"
  export RBENV_VERSION="1.2.4"
  RBENV_SHELL=bash run rbenv-sh-shell 1.2.5
  assert_output <<OUT
export OLD_RBENV_VERSION="1.2.4"
export RBENV_VERSION="1.2.5"
OUT
}

@test "shell change version to the same version does not lose OLD_RBENV_VERSION" {
  mkdir -p "${RBENV_ROOT}/versions/1.2.3"
  mkdir -p "${RBENV_ROOT}/versions/1.2.4"
  export OLD_RBENV_VERSION="1.2.3"
  export RBENV_VERSION="1.2.4"
  RBENV_SHELL=bash run rbenv-sh-shell 1.2.4
  assert_output ''
}

@test "shell change version to - swaps old and new versions" {
  mkdir -p "${RBENV_ROOT}/versions/1.2.3"
  mkdir -p "${RBENV_ROOT}/versions/1.2.4"
  export OLD_RBENV_VERSION="1.2.3"
  export RBENV_VERSION="1.2.4"
  RBENV_SHELL=bash run rbenv-sh-shell -
  assert_output <<OUT
export OLD_RBENV_VERSION="1.2.4"
export RBENV_VERSION="1.2.3"
OUT
}

@test "shell change version to - with no previous is an error" {
  mkdir -p "${RBENV_ROOT}/versions/1.2.3"
  RBENV_SHELL=bash run rbenv-sh-shell -
  assert_failure <<OUT
rbenv: OLD_RBENV_VERSION not set
OUT
}

@test "shell change version (fish)" {
  mkdir -p "${RBENV_ROOT}/versions/1.2.3"
  RBENV_SHELL=fish run rbenv-sh-shell 1.2.3
  assert_success 'setenv RBENV_VERSION "1.2.3"'
}
