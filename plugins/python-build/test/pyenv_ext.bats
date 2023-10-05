#!/usr/bin/env bats

load test_helper
export PYTHON_BUILD_CACHE_PATH="$TMP/cache"
export MAKE=make
export MAKE_OPTS="-j 2"
export CC=cc
export PYTHON_BUILD_HTTP_CLIENT="curl"

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

resolve_link() {
  $(type -P greadlink readlink | head -n1) "$1"
}

run_inline_definition_with_name() {
  local definition_name="build-definition"
  case "$1" in
  "--name="* )
    local definition_name="${1#--name=}"
    shift 1
    ;;
  esac
  local definition="${TMP}/${definition_name}"
  cat > "$definition"
  run python-build "$definition" "${1:-$INSTALL_ROOT}"
}

@test "apply built-in python patch before building" {
  cached_tarball "Python-3.6.2"

  stub brew false
  stub_make_install
  stub patch ' : echo patch "$@" | sed -E "s/\.[[:alnum:]]+$/.XXX/" >> build.log'

  echo | install_patch definitions/vanilla-python "Python-3.6.2/empty.patch"

  # yyuu/pyenv#257
  stub uname '-s : echo Linux'
  stub uname '-s : echo Linux'

  TMPDIR="$TMP" install_tmp_fixture definitions/vanilla-python < /dev/null
  assert_success

  assert_build_log <<OUT
patch -p0 --force -i $TMP/python-patch.XXX
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib"
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT

  unstub make
  unstub patch
}

@test "apply built-in python patches should be sorted by its name" {
  cached_tarball "Python-3.6.2"

  for i in {1..2}; do stub brew '* : false'; done
  stub_make_install
  stub patch ' : for arg; do [[ "$arg" == "-"* ]] || sed -e "s/^/patch: /" "$arg"; done >> build.log'

  echo "foo" | install_patch definitions/vanilla-python "Python-3.6.2/foo.patch"
  echo "bar" | install_patch definitions/vanilla-python "Python-3.6.2/bar.patch"
  echo "baz" | install_patch definitions/vanilla-python "Python-3.6.2/baz.patch"

  for i in {1..2}; do stub uname '-s : echo Linux'; done

  TMPDIR="$TMP" install_tmp_fixture definitions/vanilla-python < /dev/null
  assert_success

  assert_build_log <<OUT
patch: bar
patch: baz
patch: foo
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib"
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT

  unstub make
  unstub patch
}

@test "allow custom make install target" {
  cached_tarball "Python-3.6.2"

  stub brew false
  stub "$MAKE" \
    " : echo \"$MAKE \$@\" >> build.log" \
    " : echo \"$MAKE \$@\" >> build.log && cat build.log >> '$INSTALL_ROOT/build.log'"

  for i in {1..4}; do stub uname '-s : echo Darwin'; done

  PYTHON_MAKE_INSTALL_TARGET="altinstall" TMPDIR="$TMP" install_tmp_fixture definitions/vanilla-python < /dev/null
  assert_success

  assert_build_log <<OUT
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib"
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make altinstall
OUT

  unstub make
}

@test "ensurepip without altinstall" {
  mkdir -p "${INSTALL_ROOT}/bin"
  cat <<OUT > "${INSTALL_ROOT}/bin/python"
#!$BASH
echo "python \$@" >> "${INSTALL_ROOT}/build.log"
OUT
  chmod +x "${INSTALL_ROOT}/bin/python"

  PYTHON_MAKE_INSTALL_TARGET="" TMPDIR="$TMP" run_inline_definition <<OUT
build_package_ensurepip
OUT
  assert_success

  assert_build_log <<OUT
python -I -m ensurepip
OUT
}

@test "ensurepip with altinstall" {
  mkdir -p "${INSTALL_ROOT}/bin"
  cat <<OUT > "${INSTALL_ROOT}/bin/python"
#!$BASH
echo "python \$@" >> "${INSTALL_ROOT}/build.log"
OUT
  chmod +x "${INSTALL_ROOT}/bin/python"

  PYTHON_MAKE_INSTALL_TARGET="altinstall" TMPDIR="$TMP" run_inline_definition <<OUT
build_package_ensurepip
OUT
  assert_success

  assert_build_log <<OUT
python -I -m ensurepip --altinstall
OUT
}

@test "python3-config" {
  mkdir -p "${INSTALL_ROOT}/bin"
  touch "${INSTALL_ROOT}/bin/python3"
  chmod +x "${INSTALL_ROOT}/bin/python3"
  touch "${INSTALL_ROOT}/bin/python3.4"
  chmod +x "${INSTALL_ROOT}/bin/python3.4"
  touch "${INSTALL_ROOT}/bin/python3-config"
  chmod +x "${INSTALL_ROOT}/bin/python3-config"
  touch "${INSTALL_ROOT}/bin/python3.4-config"
  chmod +x "${INSTALL_ROOT}/bin/python3.4-config"

  TMPDIR="$TMP" run_inline_definition <<OUT
verify_python python3.4
OUT
  assert_success

  [ -L "${INSTALL_ROOT}/bin/python" ]
  [ -L "${INSTALL_ROOT}/bin/python-config" ]
  [[ "$(resolve_link "${INSTALL_ROOT}/bin/python")" == "python3.4" ]]
  [[ "$(resolve_link "${INSTALL_ROOT}/bin/python-config")" == "python3.4-config" ]]
}

@test "enable framework" {
  framework_path="${INSTALL_ROOT}/Library/Frameworks/Python.framework/Versions/Current/bin"
  mkdir -p "$framework_path"
  for executable in python3{,.4}{,-config}; do 
    touch "$framework_path/$executable"
    chmod +x "$framework_path/$executable"
  done
  unset framework_path executable

  for i in {1..3}; do stub uname '-s : echo Darwin'; done

  PYTHON_CONFIGURE_OPTS="--enable-framework" TMPDIR="$TMP" run_inline_definition <<OUT
echo "PYTHON_CONFIGURE_OPTS_ARRAY=(\${PYTHON_CONFIGURE_OPTS_ARRAY[@]})"
echo "PYTHON_CONFIGURE_OPTS=(\${PYTHON_CONFIGURE_OPTS})"
echo "CONFIGURE_OPTS=(\${CONFIGURE_OPTS})"
verify_python python3.4
OUT
  assert_success
  assert_output <<EOS
PYTHON_CONFIGURE_OPTS_ARRAY=(--libdir=${TMP}/install/lib --enable-framework=${TMP}/install/Library/Frameworks)
PYTHON_CONFIGURE_OPTS=()
CONFIGURE_OPTS=()
EOS

  [ -L "${INSTALL_ROOT}/Library/Frameworks/Python.framework/Versions/Current/bin/python" ]
  [ -L "${INSTALL_ROOT}/Library/Frameworks/Python.framework/Versions/Current/bin/python-config" ]
}

@test "enable universalsdk" {
  
  for i in {1..3}; do stub uname '-s : echo Darwin'; done
  stub arch "echo x86_64"

  PYTHON_CONFIGURE_OPTS="--enable-universalsdk" TMPDIR="$TMP" run_inline_definition <<OUT
echo "PYTHON_CONFIGURE_OPTS_ARRAY=(\${PYTHON_CONFIGURE_OPTS_ARRAY[@]})"
echo "PYTHON_CONFIGURE_OPTS=(\${PYTHON_CONFIGURE_OPTS})"
echo "CONFIGURE_OPTS=(\${CONFIGURE_OPTS})"
OUT
  assert_success
  assert_output <<EOS
PYTHON_CONFIGURE_OPTS_ARRAY=(--enable-shared --libdir=${TMP}/install/lib --enable-universalsdk=/)
PYTHON_CONFIGURE_OPTS=()
CONFIGURE_OPTS=()
EOS
}

@test "enable universalsdk on Apple Silicon" {

  for i in {1..3}; do stub uname '-s : echo Darwin'; done
  stub arch "echo arm64"

  PYTHON_CONFIGURE_OPTS="--enable-universalsdk" TMPDIR="$TMP" run_inline_definition <<OUT
echo "PYTHON_CONFIGURE_OPTS_ARRAY=(\${PYTHON_CONFIGURE_OPTS_ARRAY[@]})"
echo "PYTHON_CONFIGURE_OPTS=(\${PYTHON_CONFIGURE_OPTS})"
echo "CONFIGURE_OPTS=(\${CONFIGURE_OPTS})"
OUT
  assert_success
  assert_output <<EOS
PYTHON_CONFIGURE_OPTS_ARRAY=(--enable-shared --libdir=${TMP}/install/lib --enable-universalsdk=/ --with-universal-archs=universal2)
PYTHON_CONFIGURE_OPTS=()
CONFIGURE_OPTS=()
EOS
}

@test "enable universalsdk with explicit archs argument" {

  for i in {1..3}; do stub uname '-s : echo Darwin'; done

  PYTHON_CONFIGURE_OPTS="--enable-universalsdk --with-universal-archs=foo" TMPDIR="$TMP" run_inline_definition <<OUT
echo "PYTHON_CONFIGURE_OPTS_ARRAY=(\${PYTHON_CONFIGURE_OPTS_ARRAY[@]})"
OUT
  assert_success
  assert_output <<EOS
PYTHON_CONFIGURE_OPTS_ARRAY=(--enable-shared --libdir=${TMP}/install/lib --enable-universalsdk=/)
EOS
}

@test "enable custom unicode configuration" {
  cached_tarball "Python-3.6.2"

  for i in {1..4}; do stub brew false; done
  for i in {1..8}; do stub uname '-s : echo Linux'; done
  stub "$MAKE" \
    " : echo \"$MAKE \$@\" >> build.log" \
    " : echo \"$MAKE \$@\" >> build.log && cat build.log >> '$INSTALL_ROOT/build.log'"

  PYTHON_CONFIGURE_OPTS="--enable-unicode=ucs2" TMPDIR="$TMP" install_tmp_fixture definitions/vanilla-python < /dev/null
  assert_success

  assert_build_log <<OUT
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib"
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib --enable-unicode=ucs2
make -j 2
make install
OUT

  unstub make
  unstub uname
}

@test "default MACOSX_DEPLOYMENT_TARGET" {
  # yyuu/pyenv#257
  for i in {1..3}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 10.10'; done

  TMPDIR="$TMP" run_inline_definition <<OUT
echo "\${MACOSX_DEPLOYMENT_TARGET}"
OUT
  assert_success
  assert_output "10.10"
}

@test "use custom MACOSX_DEPLOYMENT_TARGET if defined" {
  # yyuu/pyenv#257
  stub uname '-s : echo Darwin'

  stub uname '-s : echo Darwin'

  MACOSX_DEPLOYMENT_TARGET="10.4" TMPDIR="$TMP" run_inline_definition <<OUT
echo "\${MACOSX_DEPLOYMENT_TARGET}"
OUT
  assert_success
  assert_output "10.4"
}

@test "use the default EZ_SETUP_URL by default" {
  run_inline_definition <<OUT
echo "\${EZ_SETUP_URL}"
OUT
  assert_output "https://bootstrap.pypa.io/ez_setup.py"
  assert_success
}

@test "use the default GET_PIP_URL by default" {
  run_inline_definition <<OUT
echo "\${GET_PIP_URL}"
OUT
  assert_output "https://bootstrap.pypa.io/get-pip.py"
  assert_success
}

@test "use the custom GET_PIP_URL for 2.6 versions" {
  run_inline_definition_with_name --name=2.6 <<OUT
echo "\${GET_PIP_URL}"
OUT
  assert_output "https://bootstrap.pypa.io/pip/2.6/get-pip.py"
  assert_success
}

@test "use the custom GET_PIP_URL for 2.7 versions" {
  run_inline_definition_with_name --name=2.7 <<OUT
echo "\${GET_PIP_URL}"
OUT
  assert_output "https://bootstrap.pypa.io/pip/2.7/get-pip.py"
  assert_success
}

@test "use the custom GET_PIP_URL for 3.2 versions" {
  run_inline_definition_with_name --name=3.2 <<OUT
echo "\${GET_PIP_URL}"
OUT
  assert_output "https://bootstrap.pypa.io/pip/3.2/get-pip.py"
  assert_success
}

@test "use the custom GET_PIP_URL for 3.3 versions" {
  run_inline_definition_with_name --name=3.3 <<OUT
echo "\${GET_PIP_URL}"
OUT
  assert_output "https://bootstrap.pypa.io/pip/3.3/get-pip.py"
  assert_success
}

@test "use the custom GET_PIP_URL for 3.4 versions" {
  run_inline_definition_with_name --name=3.4 <<OUT
echo "\${GET_PIP_URL}"
OUT
  assert_output "https://bootstrap.pypa.io/pip/3.4/get-pip.py"
  assert_success
}

@test "use the custom GET_PIP_URL for 3.5 versions" {
  run_inline_definition_with_name --name=3.5 <<OUT
echo "\${GET_PIP_URL}"
OUT
  assert_output "https://bootstrap.pypa.io/pip/3.5/get-pip.py"
  assert_success
}

@test "use the custom GET_PIP_URL for 3.6 versions" {
  run_inline_definition_with_name --name=3.6 <<OUT
echo "\${GET_PIP_URL}"
OUT
  assert_output "https://bootstrap.pypa.io/pip/3.6/get-pip.py"
  assert_success
}

@test "use the custom GET_PIP_URL for pypy2.7 versions" {
  run_inline_definition_with_name --name=pypy2.7-7.3.12 <<OUT
echo "\${GET_PIP_URL}"
OUT
  assert_output "https://bootstrap.pypa.io/pip/2.7/get-pip.py"
  assert_success
}

@test "use the custom GET_PIP_URL for pypy3.5 versions" {
  run_inline_definition_with_name --name=pypy3.5-7.0.0 <<OUT
echo "\${GET_PIP_URL}"
OUT
  assert_output "https://bootstrap.pypa.io/pip/3.5/get-pip.py"
  assert_success
}

@test "use the custom GET_PIP_URL for pypy3.6 versions" {
  run_inline_definition_with_name --name=pypy3.6-7.3.3 <<OUT
echo "\${GET_PIP_URL}"
OUT
  assert_output "https://bootstrap.pypa.io/pip/3.6/get-pip.py"
  assert_success
}
