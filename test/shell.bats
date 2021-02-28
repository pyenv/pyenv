#!/usr/bin/env bats

load test_helper

@test "shell integration disabled" {
  run pyenv shell
  assert_failure "pyenv: shell integration not enabled. Run \`pyenv init' for instructions."
}

@test "shell integration enabled" {
  eval "$(pyenv init -)"
  run pyenv shell
  assert_success "pyenv: no shell-specific version configured"
}

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

@test "shell revert" {
  PYENV_SHELL=bash run pyenv-sh-shell -
  assert_success
  assert_line 0 'if [ -n "${PYENV_VERSION_OLD+x}" ]; then'
}

@test "shell revert (fish)" {
  PYENV_SHELL=fish run pyenv-sh-shell -
  assert_success
  assert_line 0 'if set -q PYENV_VERSION_OLD'
}

@test "shell unset" {
  PYENV_SHELL=bash run pyenv-sh-shell --unset
  assert_success
  assert_output <<OUT
PYENV_VERSION_OLD="\${PYENV_VERSION-}"
unset PYENV_VERSION
OUT
}

@test "shell unset (fish)" {
  PYENV_SHELL=fish run pyenv-sh-shell --unset
  assert_success
  assert_output <<OUT
set -gu PYENV_VERSION_OLD "\$PYENV_VERSION"
set -e PYENV_VERSION
OUT
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
  assert_success
  assert_output <<OUT
PYENV_VERSION_OLD="\${PYENV_VERSION-}"
export PYENV_VERSION="1.2.3"
OUT
}

@test "shell change version (fish)" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3"
  PYENV_SHELL=fish run pyenv-sh-shell 1.2.3
  assert_success
  assert_output <<OUT
set -gu PYENV_VERSION_OLD "\$PYENV_VERSION"
set -gx PYENV_VERSION "1.2.3"
OUT
}
