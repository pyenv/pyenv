#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${PYENV_TEST_DIR}/myproject"
  cd "${PYENV_TEST_DIR}/myproject"
  echo "1.2.3" > .python-version
  mkdir -p "${PYENV_ROOT}/versions/1.2.3"
  run pyenv-prefix
  assert_success "${PYENV_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  PYENV_VERSION="1.2.3" run pyenv-prefix
  assert_failure "pyenv: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${PYENV_TEST_DIR}/bin"
  touch "${PYENV_TEST_DIR}/bin/python"
  chmod +x "${PYENV_TEST_DIR}/bin/python"
  PATH="${PYENV_TEST_DIR}/libexec:$PATH" PYENV_VERSION="system" run pyenv-prefix
  assert_success "$PYENV_TEST_DIR"
}

#Arch has Python at sbin as well as bin
@test "prefix for system in sbin" {
  mkdir -p "${PYENV_TEST_DIR}/sbin"
  touch "${PYENV_TEST_DIR}/sbin/python"
  chmod +x "${PYENV_TEST_DIR}/sbin/python"
  PATH="${PYENV_TEST_DIR}/sbin:$PATH" PYENV_VERSION="system" run pyenv-prefix
  assert_success "$PYENV_TEST_DIR"
}

@test "prefix for system in /" {
  mkdir -p "${PYENV_TEST_DIR}/libexec"
  cat >"${PYENV_TEST_DIR}/libexec/pyenv-which" <<OUT
#!/bin/sh
echo /bin/python
OUT
  chmod +x "${PYENV_TEST_DIR}/libexec/pyenv-which"
  PATH="${PYENV_TEST_DIR}/libexec:$PATH" PYENV_VERSION="system" run pyenv-prefix
  assert_success "/"
  rm -f "${PYENV_TEST_DIR}/libexec/pyenv-which"
}

@test "prefix for invalid system" {
  PATH="$(path_without python python2 python3)" run pyenv-prefix system
  assert_failure "pyenv: system version not found in PATH"
}
