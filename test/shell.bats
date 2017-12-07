#!/usr/bin/env bats

load test_helper

@test "shell integration disabled" {
  run rbenv shell
  assert_failure "rbenv: shell integration not enabled. Run \`rbenv init' for instructions."
}

@test "shell integration enabled" {
  eval "$(rbenv init -)"
  run rbenv shell
  assert_success "rbenv: no shell-specific version configured"
}

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

@test "shell revert" {
  RBENV_SHELL=bash run rbenv-sh-shell -
  assert_success
  assert_line 0 'if [ -n "${RBENV_VERSION_OLD+x}" ]; then'
}

@test "shell revert (fish)" {
  RBENV_SHELL=fish run rbenv-sh-shell -
  assert_success
  assert_line 0 'if set -q RBENV_VERSION_OLD'
}

@test "shell unset" {
  RBENV_SHELL=bash run rbenv-sh-shell --unset
  assert_success
  assert_output <<OUT
RBENV_VERSION_OLD="\$RBENV_VERSION"
unset RBENV_VERSION
OUT
}

@test "shell unset (fish)" {
  RBENV_SHELL=fish run rbenv-sh-shell --unset
  assert_success
  assert_output <<OUT
set -gu RBENV_VERSION_OLD "\$RBENV_VERSION"
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
  assert_success
  assert_output <<OUT
RBENV_VERSION_OLD="\$RBENV_VERSION"
export RBENV_VERSION="1.2.3"
OUT
}

@test "shell change version (fish)" {
  mkdir -p "${RBENV_ROOT}/versions/1.2.3"
  RBENV_SHELL=fish run rbenv-sh-shell 1.2.3
  assert_success
  assert_output <<OUT
set -gu RBENV_VERSION_OLD "\$RBENV_VERSION"
set -gx RBENV_VERSION "1.2.3"
OUT
}
