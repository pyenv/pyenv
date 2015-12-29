#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${RBENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${RBENV_ROOT}/versions" ]
  run rbenv-version-name
  assert_success "system"
}

@test "system version is not checked for existance" {
  RBENV_VERSION=system run rbenv-version-name
  assert_success "system"
}

@test "RBENV_VERSION can be overridden by hook" {
  create_version "1.8.7"
  create_version "1.9.3"
  create_hook version-name test.bash <<<"RBENV_VERSION=1.9.3"

  RBENV_VERSION=1.8.7 run rbenv-version-name
  assert_success "1.9.3"
}

@test "carries original IFS within hooks" {
  create_hook version-name hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export RBENV_VERSION=system
  IFS=$' \t\n' run rbenv-version-name env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "RBENV_VERSION has precedence over local" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > ".ruby-version" <<<"1.8.7"
  run rbenv-version-name
  assert_success "1.8.7"

  RBENV_VERSION=1.9.3 run rbenv-version-name
  assert_success "1.9.3"
}

@test "local file has precedence over global" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > "${RBENV_ROOT}/version" <<<"1.8.7"
  run rbenv-version-name
  assert_success "1.8.7"

  cat > ".ruby-version" <<<"1.9.3"
  run rbenv-version-name
  assert_success "1.9.3"
}

@test "missing version" {
  RBENV_VERSION=1.2 run rbenv-version-name
  assert_failure "rbenv: version \`1.2' is not installed (set by RBENV_VERSION environment variable)"
}

@test "version with prefix in name" {
  create_version "1.8.7"
  cat > ".ruby-version" <<<"ruby-1.8.7"
  run rbenv-version-name
  assert_success
  assert_output "1.8.7"
}
