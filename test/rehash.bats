#!/usr/bin/env bats

export PATH="${BATS_TEST_DIRNAME}/../libexec:$PATH"

RBENV_TEST_ROOT="${BATS_TMPDIR}/rbenv"
export RBENV_ROOT="$RBENV_TEST_ROOT"

teardown() {
  rm -rf "$RBENV_TEST_ROOT"
}

@test "empty rehash" {
  run rbenv-rehash
  [ "$status" -eq 0 ]
  [ -d "${RBENV_TEST_ROOT}/shims" ]
  rmdir "${RBENV_TEST_ROOT}/shims"
}

@test "shims directory not writable" {
  mkdir -p "${RBENV_TEST_ROOT}/shims"
  chmod -w "${RBENV_TEST_ROOT}/shims"
  run rbenv-rehash
  [ "$status" -eq 1 ]
  [ "$output" = "rbenv: cannot rehash: ${RBENV_TEST_ROOT}/shims isn't writable" ]
}

@test "rehash in progress" {
  mkdir -p "${RBENV_TEST_ROOT}/shims"
  touch "${RBENV_TEST_ROOT}/shims/.rbenv-shim"
  run rbenv-rehash
  [ "$status" -eq 1 ]
  [ "$output" = "rbenv: cannot rehash: ${RBENV_TEST_ROOT}/shims/.rbenv-shim exists" ]
}
