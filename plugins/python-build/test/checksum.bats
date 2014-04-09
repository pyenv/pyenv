#!/usr/bin/env bats

load test_helper
export PYTHON_BUILD_SKIP_MIRROR=1
export PYTHON_BUILD_CACHE_PATH=


@test "package URL without checksum" {
  stub md5 true
  stub curl "-q -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$3"

  install_fixture definitions/without-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}


@test "package URL with valid checksum" {
  stub md5 true "echo 83e6d7725e20166024a1eb74cde80677"
  stub curl "-q -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$3"

  install_fixture definitions/with-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}


@test "package URL with invalid checksum" {
  stub md5 true "echo 83e6d7725e20166024a1eb74cde80677"
  stub curl "-q -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$3"

  install_fixture definitions/with-invalid-checksum
  [ "$status" -eq 1 ]
  [ ! -f "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}


@test "package URL with checksum but no MD5 support" {
  stub md5 false
  stub curl "-q -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$3"

  install_fixture definitions/with-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}


@test "package with invalid checksum" {
  stub md5 true "echo invalid"
  stub curl "-q -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$3"

  install_fixture definitions/with-checksum
  [ "$status" -eq 1 ]
  [ ! -f "${INSTALL_ROOT}/bin/package" ]

  unstub curl
  unstub md5
}

@test "existing tarball in build location is reused" {
  stub md5 true "echo 83e6d7725e20166024a1eb74cde80677"
  stub curl false
  stub wget false

  export -n PYTHON_BUILD_CACHE_PATH
  export PYTHON_BUILD_BUILD_PATH="${TMP}/build"

  mkdir -p "$PYTHON_BUILD_BUILD_PATH"
  ln -s "${FIXTURE_ROOT}/package-1.0.0.tar.gz" "$PYTHON_BUILD_BUILD_PATH"

  run_inline_definition <<DEF
install_package "package-1.0.0" "http://example.com/packages/package-1.0.0.tar.gz#83e6d7725e20166024a1eb74cde80677" copy
DEF

  assert_success
  [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub md5
}

@test "existing tarball in build location is discarded if not matching checksum" {
  stub md5 true \
    "echo invalid" \
    "echo 83e6d7725e20166024a1eb74cde80677"
  stub curl "-q -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$3"

  export -n PYTHON_BUILD_CACHE_PATH
  export PYTHON_BUILD_BUILD_PATH="${TMP}/build"

  mkdir -p "$PYTHON_BUILD_BUILD_PATH"
  touch "${PYTHON_BUILD_BUILD_PATH}/package-1.0.0.tar.gz"

  run_inline_definition <<DEF
install_package "package-1.0.0" "http://example.com/packages/package-1.0.0.tar.gz#83e6d7725e20166024a1eb74cde80677" copy
DEF

  assert_success
  [ -x "${INSTALL_ROOT}/bin/package" ]

  unstub md5
}
