#!/usr/bin/env bats

load test_helper

# Make the build deterministic: `pyenv-install' just creates the prefix, and
# the platform tools report a fixed Linux target so the real `save' and
# `generate-installer' behave the same on any test host.
stub_build_environment() {
  create_stub pyenv-install 'echo "${0##*/} $*"; mkdir -p "${PYENV_ROOT}/versions/${1##*:}/bin"'
  create_stub pyenv-latest 'while (($#)); do case "$1" in -f|-k);; *)break;; esac; shift; done; echo "$*"'
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'
  create_stub getconf 'echo "glibc 2.17"'
  create_stub readelf true
}

@test "-v|--verbose runs pyenv install verbosely" {
  stub_build_environment
  create_stub pyenv-binary-save true
  create_stub pyenv-binary-generate-installer true

  for opt in "" -v --verbose; do 
    run pyenv-binary-package $opt 3.12.7:3.12.7-test \
      --archive-base-url http://example.com/binaries
    assert_success "pyenv-install ${opt:+--verbose }3.12.7:3.12.7-test"
  done
}

@test "completions" {
  create_stub pyenv-install 'echo "${0##*/} $*"'

  run pyenv-binary-package --complete
  assert_success <<!
--archive-base-url
--verbose
pyenv-install --list --bare
!
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

@test "writes the archive, metadata and definition under the entry name (integration)" {
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

@test "correctly joins archive base url with a trailing slash" {
  stub_build_environment
  create_stub pyenv-binary-save true
  create_stub pyenv-binary-generate-installer <<'!'
echo -n "${0##*/} "
while (($#)); do
  case $1 in
    --archive-url)
      echo "$1 ${2:?}"
      break
      ;;
  esac
  shift
done
!

  run pyenv-binary-package 3.12.7:3.12.7-test \
    --archive-base-url http://example.com/binaries/
  assert_success
  assert_line "pyenv-binary-generate-installer --archive-url http://example.com/binaries/3.12.7-test.tar.gz"
}
