#!/usr/bin/env bats

load test_helper
export PYTHON_BUILD_SKIP_MIRROR=1
export PYTHON_BUILD_CACHE_PATH=


@test "package URL without checksum" {
  stub md5 true
  stub curl "-C - -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${6##*/} \$4"

  install_fixture definitions/without-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}


@test "package URL with valid checksum" {
  stub md5 true "echo 83e6d7725e20166024a1eb74cde80677"
  stub curl "-C - -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${6##*/} \$4"

  install_fixture definitions/with-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}


@test "package URL with invalid checksum" {
  stub md5 true "echo 83e6d7725e20166024a1eb74cde80677"
  stub curl "-C - -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${6##*/} \$4"

  install_fixture definitions/with-invalid-checksum
  [ "$status" -eq 1 ]
  [ ! -f "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}


@test "package URL with checksum but no MD5 support" {
  stub md5 false
  stub curl "-C - -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${6##*/} \$4"

  install_fixture definitions/with-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}


@test "package with invalid checksum" {
  stub md5 true "echo invalid"
  stub curl "-C - -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${6##*/} \$4"

  install_fixture definitions/with-checksum
  [ "$status" -eq 1 ]
  [ ! -f "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}
