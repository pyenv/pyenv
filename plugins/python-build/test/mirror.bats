#!/usr/bin/env bats

load test_helper
export PYTHON_BUILD_SKIP_MIRROR=
export PYTHON_BUILD_CACHE_PATH=
export PYTHON_BUILD_MIRROR_URL=http://mirror.example.com


@test "package URL without checksum bypasses mirror" {
  stub md5 true
  stub curl "-C - -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${6##*/} \$4"

  install_fixture definitions/without-checksum
  echo "$output" >&2
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}


@test "package URL with checksum but no MD5 support bypasses mirror" {
  stub md5 false
  stub curl "-C - -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${6##*/} \$4"

  install_fixture definitions/with-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}


@test "package URL with checksum hits mirror first" {
  local checksum="83e6d7725e20166024a1eb74cde80677"
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub md5 true "echo $checksum"
  stub curl "-*I* $mirror_url : true" \
    "-C - -o * -*S* $mirror_url : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$4"

  install_fixture definitions/with-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}


@test "package is fetched from original URL if mirror download fails" {
  local checksum="83e6d7725e20166024a1eb74cde80677"
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub md5 true "echo $checksum"
  stub curl "-*I* $mirror_url : false" \
    "-C - -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${6##*/} \$4"

  install_fixture definitions/with-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}


@test "package is fetched from original URL if mirror download checksum is invalid" {
  local checksum="83e6d7725e20166024a1eb74cde80677"
  local mirror_url="${PYTHON_BUILD_MIRROR_URL}/$checksum"

  stub md5 true "echo invalid" "echo $checksum"
  stub curl "-*I* $mirror_url : true" \
    "-C - -o * -*S* $mirror_url : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$4" \
    "-C - -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${6##*/} \$4"

  install_fixture definitions/with-checksum
  echo "$output" >&2
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}


@test "default mirror URL" {
  export PYTHON_BUILD_MIRROR_URL=
  local checksum="83e6d7725e20166024a1eb74cde80677"

  stub md5 true "echo $checksum"
  stub curl "-*I* : true" \
    "-C - -o * -*S* http://?*/$checksum : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$4" \

  install_fixture definitions/with-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}
