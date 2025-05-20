#!/usr/bin/env bats

load test_helper

setup() {
  export PATH="${PYENV_TEST_DIR}/bin:$PATH"
}

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

@test "installed version not found" {
  create_executable pyenv-versions <<!
#!$BASH
echo 3.5.6
echo 3.10.8
!
  run pyenv-latest 3.8
  assert_failure
  assert_output <<!
pyenv: no installed versions match the prefix \`3.8'
!
}

@test "known version not found" {
  create_executable python-build <<!
#!$BASH
echo 3.5.6
echo 3.10.8
!
  run pyenv-latest -k 3.8
  assert_failure
  assert_output <<!
pyenv: no known versions match the prefix \`3.8'
!
}

@test "complete name resolves to itself" {
  create_executable pyenv-versions <<!
#!$BASH
echo foo
echo foo.bar
!

run pyenv-latest foo
assert_success
assert_output <<!
foo
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

@test "ignores rolling releases, branch tips, alternative srcs, prereleases, virtualenvs; 't' versions if prefix without 't'" {
  create_executable pyenv-versions <<!
#!$BASH
echo 3.8.5-dev
echo 3.8.5-src
echo 3.8.5-latest
echo 3.8.5a2
echo 3.8.5b3
echo 3.8.5rc2
echo 3.8.5t
echo 3.8.5b3t
echo 3.8.5rc2t
echo 3.8.1
echo 3.8.1/envs/foo
!
  run pyenv-latest 3.8
  assert_success
  assert_output <<!
3.8.1
!
}

@test "resolves to a 't' version if prefix has 't'" {
  create_executable pyenv-versions <<!
#!$BASH
echo 3.13.2t
echo 3.13.5
echo 3.13.5t
echo 3.14.6
!
  run pyenv-latest 3t
  assert_success
  assert_output <<!
3.13.5t
!
}

@test "falls back to argument with -b" {
  create_executable pyenv-versions <<!
#!$BASH
!
  run pyenv-latest -b nonexistent
  assert_failure
  assert_output <<!
nonexistent
!
}

@test "falls back to argument and succeeds with -f" {
  create_executable pyenv-versions <<!
#!$BASH
!
  run pyenv-latest -f nonexistent
  assert_success
  assert_output <<!
nonexistent
!
}
