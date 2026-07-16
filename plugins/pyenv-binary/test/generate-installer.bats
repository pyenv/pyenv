#!/usr/bin/env bats

load test_helper

create_meta() {
  local os="${1-Linux}"
  local arch="${2-x86_64}"
  local libc="${3-glibc 2.17}"
  local archive="${BATS_TEST_TMPDIR}/3.12.7.tar.gz"
  local meta="${BATS_TEST_TMPDIR}/sample.meta"

  rm -rf "${BATS_TEST_TMPDIR}/archive"
  mkdir -p "${BATS_TEST_TMPDIR}/archive/3.12.7/bin"
  printf '#!/bin/sh\n' > "${BATS_TEST_TMPDIR}/archive/3.12.7/bin/python"
  chmod +x "${BATS_TEST_TMPDIR}/archive/3.12.7/bin/python"
  tar -C "${BATS_TEST_TMPDIR}/archive" -czf "$archive" 3.12.7

  {
    echo "version=3.12.7"
    echo "os=${os}"
    echo "arch=${arch}"
    [ -z "$libc" ] || echo "libc=${libc}"
    echo "archive=${archive##*/}"
  } > "$meta"
  echo "$meta"
}

@test "completion lists the options" {
  run pyenv-binary-generate-installer --complete
  assert_success "--archive-url
-o"
}

@test "fails with no arguments" {
  create_stub pyenv-help "echo usage"
  run pyenv-binary-generate-installer
  assert_failure "usage"
}

@test "fails without an archive url" {
  create_stub pyenv-help "echo usage"
  run pyenv-binary-generate-installer "$(create_meta)"
  assert_failure "usage"
}

@test "fails when --archive-url has no value" {
  run pyenv-binary-generate-installer "$(create_meta)" --archive-url
  assert_failure "pyenv-binary: --archive-url needs a value"
}

@test "rejects a second positional argument" {
  run pyenv-binary-generate-installer "$(create_meta)" extra --archive-url http://x/a.tar.gz
  assert_failure "pyenv-binary: unexpected argument \`extra'"
}

@test "fails for a metadata file that cannot be read" {
  run pyenv-binary-generate-installer /no/such.meta --archive-url http://x/a.tar.gz
  assert_failure
}

@test "refuses macOS metadata" {
  run pyenv-binary-generate-installer "$(create_meta Darwin arm64 '')" \
    --archive-url http://x/a.tar.gz
  assert_failure "pyenv-binary: macOS archives are not supported yet"
}

@test "fails when required metadata is missing" {
  local field meta
  for field in version os arch archive; do
    meta="$(create_meta)"
    #cannot use -i: GNU sed requires -i[suf], BSD sed required -i <suf>
    sed "/^${field}=/d" "$meta" > "${meta}.tmp"; mv "${meta}"{.tmp,}

    run pyenv-binary-generate-installer "$meta" --archive-url http://x/a.tar.gz
    assert_failure "pyenv-binary: metadata is missing \`${field}'"
  done
}

@test "fails when Linux metadata is missing libc" {
  run pyenv-binary-generate-installer "$(create_meta Linux x86_64 '')" \
    --archive-url http://x/a.tar.gz
  assert_failure "pyenv-binary: metadata is missing \`libc'"
}

@test "refuses a host whose glibc is older than the archive" {
  local out="${BATS_TEST_TMPDIR}/definition"
  pyenv-binary-generate-installer "$(create_meta Linux x86_64 'glibc 99.0')" \
    --archive-url http://example.com/a.tar.gz -o "$out"
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'
  create_stub getconf 'echo "glibc 2.31"'

  run bash "$out"
  assert_failure "pyenv-binary: archive needs glibc 99.0 or newer, but this system has 2.31"
}

@test "fails when the archive is not beside the metadata" {
  local meta="$(create_meta)"
  rm "${BATS_TEST_TMPDIR}/3.12.7.tar.gz"

  run pyenv-binary-generate-installer "$meta" --archive-url http://x/a.tar.gz
  assert_failure "pyenv-binary: cannot read the archive \`${BATS_TEST_TMPDIR}/3.12.7.tar.gz' to checksum it"
}

@test "the generated definition is installable with python-build" {
  ldconfig -p &>/dev/null || skip "ldconfig with -p is not present"
  local archive="${BATS_TEST_TMPDIR}/3.12.7.tar.gz"
  local cache="${BATS_TEST_TMPDIR}/cache"
  local definition="${BATS_TEST_TMPDIR}/definition"
  local prefix="${BATS_TEST_TMPDIR}/install"
  pyenv-binary-generate-installer "$(create_meta)" \
    --archive-url http://example.com/3.12.7.tar.gz -o "$definition"
  mkdir -p "$cache"
  cp "$archive" "${cache}/Python-3.12.7-binary.tar.gz"
  create_stub pyenv 'echo "pyenv $*"'
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'

  PYTHON_BUILD_CACHE_PATH="$cache" run \
    "${BATS_TEST_DIRNAME}/../../python-build/bin/python-build" "$definition" "$prefix"
  assert_success
  assert_line "pyenv binary relocate ${prefix}"
  assert_line "Installed Python-3.12.7-binary to ${prefix}"
  assert [ -x "${prefix}/bin/python" ]
}
