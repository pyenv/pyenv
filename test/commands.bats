#!/usr/bin/env bats

load test_helper

@test "commands" {
  run pyenv-commands
  assert_success
  assert_line "init"
  assert_line "rehash"
  assert_line "shell"
  refute_line "sh-shell"
  assert_line "echo"
}

@test "commands --sh" {
  run pyenv-commands --sh
  assert_success
  refute_line "init"
  assert_line "shell"
}

@test "commands in path with spaces" {
  path="${PYENV_TEST_DIR}/my commands"
  cmd="${path}/pyenv-sh-hello"
  mkdir -p "$path"
  touch "$cmd"
  chmod +x "$cmd"

  PATH="${path}:$PATH" run pyenv-commands --sh
  assert_success
  assert_line "hello"
}

@test "commands --no-sh" {
  run pyenv-commands --no-sh
  assert_success
  assert_line "init"
  refute_line "shell"
}
