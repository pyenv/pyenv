#!/usr/bin/env bats

load test_helper
export PYTHON_BUILD_SKIP_MIRROR=
export PYTHON_BUILD_CACHE_PATH=
export PYTHON_BUILD_MIRROR_URL=http://mirror.example.com
export PYTHON_BUILD_ARIA2_OPTS=


@test "package URL without checksum bypasses mirror" {
  stub shasum true
  stub aria2c "-o * http://example.com/* : cp $FIXTURE_ROOT/\${3##*/} \$2"

  install_fixture definitions/without-checksum
  echo "$output" >&2

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub aria2c
  unstub shasum
}


@test "package URL with checksum but no shasum support bypasses mirror" {
  stub shasum false
  stub aria2c "-o * http://example.com/* : cp $FIXTURE_ROOT/\${3##*/} \$2"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub aria2c
  unstub shasum
}


@test "package URL with checksum hits mirror first" {
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub shasum true "echo $checksum"
  stub aria2c "--dry-run $mirror_url : true" \
    "-o * $mirror_url : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$2"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub aria2c
  unstub shasum
}


@test "package is fetched from original URL if mirror download fails" {
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub shasum true "echo $checksum"
  stub aria2c "--dry-run $mirror_url : false" \
    "-o * http://example.com/* : cp $FIXTURE_ROOT/\${3##*/} \$2"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub aria2c
  unstub shasum
}


@test "package is fetched from original URL if mirror download checksum is invalid" {
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub shasum true "echo invalid" "echo $checksum"
  stub aria2c "--dry-run $mirror_url : true" \
    "-o * $mirror_url : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$2" \
    "-o * http://example.com/* : cp $FIXTURE_ROOT/\${3##*/} \$2"

  install_fixture definitions/with-checksum
  echo "$output" >&2

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub aria2c
  unstub shasum
}


@test "default mirror URL" {
  export PYTHON_BUILD_MIRROR_URL=
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"

  stub shasum true "echo $checksum"
  stub aria2c "--dry-run : true" \
    "-o * https://?*/$checksum : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$2" \

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub aria2c
  unstub shasum
}


@test "package URL with ruby-lang CDN with default mirror URL will bypasses mirror" {
  export PYTHON_BUILD_MIRROR_URL=
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"

  stub shasum true "echo $checksum"
  stub aria2c "-o * https://www.python.org/* : cp $FIXTURE_ROOT/\${3##*/} \$2"

  run_inline_definition <<DEF
install_package "package-1.0.0" "https://www.python.org/packages/package-1.0.0.tar.gz#ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5" copy
DEF

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub aria2c
  unstub shasum
}
