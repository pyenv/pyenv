#!/usr/bin/env bats

load test_helper
export PYTHON_BUILD_SKIP_MIRROR=1
export PYTHON_BUILD_CACHE_PATH="$TMP/cache"

setup() {
  mkdir "$PYTHON_BUILD_CACHE_PATH"
}


@test "packages are saved to download cache" {
  stub shasum true
  stub curl "-q -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$3"

  install_fixture definitions/without-checksum
  [ "$status" -eq 0 ]
  [ -e "${PYTHON_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" ]

  unstub curl
  unstub shasum
}


@test "cached package without checksum" {
  stub shasum true
  stub curl

  cp "${FIXTURE_ROOT}/package-1.0.0.tar.gz" "$PYTHON_BUILD_CACHE_PATH"

  install_fixture definitions/without-checksum
  [ "$status" -eq 0 ]
  [ -e "${PYTHON_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" ]

  unstub curl
  unstub shasum
}


@test "cached package with valid checksum" {
  stub shasum true "echo ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"
  stub curl

  cp "${FIXTURE_ROOT}/package-1.0.0.tar.gz" "$PYTHON_BUILD_CACHE_PATH"

  install_fixture definitions/with-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]
  [ -e "${PYTHON_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" ]

  unstub curl
  unstub shasum
}


@test "cached package with invalid checksum falls back to mirror and updates cache" {
  export PYTHON_BUILD_SKIP_MIRROR=
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"

  stub shasum true "echo invalid" "echo $checksum"
  stub curl "-*I* : true" \
    "-q -o * -*S* https://?*/$checksum : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$3"

  touch "${PYTHON_BUILD_CACHE_PATH}/package-1.0.0.tar.gz"

  install_fixture definitions/with-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]
  [ -e "${PYTHON_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" ]
  diff -q "${PYTHON_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" "${FIXTURE_ROOT}/package-1.0.0.tar.gz"

  unstub curl
  unstub shasum
}


@test "nonexistent cache directory is ignored" {
  stub shasum true
  stub curl "-q -o * -*S* http://example.com/* : cp $FIXTURE_ROOT/\${5##*/} \$3"

  export PYTHON_BUILD_CACHE_PATH="${TMP}/nonexistent"

  install_fixture definitions/without-checksum
  [ "$status" -eq 0 ]
  [ -x "${INSTALL_ROOT}/bin/package" ]
  [ ! -d "$PYTHON_BUILD_CACHE_PATH" ]

  unstub curl
  unstub shasum
}
