#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${RBENV_TEST_DIR}/myproject"
  cd "${RBENV_TEST_DIR}/myproject"
  echo "1.2.3" > .ruby-version
  mkdir -p "${RBENV_ROOT}/versions/1.2.3"
  run rbenv-prefix
  assert_success "${RBENV_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  RBENV_VERSION="1.2.3" run rbenv-prefix
  assert_failure "rbenv: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${RBENV_TEST_DIR}/bin"
  touch "${RBENV_TEST_DIR}/bin/ruby"
  chmod +x "${RBENV_TEST_DIR}/bin/ruby"
  RBENV_VERSION="system" run rbenv-prefix
  assert_success "$RBENV_TEST_DIR"
}

@test "prefix for invalid system" {
  USRBIN_ALT="${RBENV_TEST_DIR}/usr-bin-alt"
  mkdir -p "$USRBIN_ALT"
  for util in head readlink greadlink; do
    if [ -x "/usr/bin/$util" ]; then
      ln -s "/usr/bin/$util" "${USRBIN_ALT}/$util"
    fi
  done
  PATH_WITHOUT_RUBY="${PATH/\/usr\/bin:/$USRBIN_ALT:}"

  PATH="$PATH_WITHOUT_RUBY" run rbenv-prefix system
  assert_failure "rbenv: system version not found in PATH"
}
