#!/usr/bin/env bats

load test_helper
export MAKE=make
export MAKE_OPTS='-j 2'
export -n CFLAGS
export -n CC
export -n PYTHON_CONFIGURE_OPTS



@test "passthrough CFLAGS_EXTRA to micropython compiler" {
    mkdir -p "$INSTALL_ROOT/mpy-cross"
    mkdir -p "$INSTALL_ROOT/ports/unix"
    mkdir -p "$INSTALL_ROOT/bin"
    # touch "$INSTALL_ROOT/bin/python"
    cd "$INSTALL_ROOT"

    stub make true true '(for a in "$@"; do echo $a; done)|grep -E "^CFLAGS_EXTRA="' true
    stub ln true
    stub mkdir true
    run_inline_definition <<DEF
exec 4<&1
CFLAGS_EXTRA='-Wno-floating-conversion' build_package_micropython
DEF

    #assert_success
    assert_output <<OUT
CFLAGS_EXTRA=-DMICROPY_PY_SYS_PATH_DEFAULT='"${TMP}/install/lib/micropython"' -Wno-floating-conversion
OUT
}
