#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${PYENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$PYENV_TEST_DIR"
  cd "$PYENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${PYENV_ROOT}/versions" ]
  run pyenv-version-name
  assert_success "system"
}

@test "system version is not checked for existence" {
  PYENV_VERSION=system run pyenv-version-name
  assert_success "system"
}

@test "PYENV_VERSION can be overridden by hook" {
  create_version "2.7.11"
  create_version "3.5.1"
  create_hook version-name test.bash <<<"PYENV_VERSION=3.5.1"

  PYENV_VERSION=2.7.11 run pyenv-version-name
  assert_success "3.5.1"
}

@test "carries original IFS within hooks" {
  create_hook version-name hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export PYENV_VERSION=system
  IFS=$' \t\n' run pyenv-version-name env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "PYENV_VERSION has precedence over local" {
  create_version "2.7.11"
  create_version "3.5.1"

  cat > ".python-version" <<<"2.7.11"
  run pyenv-version-name
  assert_success "2.7.11"

  PYENV_VERSION=3.5.1 run pyenv-version-name
  assert_success "3.5.1"
}

@test "local file has precedence over global" {
  create_version "2.7.11"
  create_version "3.5.1"

  cat > "${PYENV_ROOT}/version" <<<"2.7.11"
  run pyenv-version-name
  assert_success "2.7.11"

  cat > ".python-version" <<<"3.5.1"
  run pyenv-version-name
  assert_success "3.5.1"
}

@test "missing version" {
  PYENV_VERSION=1.2 run pyenv-version-name
  assert_failure "pyenv: version \`1.2' is not installed (set by PYENV_VERSION environment variable)"
}

@test "missing version with --force" {
  PYENV_VERSION=1.2 run pyenv-version-name -f
  assert_success "1.2"
}

@test "one missing version (second missing)" {
  create_version "3.5.1"
  PYENV_VERSION="3.5.1:1.2" run pyenv-version-name
  assert_failure
  assert_output <<OUT
pyenv: version \`1.2' is not installed (set by PYENV_VERSION environment variable)
3.5.1
OUT
}

@test "one missing version (first missing)" {
  create_version "3.5.1"
  PYENV_VERSION="1.2:3.5.1" run pyenv-version-name
  assert_failure
  assert_output <<OUT
pyenv: version \`1.2' is not installed (set by PYENV_VERSION environment variable)
3.5.1
OUT
}

pyenv-version-name-without-stderr() {
  pyenv-version-name 2>/dev/null
}

@test "one missing version (without stderr)" {
  create_version "3.5.1"
  PYENV_VERSION="1.2:3.5.1" run pyenv-version-name-without-stderr
  assert_failure
  assert_output <<OUT
3.5.1
OUT
}

@test "version with prefix in name" {
  create_version "2.7.11"
  cat > ".python-version" <<<"python-2.7.11"
  run pyenv-version-name
  assert_success
  assert_output "2.7.11"
}

@test "falls back to pyenv-latest" {
  create_version "2.7.11"
  PYENV_VERSION="2.7" run pyenv-version-name
  assert_success
  assert_output "2.7.11"
}

@test "pyenv-latest fallback with prefix in name" {
  create_version "3.12.6"
  PYENV_VERSION="python-3.12" run pyenv-version-name
  assert_success
  assert_output "3.12.6"
}

@test "pyenv version started by python-" {
  create_version "python-3.12.6"
  PYENV_VERSION="python-3.12.6" run pyenv-version-name
  assert_success
  assert_output "python-3.12.6"
}
