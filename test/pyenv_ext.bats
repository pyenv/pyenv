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

@test "should use dirname of file argument as PYENV_DIR" {
  mkdir -p "${PYENV_TEST_DIR}/dir1"
  touch "${PYENV_TEST_DIR}/dir1/file.py"
  PYENV_FILE_ARG="${PYENV_TEST_DIR}/dir1/file.py" run pyenv echo PYENV_DIR
  assert_output "${PYENV_TEST_DIR}/dir1"
}

@test "should follow symlink of file argument (#379, #404)" {
  mkdir -p "${PYENV_TEST_DIR}/dir1"
  mkdir -p "${PYENV_TEST_DIR}/dir2"
  touch "${PYENV_TEST_DIR}/dir1/file.py"
  ln -s "${PYENV_TEST_DIR}/dir1/file.py" "${PYENV_TEST_DIR}/dir2/symlink.py"
  PYENV_FILE_ARG="${PYENV_TEST_DIR}/dir2/symlink.py" run pyenv echo PYENV_DIR
  assert_output "${PYENV_TEST_DIR}/dir1"
}
