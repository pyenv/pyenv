#!/usr/bin/env bats

load test_helper
export PYTHON_BUILD_SKIP_MIRROR=1
export PYTHON_BUILD_CACHE_PATH="$TMP/cache"
unset PYTHON_BUILD_ARIA2_OPTS

setup() {
  mkdir "$PYTHON_BUILD_CACHE_PATH"
}


@test "packages are saved to download cache" {
  stub aria2c "-o * http://example.com/* : cp $FIXTURE_ROOT/\${3##*/} \$2"

  install_fixture definitions/without-checksum

  assert_success
  assert [ -e "${PYTHON_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" ]

  unstub aria2c
}


@test "cached package without checksum" {
  stub aria2c

  cp "${FIXTURE_ROOT}/package-1.0.0.tar.gz" "$PYTHON_BUILD_CACHE_PATH"

  install_fixture definitions/without-checksum

  assert_success
  assert [ -e "${PYTHON_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" ]

  unstub aria2c
}


@test "cached package with valid checksum" {
  stub shasum true "echo ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"
  stub aria2c

  cp "${FIXTURE_ROOT}/package-1.0.0.tar.gz" "$PYTHON_BUILD_CACHE_PATH"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]
  assert [ -e "${PYTHON_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" ]

  unstub aria2c
  unstub shasum
}


@test "cached package with invalid checksum falls back to mirror and updates cache" {
  export PYTHON_BUILD_SKIP_MIRROR=
  local checksum="ba988b1bb4250dee0b9dd3d4d722f9c64b2bacfc805d1b6eba7426bda72dd3c5"

  stub shasum true "echo invalid" "echo $checksum"
  stub aria2c "--dry-run * : true" \
    "-o * https://?*/$checksum : cp $FIXTURE_ROOT/package-1.0.0.tar.gz \$2"

  touch "${PYTHON_BUILD_CACHE_PATH}/package-1.0.0.tar.gz"

  install_fixture definitions/with-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]
  assert [ -e "${PYTHON_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" ]
  assert diff -q "${PYTHON_BUILD_CACHE_PATH}/package-1.0.0.tar.gz" "${FIXTURE_ROOT}/package-1.0.0.tar.gz"

  unstub aria2c
  unstub shasum
}


@test "nonexistent cache directory is ignored" {
  stub aria2c "-o * http://example.com/* : cp $FIXTURE_ROOT/\${3##*/} \$2"

  export PYTHON_BUILD_CACHE_PATH="${TMP}/nonexistent"

  install_fixture definitions/without-checksum

  assert_success
  assert [ -x "${INSTALL_ROOT}/bin/package" ]
  refute [ -d "$PYTHON_BUILD_CACHE_PATH" ]

  unstub aria2c
}
