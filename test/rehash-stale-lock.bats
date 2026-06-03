#!/usr/bin/env bats

load test_helper

setup() {
  export PYENV_ROOT="${BATS_TMPDIR}/pyenv-test"
  mkdir -p "${PYENV_ROOT}/shims"
  PROTOTYPE="${PYENV_ROOT}/shims/.pyenv-shim"
}

teardown() {
  rm -rf "${PYENV_ROOT}"
}

@test "rehash removes stale lock (>2 min) and succeeds within 5 s" {
  touch -d "3 minutes ago" "$PROTOTYPE"
  run timeout 5 pyenv-rehash
  assert_success
}

@test "rehash does not hang the full timeout on a stale lock" {
  touch -d "3 minutes ago" "$PROTOTYPE"
  start=$SECONDS
  run timeout 10 pyenv-rehash
  elapsed=$(( SECONDS - start ))
  [ "$elapsed" -lt 10 ]
}

@test "rehash exits immediately when shims dir is unwritable" {
  chmod -w "${PYENV_ROOT}/shims"
  run timeout 5 pyenv-rehash
  assert_failure
  assert_output --partial "isn't writable"
  [ "$status" -ne 124 ]  # 124 = timed out
  chmod +w "${PYENV_ROOT}/shims"
}
