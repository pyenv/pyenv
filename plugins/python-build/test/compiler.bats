#!/usr/bin/env bats

load test_helper

@test "Xcode SDK zlib honors SDKROOT and preserves compiler flags" {
  export SDKROOT="${BATS_TEST_TMPDIR}/selected-sdk"
  mkdir -p "$SDKROOT"
  stub xcrun 'false'

  run_inline_definition <<'DEF'
osx_using_default_compiler() { return 0; }
export CFLAGS=-O2 LDFLAGS=-custom-linker-flag
use_xcode_sdk_zlib
echo "CFLAGS=$CFLAGS"
echo "LDFLAGS=$LDFLAGS"
DEF

  assert_success
  assert_output <<OUT
python-build: use zlib from xcode sdk
CFLAGS=-O2 -isysroot $SDKROOT
LDFLAGS=-custom-linker-flag -isysroot $SDKROOT
OUT
  # Explicit SDKROOT must bypass SDK discovery.
  [ ! -s "$XCRUN_STUB_LOG" ]
}

@test "Xcode SDK zlib discovers SDK when SDKROOT is empty" {
  export SDKROOT=
  local sdkroot="${BATS_TEST_TMPDIR}/discovered-sdk"
  mkdir -p "$sdkroot"
  stub xcrun "--sdk macosx --show-sdk-path : echo '$sdkroot'"

  run_inline_definition <<'DEF'
osx_using_default_compiler() { return 0; }
unset CFLAGS LDFLAGS
use_xcode_sdk_zlib
echo "CFLAGS=$CFLAGS"
echo "LDFLAGS=$LDFLAGS"
DEF

  assert_success
  assert_output <<OUT
python-build: use zlib from xcode sdk
CFLAGS=-isysroot $sdkroot
LDFLAGS=-isysroot $sdkroot
OUT
  unstub xcrun
}

_setup() {
  export MAKE=make
  export MAKE_OPTS='-j 2'
  export -n CFLAGS
  export -n CC
  export -n PYTHON_CONFIGURE_OPTS
}

@test "require_gcc on OS X 10.9" {

  stub uname '-s : echo Darwin'
  stub sw_vers '-productVersion : echo 10.9.5'

  stub gcc '--version : echo 4.2.1'

  run_inline_definition <<DEF
require_gcc
echo CC=\$CC
echo MACOSX_DEPLOYMENT_TARGET=\${MACOSX_DEPLOYMENT_TARGET-no}
DEF
  assert_success
  assert_output <<OUT
CC=${BATS_TEST_TMPDIR}/bin/gcc
MACOSX_DEPLOYMENT_TARGET=10.9
OUT

  unstub uname
  unstub sw_vers
  unstub gcc
}

@test "require_gcc on OS X 10.10" {
  stub uname '-s : echo Darwin'
  stub sw_vers '-productVersion : echo 10.10'

  stub gcc '--version : echo 4.2.1'

  run_inline_definition <<DEF
require_gcc
echo CC=\$CC
echo MACOSX_DEPLOYMENT_TARGET=\${MACOSX_DEPLOYMENT_TARGET-no}
DEF

  unstub uname
  unstub sw_vers
  unstub gcc

  assert_success
  assert_output <<OUT
CC=${BATS_TEST_TMPDIR}/bin/gcc
MACOSX_DEPLOYMENT_TARGET=10.10
OUT
}

@test "require_gcc silences warnings" {
  stub gcc '--version : echo warning >&2; echo 4.2.1'

  run_inline_definition <<DEF
require_gcc
echo \$CC
DEF
  assert_success "${BATS_TEST_TMPDIR}/bin/gcc"

  unstub gcc
}

@test "CC=clang by default on OS X 10.10" {
  mkdir -p "$INSTALL_ROOT"
  cd "$INSTALL_ROOT"

  stub uname '-s : echo Darwin'
  stub sw_vers '-productVersion : echo 10.10'

  stub cc 'false'
  stub brew 'false'
  stub make \
    'echo make $@' \
    'echo make $@'

  cat > ./configure <<CON
#!${BASH}
echo ./configure "\$@"
echo CC=\$CC
echo CFLAGS=\${CFLAGS-no}
CON
  chmod +x ./configure

  run_inline_definition <<DEF
exec 4<&1
build_package_standard python
DEF
  assert_success
  assert_output <<OUT
./configure --prefix=$INSTALL_ROOT --enable-shared --libdir=${BATS_TEST_TMPDIR}/install/lib
CC=clang
CFLAGS=no
make -j 2
make install
OUT

  unstub uname
  unstub sw_vers

}

@test "passthrough CFLAGS_EXTRA to micropython compiler" {
    mkdir -p "$INSTALL_ROOT/mpy-cross"
    mkdir -p "$INSTALL_ROOT/ports/unix"
    mkdir -p "$INSTALL_ROOT/bin"
    cd "$INSTALL_ROOT"

    stub make true '(for a in "$@"; do echo $a; done)|grep -E "^CFLAGS_EXTRA="' true
    stub ln true
    stub mkdir true
    run_inline_definition <<DEF
exec 4<&1
CFLAGS_EXTRA='-Wno-floating-conversion' build_package_micropython
DEF

    assert_success
    assert_output <<OUT
CFLAGS_EXTRA=-DMICROPY_PY_SYS_PATH_DEFAULT='".frozen:${BATS_TEST_TMPDIR}/install/lib/micropython"' -Wno-floating-conversion
OUT
}
