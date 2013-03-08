#!/usr/bin/env bats

load test_helper

create_hook() {
  mkdir -p "$1/$2"
  touch "$1/$2/$3"
}

@test "prints usage help given no argument" {
  run rbenv-hooks
  assert_failure "Usage: rbenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${RBENV_TEST_DIR}/rbenv.d"
  path2="${RBENV_TEST_DIR}/etc/rbenv_hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path1" exec "ahoy.bash"
  create_hook "$path1" exec "invalid.sh"
  create_hook "$path1" which "boom.bash"
  create_hook "$path2" exec "bueno.bash"

  RBENV_HOOK_PATH="$path1:$path2" run rbenv-hooks exec
  assert_success
  assert_line 0 "${RBENV_TEST_DIR}/rbenv.d/exec/ahoy.bash"
  assert_line 1 "${RBENV_TEST_DIR}/rbenv.d/exec/hello.bash"
  assert_line 2 "${RBENV_TEST_DIR}/etc/rbenv_hooks/exec/bueno.bash"
}

@test "resolves relative paths" {
  path="${RBENV_TEST_DIR}/rbenv.d"
  create_hook "$path" exec "hello.bash"
  mkdir -p "$HOME"

  RBENV_HOOK_PATH="${HOME}/../rbenv.d" run rbenv-hooks exec
  assert_success "${RBENV_TEST_DIR}/rbenv.d/exec/hello.bash"
}
