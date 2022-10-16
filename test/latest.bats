#!/usr/bin/env bats

load test_helper

create_executable() {
  local name="$1"
  local bin="${PYENV_TEST_DIR}/bin"
  mkdir -p "$bin"
  sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "read from installed" {
  create_executable pyenv-versions <<!
#!$BASH
echo 4.5.6
!
  run pyenv-latest 4
  assert_success
  assert_output <<!
4.5.6
!
}

@test "read from known" {
  create_executable python-build <<!
#!$BASH
echo 4.5.6
!
  run pyenv-latest -k 4
  assert_success
  assert_output <<!
4.5.6
!
}

@test "sort CPython" {
  create_executable pyenv-versions <<!
#!$BASH
echo 2.7.18
echo 3.5.6
echo 3.10.8
echo 3.10.6
!
  run pyenv-latest 3
  assert_success
  assert_output <<!
3.10.8
!
}
