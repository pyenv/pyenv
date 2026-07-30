#!/usr/bin/env bats

load test_helper

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
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'
  create_stub lsb_release 'case "$1" in -si) echo Debian;; -sr) echo 12;; esac'

  run pyenv-binary-package-name 3.13.14
  assert_success "3.13.14-debian-12-x86_64"
}

@test "generates a package name for macOS" {
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'
  create_stub sw_vers 'echo 15.5'

  run pyenv-binary-package-name 3.13.14
  assert_success "3.13.14-macos-15.5-arm64"
}

@test "generates a package name for FreeBSD" {
  create_stub uname \
    'case "$1" in -s) echo FreeBSD;; -m) echo amd64;; -r) echo 14.2-RELEASE-p3;; esac'

  run pyenv-binary-package-name 3.13.14
  assert_success "3.13.14-freebsd-14.2-release-p3-amd64"
}

@test "rejects an invalid version name" {
  run pyenv-binary-package-name ../3.13.14
  assert_failure "pyenv-binary: invalid version name \`../3.13.14'"
}
