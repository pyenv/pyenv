#!/usr/bin/env bats

load test_helper
load binary_helper

_setup() {
  PATH="${BATS_TEST_TMPDIR}/stubs:${BATS_TEST_DIRNAME}/../../python-build/bin:$PATH"
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
  set_platform Linux x86_64 'debian 12'

  run pyenv-binary-package-name 3.13.14
  assert_success "3.13.14-debian-12-x86_64"
}

@test "generates a package name for the macOS major version" {
  set_platform Darwin arm64 'macos 15.5'

  run pyenv-binary-package-name 3.13.14
  assert_success "3.13.14-macos-15-arm64"
}

@test "fails without a distribution release" {
  set_platform Linux x86_64 'arch '

  run pyenv-binary-package-name 3.13.14
  assert_failure "pyenv-binary: could not determine the package platform"
}

@test "does not pass the version to the Python-Build library loader" {
  set_platform Linux x86_64 'debian 12'

  run pyenv-binary-package-name --lib
  assert_success "--lib-debian-12-x86_64"
}

@test "resolves a version prefix when generating a package name" {
  create_stub pyenv-latest '[ "$*" = "-f -k 3" ] && echo 3.14.7'
  set_platform FreeBSD amd64 'freebsd 14.2'

  run pyenv-binary-package-name 3
  assert_success "3.14.7-freebsd-14.2-amd64"
}

@test "rejects an invalid version name" {
  run pyenv-binary-package-name ../3.13.14
  assert_failure "pyenv-binary: invalid version name \`../3.13.14'"
}
