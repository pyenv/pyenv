#!/usr/bin/env bats

load test_helper

# Make the build deterministic: `pyenv-install' just creates the prefix, and
# the platform tools report a fixed Linux target so the real `save' and
# `generate-installer' behave the same on any test host.
stub_build_environment() {
  create_stub pyenv-install 'mkdir -p "${PYENV_ROOT}/versions/${1##*:}/bin"'
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'
  create_stub getconf 'echo "glibc 2.17"'
}

@test "completion lists the option and definitions provided by another plugin" {
  mkdir -p "${PYENV_ROOT}/plugins/example/share/python-build"
  touch "${PYENV_ROOT}/plugins/example/share/python-build/3.12.7-example"
  PATH="${BATS_TEST_DIRNAME}/../../python-build/bin:${PATH}"

  run pyenv-binary-package --complete
  assert_success
  assert_line "--archive-base-url"
  assert_line "3.12.7-example"
  refute_line "Available versions:"
}

@test "fails with no arguments" {
  create_stub pyenv-help "echo usage"
  run pyenv-binary-package
  assert_failure "usage"
}

@test "fails without an archive base url" {
  create_stub pyenv-help "echo usage"
  run pyenv-binary-package 3.12.7:3.12.7-test
  assert_failure "usage"
}

@test "fails when --archive-base-url has no value" {
  run pyenv-binary-package 3.12.7:3.12.7-test --archive-base-url
  assert_failure "pyenv-binary: --archive-base-url needs a value"
}

@test "rejects a second positional argument" {
  run pyenv-binary-package 3.12.7:3.12.7-test extra --archive-base-url http://x/b
  assert_failure "pyenv-binary: unexpected argument \`extra'"
}

@test "generates an entry name for a bare version" {
  stub_build_environment
  create_stub lsb_release 'case "$1" in -si) echo Debian;; -sr) echo 12;; esac'
  cd "${BATS_TEST_TMPDIR}"

  run pyenv-binary-package 3.12.7 --archive-base-url http://example.com/binaries
  assert_success
  assert [ -d "${PYENV_ROOT}/versions/3.12.7-debian-12-x86_64" ]
  assert [ -f "${BATS_TEST_TMPDIR}/3.12.7-debian-12-x86_64.tar.gz" ]
  assert [ -f "${BATS_TEST_TMPDIR}/3.12.7-debian-12-x86_64.meta" ]
  run grep '^ARCHIVE_URL=' "${BATS_TEST_TMPDIR}/3.12.7-debian-12-x86_64"
  assert_success "ARCHIVE_URL=http://example.com/binaries/3.12.7-debian-12-x86_64.tar.gz"
}

@test "rejects an entry name containing a slash" {
  run pyenv-binary-package "3.12.7:foo/bar" --archive-base-url http://x/b
  assert_failure "pyenv-binary: invalid entry name \`foo/bar'"
}

@test "rejects \`latest' as an entry name" {
  run pyenv-binary-package 3.12:latest --archive-base-url http://x/b
  assert_failure "pyenv-binary: \`latest' cannot be used as an entry name"
}

@test "refuses to package on macOS before compiling anything" {
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'
  run pyenv-binary-package 3.12.7:3.12.7-test --archive-base-url http://x/b
  assert_failure "pyenv-binary: macOS archives are not supported yet"
}

@test "writes the archive, metadata and definition under the entry name" {
  stub_build_environment
  cd "${BATS_TEST_TMPDIR}"

  run pyenv-binary-package 3.12.7:3.12.7-test \
    --archive-base-url http://example.com/binaries
  assert_success
  assert [ -d "${PYENV_ROOT}/versions/3.12.7-test" ]
  assert [ -f "${BATS_TEST_TMPDIR}/3.12.7-test.tar.gz" ]
  assert [ -f "${BATS_TEST_TMPDIR}/3.12.7-test.meta" ]
  run grep '^ARCHIVE_URL=' "${BATS_TEST_TMPDIR}/3.12.7-test"
  assert_success "ARCHIVE_URL=http://example.com/binaries/3.12.7-test.tar.gz"
}

@test "strips a trailing slash from the archive base url" {
  stub_build_environment
  cd "${BATS_TEST_TMPDIR}"

  run pyenv-binary-package 3.12.7:3.12.7-test \
    --archive-base-url http://example.com/binaries/
  assert_success
  run grep '^ARCHIVE_URL=' "${BATS_TEST_TMPDIR}/3.12.7-test"
  assert_success "ARCHIVE_URL=http://example.com/binaries/3.12.7-test.tar.gz"
}
