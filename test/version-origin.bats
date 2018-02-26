#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${RBENV_ROOT}/version" ]
  run rbenv-version-origin
  assert_success "${RBENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$RBENV_ROOT"
  touch "${RBENV_ROOT}/version"
  run rbenv-version-origin
  assert_success "${RBENV_ROOT}/version"
}

@test "detects RBENV_VERSION" {
  RBENV_VERSION=1 run rbenv-version-origin
  assert_success "RBENV_VERSION environment variable"
}

@test "detects local file" {
  echo "system" > .ruby-version
  run rbenv-version-origin
  assert_success "${PWD}/.ruby-version"
}

@test "reports from hook" {
  create_hook version-origin test.bash <<<"RBENV_VERSION_ORIGIN=plugin"

  RBENV_VERSION=1 run rbenv-version-origin
  assert_success "plugin"
}

@test "carries original IFS within hooks" {
  create_hook version-origin hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export RBENV_VERSION=system
  IFS=$' \t\n' run rbenv-version-origin env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "doesn't inherit RBENV_VERSION_ORIGIN from environment" {
  RBENV_VERSION_ORIGIN=ignored run rbenv-version-origin
  assert_success "${RBENV_ROOT}/version"
}
