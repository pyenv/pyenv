#!/usr/bin/env bats

load test_helper
export PYTHON_BUILD_CACHE_PATH="$TMP/cache"
export MAKE=make
export MAKE_OPTS="-j 2"
export CC=cc

export TMP_FIXTURES="$TMP/fixtures"

setup() {
  mkdir -p "$INSTALL_ROOT"
  stub md5 false
  stub curl false
}

executable() {
  local file="$1"
  mkdir -p "${file%/*}"
  cat > "$file"
  chmod +x "$file"
}

cached_tarball() {
  mkdir -p "$PYTHON_BUILD_CACHE_PATH"
  pushd "$PYTHON_BUILD_CACHE_PATH" >/dev/null
  tarball "$@"
  popd >/dev/null
}

tarball() {
  local name="$1"
  local path="$PWD/$name"
  local configure="$path/configure"
  shift 1

  executable "$configure" <<OUT
#!$BASH
echo "$name: CPPFLAGS=\\"\$CPPFLAGS\\" LDFLAGS=\\"\$LDFLAGS\\"" >> build.log
echo "$name: \$@" \${PYTHONOPT:+PYTHONOPT=\$PYTHONOPT} >> build.log
OUT

  for file; do
    mkdir -p "$(dirname "${path}/${file}")"
    touch "${path}/${file}"
  done

  tar czf "${path}.tar.gz" -C "${path%/*}" "$name"
}

stub_make_install() {
  stub "$MAKE" \
    " : echo \"$MAKE \$@\" >> build.log" \
    "install : echo \"$MAKE \$@\" >> build.log && cat build.log >> '$INSTALL_ROOT/build.log'"
}

assert_build_log() {
  run cat "$INSTALL_ROOT/build.log"
  assert_output
}

install_patch() {
  local name="$1"
  local patch="$2"
  [ -n "$patch" ] || patch="python.patch"

  mkdir -p "${TMP_FIXTURES}/${name%/*}/patches/${name##*/}/${patch%/*}"
  cat > "${TMP_FIXTURES}/${name%/*}/patches/${name##*/}/${patch}"
}

install_tmp_fixture() {
  local args

  while [ "${1#-}" != "$1" ]; do
    args="$args $1"
    shift 1
  done

  local name="$1"
  local destination="$2"
  [ -n "$destination" ] || destination="$INSTALL_ROOT"

  # Copy fixture to temporary path
  mkdir -p "${TMP_FIXTURES}/${name%/*}"
  cp "${FIXTURE_ROOT}/${name}" "${TMP_FIXTURES}/${name}"

  run python-build $args "$TMP_FIXTURES/$name" "$destination"
}

@test "apply built-in python patch before building" {
  cached_tarball "Python-3.2.1"

  stub brew false
  stub_make_install
  stub patch ' : echo patch "$@" | sed -E "s/\.[[:alnum:]]+$/.XXX/" >> build.log'

  echo | install_patch definitions/vanilla-python "Python-3.2.1/empty.patch"

  TMPDIR="$TMP" install_tmp_fixture definitions/vanilla-python < /dev/null
  assert_success

  assert_build_log <<OUT
patch -p0 --force -i $TMP/python-patch.XXX
Python-3.2.1: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
Python-3.2.1: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT

  unstub make
  unstub patch
}

@test "apply built-in python patches should be sorted by its name" {
  cached_tarball "Python-3.2.1"

  stub brew false
  stub_make_install
  stub patch ' : for arg; do [[ "$arg" == "-"* ]] || sed -e "s/^/patch: /" "$arg"; done >> build.log'

  echo "foo" | install_patch definitions/vanilla-python "Python-3.2.1/foo.patch"
  echo "bar" | install_patch definitions/vanilla-python "Python-3.2.1/bar.patch"
  echo "baz" | install_patch definitions/vanilla-python "Python-3.2.1/baz.patch"

  TMPDIR="$TMP" install_tmp_fixture definitions/vanilla-python < /dev/null
  assert_success

  assert_build_log <<OUT
patch: bar
patch: baz
patch: foo
Python-3.2.1: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
Python-3.2.1: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT

  unstub make
  unstub patch
}

@test "allow custom make install target" {
  cached_tarball "Python-3.2.1"

  stub brew false
  stub "$MAKE" \
    " : echo \"$MAKE \$@\" >> build.log" \
    " : echo \"$MAKE \$@\" >> build.log && cat build.log >> '$INSTALL_ROOT/build.log'"

  PYTHON_MAKE_INSTALL_TARGET="altinstall" TMPDIR="$TMP" install_tmp_fixture definitions/vanilla-python < /dev/null
  assert_success

  assert_build_log <<OUT
Python-3.2.1: CPPFLAGS="-I${TMP}/install/include " LDFLAGS="-L${TMP}/install/lib "
Python-3.2.1: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib
make -j 2
make altinstall
OUT

  unstub make
}
