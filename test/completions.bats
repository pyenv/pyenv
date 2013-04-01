#!/usr/bin/env bats

load test_helper

create_command() {
  bin="${RBENV_TEST_DIR}/bin"
  mkdir -p "$bin"
  echo "$2" > "${bin}/$1"
  chmod +x "${bin}/$1"
}

@test "command with no completion support" {
  create_command "rbenv-hello" "#!$BASH
    echo hello"
  run rbenv-completions hello
  assert_success ""
}

@test "command with completion support" {
  create_command "rbenv-hello" "#!$BASH
# provide rbenv completions
if [[ \$1 = --complete ]]; then
  echo hello
else
  exit 1
fi"
  run rbenv-completions hello
  assert_success "hello"
}

@test "forwards extra arguments" {
  create_command "rbenv-hello" "#!$BASH
# provide rbenv completions
if [[ \$1 = --complete ]]; then
  shift 1
  while [[ \$# -gt 0 ]]; do
    echo \$1
    shift 1
  done
else
  exit 1
fi"
  run rbenv-completions hello happy world
  assert_success
  assert_line 0 "happy"
  assert_line 1 "world"
  refute_line 2
}
