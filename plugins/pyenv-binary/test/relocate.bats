#!/usr/bin/env bats

load test_helper

_setup() {
  create_stub pyenv-help "echo usage"
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'
}

stub_patchelf() {
  create_path_executable patchelf <<STUB
if [ "\$1" = "--print-rpath" ]; then
  exit 0
fi
echo "\$*" >> "${BATS_TEST_TMPDIR}/patchelf.log"
STUB
}

create_interpreter() {
  mkdir -p "${BATS_TEST_TMPDIR}/prefix/bin"
  printf '#!/bin/sh\n' > "${BATS_TEST_TMPDIR}/prefix/bin/python2.7"
  chmod +x "${BATS_TEST_TMPDIR}/prefix/bin/python2.7"
}

create_macos_tree() {
  local prefix="${BATS_TEST_TMPDIR}/prefix"
  local lib="${prefix}/lib/python3.12"
  mkdir -p "${prefix}/bin" "${lib}/lib-dynload" "${lib}/site-packages/numpy"
  printf '#!/bin/sh\n' > "${prefix}/bin/python3.12"
  chmod +x "${prefix}/bin/python3.12"
  touch "${prefix}/lib/libpython3.12.dylib"
  touch "${lib}/lib-dynload/_ssl.cpython-312-darwin.so"
  touch "${lib}/site-packages/numpy/_multiarray.so"
}

stub_macos_tools() {
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'
  create_path_executable install_name_tool \
    'echo "$*" >> "${BATS_TEST_TMPDIR}/install-name-tool.log"'
  create_path_executable otool <<'STUB'
file="${!#}"
echo "$*" >> "${BATS_TEST_TMPDIR}/otool.log"
old="/build prefix/3.12.7"
case "$1" in
-L )
  echo "${file}:"
  case "$file" in
  */bin/python3.12 )
    if [ -n "$OTOOL_RELOCATED" ]; then
      echo "    @rpath/libpython3.12.dylib (compatibility version 3.12.0, current version 3.12.0)"
    else
      echo "    ${old}/lib/libpython3.12.dylib (compatibility version 3.12.0, current version 3.12.0)"
    fi
    echo "    ${old}-other/lib/libother.dylib (compatibility version 1.0.0, current version 1.0.0)"
    echo "    /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1.0.0)"
    echo "    /opt/homebrew/lib/libintl.8.dylib (compatibility version 1.0.0, current version 1.0.0)"
    echo "    @loader_path/liblocal.dylib (compatibility version 1.0.0, current version 1.0.0)"
    ;;
  */lib/libpython3.12.dylib )
    if [ -n "$OTOOL_RELOCATED" ]; then
      echo "    @rpath/libpython3.12.dylib (compatibility version 3.12.0, current version 3.12.0)"
    else
      echo "    ${old}/lib/libpython3.12.dylib (compatibility version 3.12.0, current version 3.12.0)"
    fi
    ;;
  esac
  ;;
-D )
  echo "${file}:"
  case "$file" in
  */lib/libpython3.12.dylib )
    if [ -n "$OTOOL_RELOCATED" ]; then
      echo '@rpath/libpython3.12.dylib'
    else
      echo "${old}/lib/libpython3.12.dylib"
    fi
    ;;
  esac
  ;;
-l )
  if [ -n "$OTOOL_RELOCATED" ]; then
    case "$file" in
    */bin/* ) rpath='@executable_path/../lib' ;;
    */lib/*.dylib ) rpath='@loader_path' ;;
    * ) rpath='@loader_path/../..' ;;
    esac
  else
    rpath="${old}/lib"
  fi
  cat <<EOF
          cmd LC_RPATH
         path ${rpath} (offset 12)
          cmd LC_RPATH
         path /opt/homebrew/lib (offset 12)
          cmd LC_RPATH
         path @loader_path/vendor (offset 12)
EOF
  ;;
esac
STUB
}

@test "completion produces nothing" {
  run pyenv-binary-relocate --complete
  assert_success ""
}

@test "fails without a prefix" {
  run pyenv-binary-relocate
  assert_failure "usage"
}

@test "fails when patchelf is not available" {
  PATH="$(path_without patchelf)" run pyenv-binary-relocate "${BATS_TEST_TMPDIR}/prefix"
  assert_failure "pyenv-binary: need patchelf to relocate the binary"
}

@test "fails without the original build prefix on macOS" {
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'

  run pyenv-binary-relocate "${BATS_TEST_TMPDIR}/prefix"
  assert_failure "pyenv-binary: need the original build prefix to relocate a macOS binary"
}

@test "fails when otool is not available on macOS" {
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'
  create_path_executable install_name_tool true

  PATH="$(path_without otool)" run \
    pyenv-binary-relocate "${BATS_TEST_TMPDIR}/prefix" /build/3.12.7
  assert_failure "pyenv-binary: need otool to relocate the binary"
}

@test "fails when install_name_tool is not available on macOS" {
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'
  create_path_executable otool true

  PATH="$(path_without install_name_tool)" run \
    pyenv-binary-relocate "${BATS_TEST_TMPDIR}/prefix" /build/3.12.7
  assert_failure "pyenv-binary: need install_name_tool to relocate the binary"
}

@test "fails when the prefix has no interpreter" {
  create_path_executable patchelf "exit 0"
  mkdir -p "${BATS_TEST_TMPDIR}/prefix"

  run pyenv-binary-relocate "${BATS_TEST_TMPDIR}/prefix"
  assert_failure "pyenv-binary: found no interpreter to relocate under \`${BATS_TEST_TMPDIR}/prefix/bin'"
}

@test "relocates an executable interpreter" {
  stub_patchelf
  create_interpreter

  run pyenv-binary-relocate "${BATS_TEST_TMPDIR}/prefix"
  assert_success
  run cat "${BATS_TEST_TMPDIR}/patchelf.log"
  assert_output "--set-rpath ${BATS_TEST_TMPDIR}/prefix/lib ${BATS_TEST_TMPDIR}/prefix/bin/python2.7"
}

@test "relocates the extension modules but not what a wheel installed" {
  local lib="${BATS_TEST_TMPDIR}/prefix/lib/python3.12"
  stub_patchelf
  create_interpreter
  mkdir -p "${lib}/lib-dynload" "${lib}/site-packages/numpy"
  touch "${lib}/lib-dynload/_ssl.cpython-312-x86_64-linux-gnu.so"
  # A wheel points its extensions at the libraries it bundles alongside them, so
  # its rpath is its own business and must survive relocation.
  touch "${lib}/site-packages/numpy/_multiarray.so"

  run pyenv-binary-relocate "${BATS_TEST_TMPDIR}/prefix"
  assert_success
  run cat "${BATS_TEST_TMPDIR}/patchelf.log"
  assert_line "--set-rpath ${BATS_TEST_TMPDIR}/prefix/lib ${lib}/lib-dynload/_ssl.cpython-312-x86_64-linux-gnu.so"
  refute_line "--set-rpath ${BATS_TEST_TMPDIR}/prefix/lib ${lib}/site-packages/numpy/_multiarray.so"
}

@test "relocates macOS load commands without changing unrelated entries" {
  local prefix="${BATS_TEST_TMPDIR}/prefix"
  local old="/build prefix/3.12.7"
  local lib="${prefix}/lib/python3.12"
  create_macos_tree
  stub_macos_tools

  run pyenv-binary-relocate "$prefix" "$old"
  assert_success
  run cat "${BATS_TEST_TMPDIR}/install-name-tool.log"
  assert_output <<EOF
-change ${old}/lib/libpython3.12.dylib @rpath/libpython3.12.dylib ${prefix}/bin/python3.12
-rpath ${old}/lib @executable_path/../lib ${prefix}/bin/python3.12
-id @rpath/libpython3.12.dylib ${prefix}/lib/libpython3.12.dylib
-rpath ${old}/lib @loader_path ${prefix}/lib/libpython3.12.dylib
-rpath ${old}/lib @loader_path/../.. ${lib}/lib-dynload/_ssl.cpython-312-darwin.so
EOF
  run grep -F "${lib}/site-packages/numpy/_multiarray.so" "${BATS_TEST_TMPDIR}/otool.log"
  assert_failure
}

@test "skips already relocated macOS load commands" {
  local prefix="${BATS_TEST_TMPDIR}/prefix"
  create_macos_tree
  stub_macos_tools
  export OTOOL_RELOCATED=1

  run pyenv-binary-relocate "$prefix" "/build prefix/3.12.7"
  assert_success
  assert [ ! -e "${BATS_TEST_TMPDIR}/install-name-tool.log" ]
}

@test "fails when install_name_tool cannot modify a selected file" {
  local prefix="${BATS_TEST_TMPDIR}/prefix"
  create_macos_tree
  stub_macos_tools
  create_path_executable install_name_tool 'exit 1'

  run pyenv-binary-relocate "$prefix" "/build prefix/3.12.7"
  assert_failure ""
}
