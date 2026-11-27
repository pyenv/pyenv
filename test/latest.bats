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

@test "falls back to a 't' argument unchanged" {
  create_stub pyenv-versions <<!
echo 3.14.2
!
  run pyenv-latest -f 3.14.2t
  assert_success
  assert_output <<!
3.14.2t
!
}

@test "provides completions" {
  run pyenv-latest --complete
  assert_success
  assert_output <<!
--known
--prerelease
!
}

@test "--prerelease resolves installed prereleases and excludes -dev, -src, -latest" {
  create_prereleases_stub
  run pyenv-latest --prerelease 3.8
  assert_success
  assert_output <<!
3.8.5rc2
!
}

@test "--prerelease resolves known prereleases regardless of flag order" {
  create_stub pyenv-install <<!
echo 3.16-dev
echo 3.16.0a2
echo 3.16.0a2t
echo 3.16t-dev
!
  run pyenv-latest -k --prerelease 3.16
  assert_success "3.16.0a2"

  run pyenv-latest --prerelease -k 3.16
  assert_success "3.16.0a2"
}

@test "--prerelease prefers final over prerelease and orders alpha < beta < rc numerically" {
  create_stub pyenv-install <<!
echo 3.12.0a2
echo 3.12.0a10
echo 3.12.0b1
echo 3.12.0b2
echo 3.12.0rc1
echo 3.12.0rc2
!
  run pyenv-latest -k --prerelease 3.12
  assert_success "3.12.0rc2"

  create_stub pyenv-install <<!
echo 3.12.0a2
echo 3.12.0a10
!
  run pyenv-latest -k --prerelease 3.12
  assert_success "3.12.0a10"

  create_stub pyenv-install <<!
echo 3.12.0a10
echo 3.12.0b1
!
  run pyenv-latest -k --prerelease 3.12
  assert_success "3.12.0b1"

  create_stub pyenv-install <<!
echo 3.12.0
echo 3.12.0rc2
echo 3.12.0b3
echo 3.12.0a5
!
  run pyenv-latest -k --prerelease 3.12
  assert_success "3.12.0"
}

@test "--prerelease resolves newer minor prerelease over older stable" {
  create_stub pyenv-install <<!
echo 3.15.2
echo 3.16-dev
echo 3.16.0a2
!
  run pyenv-latest -k --prerelease 3
  assert_success "3.16.0a2"

  run pyenv-latest -k 3
  assert_success "3.15.2"
}

@test "--prerelease does not fall back to -dev when no prereleases exist" {
  create_stub pyenv-install <<!
echo 3.17-dev
echo 3.17t-dev
!
  run pyenv-latest -k --prerelease 3.17
  assert_failure "pyenv: no known versions match the prefix \`3.17'"
}

@test "--prerelease respects 't' suffix for free-threaded prereleases" {
  create_prereleases_stub
  run pyenv-latest --prerelease 3.8t
  assert_success "3.8.6b3t"

  create_stub pyenv-versions <<!
echo 3.13.0a2t
echo 3.13.0a10t
echo 3.13.0b1t
echo 3.13.0rc1t
echo 3.13.0t
!
  run pyenv-latest --prerelease 3.13t
  assert_success "3.13.0t"

  create_stub pyenv-versions <<!
echo 3.13.0a2t
echo 3.13.0a10t
!
  run pyenv-latest --prerelease 3.13t
  assert_success "3.13.0a10t"
}

@test "--prerelease handles hyphenated prereleases for other flavors" {
  create_stub pyenv-install <<!
echo jython-2.5.3
echo jython-2.5.4-rc1
echo jython-2.5-dev
echo pypy3.3-5.2-alpha1
echo pypy3.3-5.2-alpha1-src
echo pypy3.3-5.5-alpha
echo pypy3.5-5.7-beta
echo pypy3.5-5.7.1-beta
!
  run pyenv-latest -k jython-2.5
  assert_success "jython-2.5.3"

  run pyenv-latest -k --prerelease jython-2.5
  assert_success "jython-2.5.4-rc1"

  run pyenv-latest -k pypy3.3
  assert_failure "pyenv: no known versions match the prefix \`pypy3.3'"

  run pyenv-latest -k --prerelease pypy3.3
  assert_success "pypy3.3-5.5-alpha"

  run pyenv-latest -k --prerelease pypy3.5
  assert_success "pypy3.5-5.7.1-beta"
}

@test "--prerelease falls back unchanged with -b and -f" {
  create_stub pyenv-install <<!
echo 3.17-dev
!
  run pyenv-latest -b -k --prerelease 3.17
  assert_failure "3.17"

  run pyenv-latest -f -k --prerelease 3.17
  assert_success "3.17"
}
