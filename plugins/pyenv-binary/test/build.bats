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

@test "completion lists the option and the buildable versions" {
  create_stub python-build 'echo 3.12.7'
  run pyenv-binary-build --complete
  assert_success "--archive-url
3.12.7"
}

@test "fails with no arguments" {
  create_stub pyenv-help "echo usage"
  run pyenv-binary-build
  assert_failure "usage"
}

@test "fails without an archive url" {
  create_stub pyenv-help "echo usage"
  run pyenv-binary-build 3.12.7:3.12.7-test
  assert_failure "usage"
}

@test "fails when --archive-url has no value" {
  run pyenv-binary-build 3.12.7:3.12.7-test --archive-url
  assert_failure "pyenv-binary: --archive-url needs a value"
}

@test "rejects a second positional argument" {
  run pyenv-binary-build 3.12.7:3.12.7-test extra --archive-url http://x/b
  assert_failure "pyenv-binary: unexpected argument \`extra'"
}

@test "rejects a bare version without an entry name" {
  run pyenv-binary-build 3.12.7 --archive-url http://x/b
  assert_failure "pyenv-binary: expected <version>:<entry>, e.g. \`3.13.14:3.13.14-debian-12'"
}

@test "rejects an entry name containing a slash" {
  run pyenv-binary-build "3.12.7:foo/bar" --archive-url http://x/b
  assert_failure "pyenv-binary: invalid entry name \`foo/bar'"
}

@test "rejects \`latest' as an entry name" {
  run pyenv-binary-build 3.12:latest --archive-url http://x/b
  assert_failure "pyenv-binary: \`latest' cannot be used as an entry name"
}

@test "refuses to build on macOS before compiling anything" {
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'
  run pyenv-binary-build 3.12.7:3.12.7-test --archive-url http://x/b
  assert_failure "pyenv-binary: macOS archives are not supported yet"
}

@test "builds under the entry name and writes the archive and definition" {
  stub_build_environment
  cd "${BATS_TEST_TMPDIR}"

  run pyenv-binary-build 3.12.7:3.12.7-test --archive-url http://example.com/binaries
  assert_success
  assert [ -d "${PYENV_ROOT}/versions/3.12.7-test" ]
  assert [ -f "${BATS_TEST_TMPDIR}/3.12.7-test-linux-x86_64.tar.gz" ]
  assert [ -f "${BATS_TEST_TMPDIR}/3.12.7-test-linux-x86_64.meta" ]
  run grep '^ARCHIVE_URL=' "${BATS_TEST_TMPDIR}/3.12.7-test"
  assert_success "ARCHIVE_URL=http://example.com/binaries/3.12.7-test-linux-x86_64.tar.gz"
}

@test "strips a trailing slash from the archive url" {
  stub_build_environment
  cd "${BATS_TEST_TMPDIR}"

  run pyenv-binary-build 3.12.7:3.12.7-test --archive-url http://example.com/binaries/
  assert_success
  run grep '^ARCHIVE_URL=' "${BATS_TEST_TMPDIR}/3.12.7-test"
  assert_success "ARCHIVE_URL=http://example.com/binaries/3.12.7-test-linux-x86_64.tar.gz"
}
