#!/usr/bin/env bats

load test_helper
export MAKE=make
export MAKE_OPTS='-j 2'
export -n CFLAGS
export -n CC
export -n PYTHON_CONFIGURE_OPTS

@test "require_gcc on OS X 10.9" {
  # yyuu/pyenv#222
  stub uname '-s : echo Darwin'
  stub sw_vers '-productVersion : echo 10.9.5'

  # yyuu/pyenv#257
  stub uname '-s : echo Darwin'

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
CC=${TMP}/bin/gcc
MACOSX_DEPLOYMENT_TARGET=10.9
OUT
}

@test "require_gcc on OS X 10.10" {
  # yyuu/pyenv#222
  stub uname '-s : echo Darwin'
  stub sw_vers '-productVersion : echo 10.10'

  # yyuu/pyenv#257
  stub uname '-s : echo Darwin'

  stub uname '-s : echo Darwin'
  stub sw_vers '-productVersion : echo 10.10'
  stub gcc '--version : echo 4.2.1'

  run_inline_definition <<DEF
require_gcc
echo CC=\$CC
echo MACOSX_DEPLOYMENT_TARGET=\${MACOSX_DEPLOYMENT_TARGET-no}
DEF
  assert_success
  assert_output <<OUT
CC=${TMP}/bin/gcc
MACOSX_DEPLOYMENT_TARGET=10.9
OUT
}

@test "require_gcc silences warnings" {
  stub gcc '--version : echo warning >&2; echo 4.2.1'

  run_inline_definition <<DEF
require_gcc
echo \$CC
DEF
  assert_success "${TMP}/bin/gcc"
}

@test "CC=clang by default on OS X 10.10" {
  mkdir -p "$INSTALL_ROOT"
  cd "$INSTALL_ROOT"

  # yyuu/pyenv#222
  stub uname '-s : echo Darwin'
  stub sw_vers '-productVersion : echo 10.10'

  # yyuu/pyenv#257
  stub uname '-s : echo Darwin'

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
./configure --prefix=$INSTALL_ROOT --libdir=${TMP}/install/lib
CC=clang
CFLAGS=no
make -j 2
make install
OUT
}
