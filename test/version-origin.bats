#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$PYENV_TEST_DIR"
  cd "$PYENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${PYENV_ROOT}/version" ]
  run pyenv-version-origin
  assert_success "${PYENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$PYENV_ROOT"
  touch "${PYENV_ROOT}/version"
  run pyenv-version-origin
  assert_success "${PYENV_ROOT}/version"
}

@test "detects PYENV_VERSION" {
  PYENV_VERSION=1 run pyenv-version-origin
  assert_success "PYENV_VERSION environment variable"
}

@test "detects local file" {
  echo "system" > .python-version
  run pyenv-version-origin
  assert_success "${PWD}/.python-version"
}

@test "reports from hook" {
  create_hook version-origin test.bash <<<"PYENV_VERSION_ORIGIN=plugin"

  PYENV_VERSION=1 run pyenv-version-origin
  assert_success "plugin"
}

@test "carries original IFS within hooks" {
  create_hook version-origin hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export PYENV_VERSION=system
  IFS=$' \t\n' run pyenv-version-origin env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "doesn't inherit PYENV_VERSION_ORIGIN from environment" {
  PYENV_VERSION_ORIGIN=ignored run pyenv-version-origin
  assert_success "${PYENV_ROOT}/version"
}
