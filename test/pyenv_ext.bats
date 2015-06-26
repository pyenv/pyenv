#!/usr/bin/env bats

load test_helper

@test "prefixes" {
  mkdir -p "${PYENV_TEST_DIR}/bin"
  touch "${PYENV_TEST_DIR}/bin/python"
  chmod +x "${PYENV_TEST_DIR}/bin/python"
  mkdir -p "${PYENV_ROOT}/versions/2.7.10"
  PYENV_VERSION="system:2.7.10" run pyenv-prefix
  assert_success "${PYENV_TEST_DIR}:${PYENV_ROOT}/versions/2.7.10"
  PYENV_VERSION="2.7.10:system" run pyenv-prefix
  assert_success "${PYENV_ROOT}/versions/2.7.10:${PYENV_TEST_DIR}"
}
