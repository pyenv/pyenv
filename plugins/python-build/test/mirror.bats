#!/usr/bin/env bats

load test_helper

_setup() {
  export PYTHON_BUILD_SKIP_MIRROR=
  export PYTHON_BUILD_CACHE_PATH=
  export PYTHON_BUILD_MIRROR_URL=http://mirror.example.com
  export checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"
}

assert_package_success() {
  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]
}

assert_package_failure() {
  assert_failure
  refute [ -f "${INSTALL_ROOT}/bin/package" ]
}

@test "package URL without checksum bypasses mirror" {
  stub curl '** -o * ** http://example.com/* : "$FIXTURE_ROOT/fake_downloader" "$@"'

  install_fixture definitions/without-checksum

  assert_package_success

  unstub curl
}


@test "package URL with checksum but no shasum support bypasses mirror" {
  stub shasum false
  stub curl '** -o * ** http://example.com/* : "$FIXTURE_ROOT/fake_downloader" "$@"'

  install_fixture definitions/with-checksum

  assert_package_success

  unstub curl
  unstub shasum
}


@test "package URL with MD5 checksum but no md5 support bypasses mirror" {
  stub md5 false
  stub curl '** -o * ** http://example.com/* : "$FIXTURE_ROOT/fake_downloader" "$@"'

  install_fixture definitions/with-md5-checksum

  assert_package_success

  unstub curl
  unstub md5
}


@test "SKIP_MIRROR bypasses mirror" {
  export PYTHON_BUILD_SKIP_MIRROR=1

  stub shasum true "echo $checksum"
  stub curl '** -o * ** http://example.com/* : "$FIXTURE_ROOT/fake_downloader" "$@"'

  install_fixture definitions/with-checksum

  assert_package_success

  unstub curl
  unstub shasum
}


@test "package URL with checksum hits mirror" {
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub shasum true "echo $checksum"
  stub curl "-*I* $mirror_url : true" \
    "** -o * ** $mirror_url : "'"$FIXTURE_ROOT/fake_downloader" hash "$@"'

  install_fixture definitions/with-checksum

  assert_package_success

  unstub curl
  unstub shasum
}


@test "package is fetched from original URL if mirror is unreachable" {
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub shasum true "echo $checksum"
  stub curl "-*I* $mirror_url : false" \
    '** -o * ** http://example.com/* : "$FIXTURE_ROOT/fake_downloader" "$@"'

  install_fixture definitions/with-checksum

  assert_package_success

  unstub curl
  unstub shasum
}


@test "package is fetched from original URL if mirror download fails" {
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub shasum true "echo $checksum"
  stub curl "-*I* $mirror_url : true" \
    "** -o * ** $mirror_url : false" \
    '** -o * ** http://example.com/* : "$FIXTURE_ROOT/fake_downloader" "$@"'

  install_fixture definitions/with-checksum

  assert_package_success

  unstub curl
  unstub shasum
}


@test "package is fetched from original URL if mirror download checksum is invalid" {
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub shasum true "echo invalid" "echo $checksum"
  stub curl "-*I* $mirror_url : true" \
    "** -o * ** $mirror_url : "'"$FIXTURE_ROOT/fake_downloader" hash "$@"' \
    '** -o * ** http://example.com/* : "$FIXTURE_ROOT/fake_downloader" "$@"'

  install_fixture definitions/with-checksum

  assert_package_success

  unstub curl
  unstub shasum
}


@test "package is fetched from a traditional mirror of URL_BASE if MIRROR_URL_SKIP_CHECKSUM set" {
  export PYTHON_BUILD_MIRROR_URL_SKIP_CHECKSUM=1
  export PYTHON_BUILD_MIRROR_URL=https://custom.mirror.org
  export URL_BASE=example.com

  stub shasum true "echo $checksum"
  stub curl "-*I* : true" \
    '** -o * ** https://custom.mirror.org/packages/package-1.0.0.tar.gz : "$FIXTURE_ROOT/fake_downloader" "$@"'

  install_fixture definitions/with-checksum

  assert_package_success

  unstub curl
  unstub shasum
}


@test "default mirror has flat structure" {
  export PYTHON_BUILD_MIRROR_URL=

  stub shasum true "echo $checksum"
  stub curl "-*I* : true" \
    "** -o * ** https://?*/$checksum : "'"$FIXTURE_ROOT/fake_downloader" hash "$@"'

  install_fixture definitions/with-checksum

  assert_package_success

  unstub curl
  unstub shasum
}


@test "package URL from the official CPython site bypasses the default mirror" {
  export PYTHON_BUILD_MIRROR_URL=

  stub shasum true "echo $checksum"
  stub curl '** -o * ** https://www.python.org/ftp/python* : "$FIXTURE_ROOT/fake_downloader" "$@"'

  run_inline_definition <<DEF
install_package "package-1.0.0" "https://www.python.org/ftp/python/packages/package-1.0.0.tar.gz#$checksum" copy
DEF

  assert_package_success

  unstub curl
  unstub shasum
}


@test "package hits mirror and fails if mirror is unreachable and NO_FALLBACK set" {
  export PYTHON_BUILD_MIRROR_NO_FALLBACK=1
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub shasum true
  stub curl "-*I* $mirror_url : false"

  install_fixture definitions/with-checksum

  assert_package_failure
  assert_output_contains "failed to download package-1.0.0.tar.gz from the mirror, not falling back to http://example.com/"

  unstub curl
  unstub shasum
}


@test "package hits mirror and fails if mirror download fails and NO_FALLBACK set" {
  export PYTHON_BUILD_MIRROR_NO_FALLBACK=1
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub shasum true
  stub curl "-*I* $mirror_url : true" \
    "** -o * ** $mirror_url : false"

  install_fixture definitions/with-checksum

  assert_package_failure
  assert_output_contains "failed to download package-1.0.0.tar.gz from the mirror, not falling back to http://example.com/"

  unstub curl
  unstub shasum
}


@test "package hits mirror and fails if mirror download checksum is invalid and NO_FALLBACK set" {
  export PYTHON_BUILD_MIRROR_NO_FALLBACK=1
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub shasum true "echo invalid"
  stub curl "-*I* $mirror_url : true" \
    "** -o * ** $mirror_url : "'"$FIXTURE_ROOT/fake_downloader" hash "$@"'

  install_fixture definitions/with-checksum

  assert_package_failure
  assert_output_contains "failed to download package-1.0.0.tar.gz from the mirror, not falling back to http://example.com/"

  unstub curl
  unstub shasum
}


@test "package URL without checksum still bypasses a flat mirror if NO_FALLBACK set" {
  export PYTHON_BUILD_MIRROR_NO_FALLBACK=1

  stub curl "** -o * ** http://example.com/* : "'"$FIXTURE_ROOT/fake_downloader" "$@"'

  install_fixture definitions/without-checksum

  assert_package_success

  unstub curl
}


@test "no shasum support still bypasses a flat mirror if NO_FALLBACK set" {
  export PYTHON_BUILD_MIRROR_NO_FALLBACK=1

  stub shasum false
  stub curl "** -o * ** http://example.com/* : "'"$FIXTURE_ROOT/fake_downloader" "$@"'

  install_fixture definitions/with-checksum

  assert_package_success

  unstub curl
  unstub shasum
}


@test "package from a site other than URL_BASE bypasses the mirror with MIRROR_URL_SKIP_CHECKSUM and NO_FALLBACK set" {
  export PYTHON_BUILD_MIRROR_URL_SKIP_CHECKSUM=1
  export PYTHON_BUILD_MIRROR_NO_FALLBACK=1
  export PYTHON_BUILD_MIRROR_URL=https://custom.mirror.org
  export URL_BASE=other.example.org

  stub shasum true "echo $checksum"
  stub curl "-*I* http://example.com/* : true" \
    "** -o ** http://example.com/* : "'"$FIXTURE_ROOT/fake_downloader" "$@"'

  install_fixture definitions/with-checksum

  assert_package_success

  unstub curl
  unstub shasum
}


@test "NO_FALLBACK has no effect with default mirror URL" {
  export PYTHON_BUILD_MIRROR_URL=
  export PYTHON_BUILD_MIRROR_NO_FALLBACK=1

  stub shasum true "echo $checksum"
  stub curl "-*I* https://pyenv.github.io/pythons/* : false" \
    "** -o * ** https://www.python.org/* : "'"$FIXTURE_ROOT/fake_downloader" hash "$@"'

  run_inline_definition <<DEF
install_package "package-1.0.0" "https://www.python.org/packages/package-1.0.0.tar.gz#$checksum" copy
DEF

  assert_package_success
  assert_output_contains "PYTHON_BUILD_MIRROR_NO_FALLBACK has no effect"

  unstub curl
  unstub shasum
}
