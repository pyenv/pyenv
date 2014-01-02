#!/usr/bin/env bats

load test_helper

@test "no shell version" {
  mkdir -p "${PYENV_TEST_DIR}/myproject"
  cd "${PYENV_TEST_DIR}/myproject"
  echo "1.2.3" > .python-version
  PYENV_VERSION="" run pyenv-sh-shell
  assert_failure "pyenv: no shell-specific version configured"
}

@test "shell version" {
  PYENV_SHELL=bash PYENV_VERSION="1.2.3" run pyenv-sh-shell
  assert_success 'echo "$PYENV_VERSION"'
}

@test "shell version (fish)" {
  PYENV_SHELL=fish PYENV_VERSION="1.2.3" run pyenv-sh-shell
  assert_success 'echo "$PYENV_VERSION"'
}

@test "shell unset" {
  PYENV_SHELL=bash run pyenv-sh-shell --unset
  assert_success "unset PYENV_VERSION"
}

@test "shell unset (fish)" {
  PYENV_SHELL=fish run pyenv-sh-shell --unset
  assert_success "set -e PYENV_VERSION"
}

@test "shell change invalid version" {
  run pyenv-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
pyenv: version \`1.2.3' not installed
false
SH
}

@test "shell change version" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3"
  PYENV_SHELL=bash run pyenv-sh-shell 1.2.3
  assert_success 'export PYENV_VERSION="1.2.3"'
}

@test "shell change version (fish)" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3"
  PYENV_SHELL=fish run pyenv-sh-shell 1.2.3
  assert_success 'setenv PYENV_VERSION "1.2.3"'
}
