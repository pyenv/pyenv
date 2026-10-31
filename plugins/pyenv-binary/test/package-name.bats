#!/usr/bin/env bats

load test_helper
load binary_helper

_setup() {
  create_stub pyenv-latest '[ "$1" = "-f" ] && [ "$2" = "-k" ] && shift 2 && echo "$*"'
}

@test "completion lists installable versions" {
  create_stub pyenv-install \
    '[ "$*" = "--list --bare" ] && echo 3.13.14'

  run pyenv-binary-package-name --complete
  assert_success "3.13.14"
}

@test "fails without a version" {
  create_stub pyenv-help 'echo usage'

  run pyenv-binary-package-name
  assert_failure "usage"
}

@test "rejects a second argument" {
  create_stub pyenv-help 'echo usage'

  run pyenv-binary-package-name 3.13.14 extra
  assert_failure "usage"
}

@test "generates a package name for Linux" {
  use_records
  set_platform Linux x86_64 'Debian 12'

  run pyenv-binary-package-name 3.13.14
  assert_success "3.13.14-debian-12-x86_64"
}

@test "fails to name a Linux package without a distribution release" {
  use_records
  set_platform Linux x86_64 'arch '

  run pyenv-binary-package-name 3.13.14
  assert_failure "pyenv-binary: could not determine the package platform"
}

@test "generates a package name for macOS" {
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'
  create_stub sw_vers 'echo 15.5'

  run pyenv-binary-package-name 3.13.14
  assert_success "3.13.14-macos-15-arm64"
}

@test "fails when the platform release cannot be determined" {
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'
  create_stub sw_vers 'echo'

  run pyenv-binary-package-name 3.13.14
  assert_failure "pyenv-binary: could not determine the package platform"
}

@test "resolves a version prefix when generating a package name" {
  create_stub pyenv-latest '[ "$*" = "-f -k 3" ] && echo 3.14.7'
  create_stub uname \
    'case "$1" in -s) echo FreeBSD;; -m) echo amd64;; -r) echo 14.2-RELEASE-p3;; esac'

  run pyenv-binary-package-name 3
  assert_success "3.14.7-freebsd-14.2-release-p3-amd64"
}

@test "rejects an invalid version name" {
  run pyenv-binary-package-name ../3.13.14
  assert_failure "pyenv-binary: invalid version name \`../3.13.14'"
}

@test "rejects an invalid resolved version name" {
  create_stub pyenv-latest 'echo ../3.14.7'

  run pyenv-binary-package-name 3.14
  assert_failure "pyenv-binary: invalid version name \`../3.14.7'"
}
