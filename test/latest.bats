#!/usr/bin/env bats

load test_helper

@test "read from installed" {
  create_stub pyenv-versions <<!
echo 4.5.6
!
  run pyenv-latest 4
  assert_success
  assert_output <<!
4.5.6
!
}

@test "read from known" {
  create_stub pyenv-install <<!
echo 4.5.6
!
  run pyenv-latest -k 4
  assert_success
  assert_output <<!
4.5.6
!
}

@test "known versions include plugin definitions" {
  PATH="${_PYENV_INSTALL_PREFIX}/plugins/python-build/bin:$PATH"
  local definitions="$PYENV_ROOT/plugins/custom/share/python-build"
  mkdir -p "$definitions"
  touch "$definitions/custom-1.0" "$definitions/custom-2.0"

  run pyenv-latest -k custom
  assert_success "custom-2.0"
}

@test "installed version not found" {
  create_stub pyenv-versions <<!
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
  create_stub pyenv-install <<!
echo 3.5.6
echo 3.10.8
!
  run pyenv-latest -k 3.8
  assert_failure
  assert_output <<!
pyenv: no known versions match the prefix \`3.8'
!
}

@test "a failed known-version listing is not bypassed by --force" {
  create_stub pyenv-install 'echo "listing failed" >&2; exit 1'

  run pyenv-latest -f -k 3.14
  assert_failure "listing failed"
}

@test "complete name resolves to itself" {
  create_stub pyenv-versions <<!
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
  create_stub pyenv-versions <<!
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

@test "sort versions of a flavor whose name has a version" {
  create_stub pyenv-install <<!
echo pypy2.7-5.10.0
echo pypy2.7-7.3.23
echo pypy2.7-8.0.1
echo pypy2.7-8.0.0
echo pypy3.10-7.3.12
!
  run pyenv-latest -k pypy2.7
  assert_success
  assert_output <<!
pypy2.7-8.0.1
!
}

create_prereleases_stub() {
  create_stub pyenv-versions <<!
[[ " \$* " == *" --skip-envs "* ]] || {
  echo "unexpected command line: \$@" >&2;
  exit 1
}
echo 3.8.5-dev
echo 3.8.5-src
echo 3.8.5-latest
echo 3.8.5a2
echo 3.8.5b3
echo 3.8.5rc2
echo 3.8.1t
echo 3.8.6b3t
echo 3.8.5rc2t
echo 3.8.1
!
}

@test "ignores rolling releases, branch tips, alternative srcs, prereleases, virtualenvs, including 't' ones (prefix without 't')" {
  create_prereleases_stub
  run pyenv-latest 3.8
  assert_success
  assert_output <<!
3.8.1
!
}

@test "ignores rolling releases, branch tips, alternative srcs, prereleases, virtualenvs, including 't' ones (prefix with 't')" {
  create_prereleases_stub
  run pyenv-latest 3.8t
  assert_success
  assert_output <<!
3.8.1t
!
}

@test "resolves to a 't' version if prefix has 't'" {
  create_stub pyenv-versions <<!
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
  create_stub pyenv-versions
  run pyenv-latest -b nonexistent
  assert_failure
  assert_output <<!
nonexistent
!
}

@test "falls back to argument and succeeds with -f" {
  create_stub pyenv-versions
  run pyenv-latest -f nonexistent
  assert_success
  assert_output <<!
nonexistent
!
}
