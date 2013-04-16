#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${RBENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "empty rehash" {
  assert [ ! -d "${RBENV_ROOT}/shims" ]
  run rbenv-rehash
  assert_success ""
  assert [ -d "${RBENV_ROOT}/shims" ]
  rmdir "${RBENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${RBENV_ROOT}/shims"
  chmod -w "${RBENV_ROOT}/shims"
  run rbenv-rehash
  assert_failure "rbenv: cannot rehash: ${RBENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${RBENV_ROOT}/shims"
  touch "${RBENV_ROOT}/shims/.rbenv-shim"
  run rbenv-rehash
  assert_failure "rbenv: cannot rehash: ${RBENV_ROOT}/shims/.rbenv-shim exists"
}

@test "creates shims" {
  create_executable "1.8" "ruby"
  create_executable "1.8" "rake"
  create_executable "2.0" "ruby"
  create_executable "2.0" "rspec"

  assert [ ! -e "${RBENV_ROOT}/shims/ruby" ]
  assert [ ! -e "${RBENV_ROOT}/shims/rake" ]
  assert [ ! -e "${RBENV_ROOT}/shims/rspec" ]

  run rbenv-rehash
  assert_success ""

  run ls "${RBENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
rake
rspec
ruby
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${RBENV_TEST_DIR}/rbenv.d"
  mkdir -p "${hook_path}/rehash"
  cat > "${hook_path}/rehash/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  RBENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run rbenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}
