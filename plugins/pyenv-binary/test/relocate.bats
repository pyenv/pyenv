#!/usr/bin/env bats

load test_helper

_setup() {
  create_stub pyenv-help "echo usage"
}

stub_patchelf() {
  create_path_executable patchelf <<STUB
if [ "\$1" = "--print-rpath" ]; then
  exit 0
fi
echo "\$*" >> "${BATS_TEST_TMPDIR}/patchelf.log"
STUB
}

create_interpreter() {
  mkdir -p "${BATS_TEST_TMPDIR}/prefix/bin"
  printf '#!/bin/sh\n' > "${BATS_TEST_TMPDIR}/prefix/bin/python2.7"
  chmod +x "${BATS_TEST_TMPDIR}/prefix/bin/python2.7"
}

@test "completion produces nothing" {
  run pyenv-binary-relocate --complete
  assert_success ""
}

@test "fails without a prefix" {
  run pyenv-binary-relocate
  assert_failure "usage"
}

@test "fails when patchelf is not available" {
  PATH="$(path_without patchelf)" run pyenv-binary-relocate "${BATS_TEST_TMPDIR}/prefix"
  assert_failure "pyenv-binary: need patchelf to relocate the binary"
}

@test "fails when the prefix has no interpreter" {
  create_path_executable patchelf "exit 0"
  mkdir -p "${BATS_TEST_TMPDIR}/prefix"

  run pyenv-binary-relocate "${BATS_TEST_TMPDIR}/prefix"
  assert_failure "pyenv-binary: found no interpreter to relocate under \`${BATS_TEST_TMPDIR}/prefix/bin'"
}

@test "relocates an executable interpreter" {
  stub_patchelf
  create_interpreter

  run pyenv-binary-relocate "${BATS_TEST_TMPDIR}/prefix"
  assert_success
  run cat "${BATS_TEST_TMPDIR}/patchelf.log"
  assert_output "--set-rpath ${BATS_TEST_TMPDIR}/prefix/lib ${BATS_TEST_TMPDIR}/prefix/bin/python2.7"
}

@test "relocates the extension modules but not what a wheel installed" {
  local lib="${BATS_TEST_TMPDIR}/prefix/lib/python3.12"
  stub_patchelf
  create_interpreter
  mkdir -p "${lib}/lib-dynload" "${lib}/site-packages/numpy"
  touch "${lib}/lib-dynload/_ssl.cpython-312-x86_64-linux-gnu.so"
  # A wheel points its extensions at the libraries it bundles alongside them, so
  # its rpath is its own business and must survive relocation.
  touch "${lib}/site-packages/numpy/_multiarray.so"

  run pyenv-binary-relocate "${BATS_TEST_TMPDIR}/prefix"
  assert_success
  run cat "${BATS_TEST_TMPDIR}/patchelf.log"
  assert_line "--set-rpath ${BATS_TEST_TMPDIR}/prefix/lib ${lib}/lib-dynload/_ssl.cpython-312-x86_64-linux-gnu.so"
  refute_line "--set-rpath ${BATS_TEST_TMPDIR}/prefix/lib ${lib}/site-packages/numpy/_multiarray.so"
}
