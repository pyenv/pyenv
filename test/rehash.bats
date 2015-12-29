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

@test "removes outdated shims" {
  mkdir -p "${RBENV_ROOT}/shims"
  touch "${RBENV_ROOT}/shims/oldshim1"
  chmod +x "${RBENV_ROOT}/shims/oldshim1"

  create_executable "2.0" "rake"
  create_executable "2.0" "ruby"

  run rbenv-rehash
  assert_success ""

  assert [ ! -e "${RBENV_ROOT}/shims/oldshim1" ]
}

@test "do exact matches when removing stale shims" {
  create_executable "2.0" "unicorn_rails"
  create_executable "2.0" "rspec-core"

  rbenv-rehash

  cp "$RBENV_ROOT"/shims/{rspec-core,rspec}
  cp "$RBENV_ROOT"/shims/{rspec-core,rails}
  cp "$RBENV_ROOT"/shims/{rspec-core,uni}
  chmod +x "$RBENV_ROOT"/shims/{rspec,rails,uni}

  run rbenv-rehash
  assert_success ""

  assert [ ! -e "${RBENV_ROOT}/shims/rails" ]
  assert [ ! -e "${RBENV_ROOT}/shims/rake" ]
  assert [ ! -e "${RBENV_ROOT}/shims/uni" ]
}

@test "binary install locations containing spaces" {
  create_executable "dirname1 p247" "ruby"
  create_executable "dirname2 preview1" "rspec"

  assert [ ! -e "${RBENV_ROOT}/shims/ruby" ]
  assert [ ! -e "${RBENV_ROOT}/shims/rspec" ]

  run rbenv-rehash
  assert_success ""

  run ls "${RBENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
rspec
ruby
OUT
}

@test "carries original IFS within hooks" {
  create_hook rehash hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' run rbenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  create_executable "2.0" "ruby"
  RBENV_SHELL=bash run rbenv-sh-rehash
  assert_success "hash -r 2>/dev/null || true"
  assert [ -x "${RBENV_ROOT}/shims/ruby" ]
}

@test "sh-rehash in fish" {
  create_executable "2.0" "ruby"
  RBENV_SHELL=fish run rbenv-sh-rehash
  assert_success ""
  assert [ -x "${RBENV_ROOT}/shims/ruby" ]
}
