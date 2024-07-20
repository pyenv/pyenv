#!/usr/bin/env bats

load test_helper
export PYENV_ROOT="${TMP}/pyenv"

setup() {
  stub pyenv-hooks 'install : true'
  stub pyenv-rehash true
}

stub_python_build_lib() {
  stub python-build "--lib : $BATS_TEST_DIRNAME/../bin/python-build --lib" "$@"
}

stub_python_build_no_latest() {
  stub python-build "${@:-echo python-build \"\$@\"}"
}
  
stub_python_build() {
  stub_python_build_no_latest "$@"
  stub pyenv-latest '-f -k * : shift 2; echo "$@"'
}

@test "install a single version" {
  stub_python_build_lib
  stub_python_build

  run pyenv-install 3.4.2
  assert_success "python-build 3.4.2 ${PYENV_ROOT}/versions/3.4.2"

  unstub python-build
}

@test "install multiple versions" {
  stub_python_build_lib
  stub_python_build
  stub_python_build

  run pyenv-install 3.4.1 3.4.2
  assert_success
  assert_output <<OUT
python-build 3.4.1 ${TMP}/pyenv/versions/3.4.1
python-build 3.4.2 ${TMP}/pyenv/versions/3.4.2
OUT

  unstub python-build
  unstub pyenv-latest
}

@test "install multiple versions, some fail" {
  stub_python_build_lib
  stub_python_build 'echo "fail: python-build" "$@"; false'

  run pyenv-install 3.4.1 3.4.2
  assert_failure
  assert_output <<OUT
fail: python-build 3.4.1 ${TMP}/pyenv/versions/3.4.1
OUT

  unstub python-build
}


@test "install resolves a prefix" {
  stub_python_build_lib
  for i in {1..3}; do stub_python_build_no_latest; done
  stub pyenv-latest \
      '-r -k 3.4 : echo 3.4.2' \
      '-r -k 3.5.1 : false' \
      '-r -k 3.5 : echo 3.5.2'

  run pyenv-install 3.4 3.5.1 3.5
  assert_success <<OUT
python-build 3.4.2 ${PYENV_ROOT}/versions/3.4.2
python-build 3.5.1 ${PYENV_ROOT}/versions/3.5.1
python-build 3.5.2 ${PYENV_ROOT}/versions/3.5.2
OUT


  unstub python-build
}


@test "install resolves :latest" {
  stub_python_build_lib
  for i in {1..2}; do stub_python_build '--definitions : echo -e 3.4.2\\n3.5.1\\n3.5.2'; done
  for i in {1..2}; do stub_python_build; done
  
  pyenv-hooks install; unstub pyenv-hooks
  PYENV_INSTALL_ROOT="$BATS_TEST_DIRNAME/../../.."
  export PYENV_HOOK_PATH="$PYENV_INSTALL_ROOT/pyenv.d"
  [[ -d "$PYENV_INSTALL_ROOT/libexec" ]] || skip "python-build is installed separately from pyenv"
  export PATH="$PATH:$PYENV_INSTALL_ROOT/libexec"

  run pyenv-install 3.4:latest 3:latest
  assert_success <<!
python-build 3.4.2 ${PYENV_ROOT}/versions/3.4.2
python-build 3.5.2 ${PYENV_ROOT}/versions/3.5.2
!

  unstub python-build
}

@test "install installs local versions by default" {
  stub_python_build_lib
  stub_python_build
  stub_python_build
  stub pyenv-local 'echo 3.4.2; echo 3.4.1'

  run pyenv-install
  assert_success <<OUT
python-build 3.4.2
python-build 3.4.1
OUT

  unstub python-build
  unstub pyenv-local
}

@test "list available versions" {
  stub_python_build_lib
  stub_python_build "--definitions : echo 2.6.9 2.7.9-rc1 2.7.9-rc2 3.4.2 | tr ' ' $'\\n'"

  run pyenv-install --list
  assert_success
  assert_output <<OUT
Available versions:
  2.6.9
  2.7.9-rc1
  2.7.9-rc2
  3.4.2
OUT

  unstub python-build
}

@test "upgrade instructions given for a nonexistent version" {
  stub brew false
  stub_python_build_lib
  stub_python_build 'echo ERROR >&2 && exit 2'
  stub_python_build "--definitions : echo 2.6.9 2.7.9-rc1 2.7.9-rc2 3.4.2 | tr ' ' $'\\n'"

  run pyenv-install 2.7.9
  assert_failure
  assert_output <<OUT
ERROR

The following versions contain \`2.7.9' in the name:
  2.7.9-rc1
  2.7.9-rc2

See all available versions with \`pyenv install --list'.

If the version you need is missing, try upgrading pyenv:

  cd ${BATS_TEST_DIRNAME}/../../.. && git pull && cd -
OUT

  unstub python-build
}

@test "homebrew upgrade instructions given when pyenv is homebrew-installed" {
  stub brew "--prefix : echo '${BATS_TEST_DIRNAME%/*}'"
  stub_python_build_lib
  stub_python_build 'echo ERROR >&2 && exit 2' \
    "--definitions : true"

  run pyenv-install 1.9.3
  assert_failure
  assert_output <<OUT
ERROR

See all available versions with \`pyenv install --list'.

If the version you need is missing, try upgrading pyenv:

  brew update && brew upgrade pyenv
OUT

  unstub brew
  unstub python-build
}

@test "no build definitions from plugins" {
  assert [ ! -e "${PYENV_ROOT}/plugins" ]
  stub_python_build_lib
  stub_python_build 'echo $PYTHON_BUILD_DEFINITIONS'

  run pyenv-install 3.4.2
  assert_success ""
  
  unstub python-build
}

@test "some build definitions from plugins" {
  mkdir -p "${PYENV_ROOT}/plugins/foo/share/python-build"
  mkdir -p "${PYENV_ROOT}/plugins/bar/share/python-build"
  stub_python_build_lib
  stub_python_build "echo \$PYTHON_BUILD_DEFINITIONS | tr ':' $'\\n'"

  run pyenv-install 3.4.2
  assert_success
  assert_output <<OUT

${PYENV_ROOT}/plugins/bar/share/python-build
${PYENV_ROOT}/plugins/foo/share/python-build
OUT

  unstub python-build
}

@test "list build definitions from plugins" {
  mkdir -p "${PYENV_ROOT}/plugins/foo/share/python-build"
  mkdir -p "${PYENV_ROOT}/plugins/bar/share/python-build"
  stub_python_build_lib
  stub_python_build "--definitions : echo \$PYTHON_BUILD_DEFINITIONS | tr ':' $'\\n'"

  run pyenv-install --list
  assert_success
  assert_output <<OUT
Available versions:
  
  ${PYENV_ROOT}/plugins/bar/share/python-build
  ${PYENV_ROOT}/plugins/foo/share/python-build
OUT

  unstub python-build
}

@test "completion results include build definitions from plugins" {
  mkdir -p "${PYENV_ROOT}/plugins/foo/share/python-build"
  mkdir -p "${PYENV_ROOT}/plugins/bar/share/python-build"
  stub_python_build "--definitions : echo \$PYTHON_BUILD_DEFINITIONS | tr ':' $'\\n'"

  run pyenv-install --complete
  assert_success
  assert_output <<OUT
--list
--force
--skip-existing
--keep
--patch
--verbose
--version
--debug

${PYENV_ROOT}/plugins/bar/share/python-build
${PYENV_ROOT}/plugins/foo/share/python-build
OUT

  unstub python-build
}

@test "not enough arguments for pyenv-install if no local version" {
  stub_python_build_lib
  stub pyenv-help 'install : true'

  run pyenv-install
  assert_failure
  unstub pyenv-help
  assert_output ""
}

@test "show help for pyenv-install" {
  stub pyenv-help 'install : true'

  run pyenv-install -h
  assert_success
  unstub pyenv-help
}

@test "pyenv-install has usage help preface" {
  run head "$(command -v pyenv-install)"
  assert_output_contains 'Usage: pyenv install'
}

@test "not enough arguments pyenv-uninstall" {
  stub pyenv-help 'uninstall : true'

  run pyenv-uninstall
  assert_failure
  unstub pyenv-help
}

@test "multiple arguments for pyenv-uninstall" {
  mkdir -p "${PYENV_ROOT}/versions/3.4.1"
  mkdir -p "${PYENV_ROOT}/versions/3.4.2"
  run pyenv-uninstall -f 3.4.1 3.4.2

  assert_success
  refute [ -d "${PYENV_ROOT}/versions/3.4.1" ]
  refute [ -d "${PYENV_ROOT}/versions/3.4.2" ]
}

@test "invalid arguments for pyenv-uninstall" {
  mkdir -p "${PYENV_ROOT}/versions/3.10.3"
  mkdir -p "${PYENV_ROOT}/versions/3.10.4"

  run pyenv-uninstall -f 3.10.3 --invalid-option 3.10.4
  assert_failure

  assert [ -d "${PYENV_ROOT}/versions/3.10.3" ]
  assert [ -d "${PYENV_ROOT}/versions/3.10.4" ]

  rmdir "${PYENV_ROOT}/versions/3.10.3"
  rmdir "${PYENV_ROOT}/versions/3.10.4"
}

@test "show help for pyenv-uninstall" {
  stub pyenv-help 'uninstall : true'

  run pyenv-uninstall -h
  assert_success
  unstub pyenv-help
}

@test "pyenv-uninstall has usage help preface" {
  run head "$(command -v pyenv-uninstall)"
  assert_output_contains 'Usage: pyenv uninstall'
}
