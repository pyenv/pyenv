#!/usr/bin/env bats

load test_helper
export PYTHON_BUILD_SKIP_MIRROR=
export PYTHON_BUILD_CACHE_PATH=
export PYTHON_BUILD_MIRROR_URL=http://mirror.example.com


@test "package URL without checksum bypasses mirror" {
  stub shasum true
  stub curl "-q -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$3"

  install_fixture definitions/without-checksum
  echo "$output" >&2

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}


@test "package URL with checksum but no shasum support bypasses mirror" {
  stub shasum false
  stub curl "-q -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$3"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}


@test "package URL with checksum hits mirror first" {
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub shasum true "echo $checksum"
  stub curl "-*I* $mirror_url : true" \
    "-q -o * -*S* $mirror_url : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$3"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}


@test "package is fetched from original URL if mirror download fails" {
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub shasum true "echo $checksum"
  stub curl "-*I* $mirror_url : false" \
    "-q -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$3"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}

@test "package is fetched from mirror when checksum is invalid if SKIP_CHECKSUM set" {
  export PYTHON_BUILD_MIRROR_URL_SKIP_CHECKSUM=1
  export PYTHON_BUILD_MIRROR_URL=https://custom.mirror.org
  export URL_BASE=example.com
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"

  stub shasum false
  stub curl "-*I* : true" \
    "-q -o * -*S* https://custom.mirror.org/* : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$3" \

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
  unset PYTHON_BUILD_MIRROR_URL_SKIP_CHECKSUM
}


@test "package is fetched from original URL if mirror download checksum is invalid" {
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub shasum true "echo invalid" "echo $checksum"
  stub curl "-*I* $mirror_url : true" \
    "-q -o * -*S* $mirror_url : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$3" \
    "-q -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$3"

  install_fixture definitions/with-checksum
  echo "$output" >&2

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}


@test "default mirror URL" {
  export PYTHON_BUILD_MIRROR_URL=
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"

  stub shasum true "echo $checksum"
  stub curl "-*I* : true" \
    "-q -o * -*S* https://?*/$checksum : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$3" \

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}


@test "package URL with ruby-lang CDN with default mirror URL will bypasses mirror" {
  export PYTHON_BUILD_MIRROR_URL=
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"

  stub shasum true "echo $checksum"
  stub curl "-q -o * -*S* https://www.python.org/* : cp $FIXTURE_ROOT/\${5##*/} \$3"

  run_inline_definition <<DEF
install_package "package-1.0.0" "https://www.python.org/packages/package-1.0.0.tar.gz#ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5" copy
DEF

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub shasum
}
