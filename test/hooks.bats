#!/usr/bin/env bats

load test_helper

@test "prints usage help given no argument" {
  run rbenv-hooks
  assert_failure "Usage: rbenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${RBENV_TEST_DIR}/rbenv.d"
  path2="${RBENV_TEST_DIR}/etc/rbenv_hooks"
  RBENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  create_hook exec "ahoy.bash"
  create_hook exec "invalid.sh"
  create_hook which "boom.bash"
  RBENV_HOOK_PATH="$path2"
  create_hook exec "bueno.bash"

  RBENV_HOOK_PATH="$path1:$path2" run rbenv-hooks exec
  assert_success
  assert_output <<OUT
${RBENV_TEST_DIR}/rbenv.d/exec/ahoy.bash
${RBENV_TEST_DIR}/rbenv.d/exec/hello.bash
${RBENV_TEST_DIR}/etc/rbenv_hooks/exec/bueno.bash
OUT
}

@test "supports hook paths with spaces" {
  path1="${RBENV_TEST_DIR}/my hooks/rbenv.d"
  path2="${RBENV_TEST_DIR}/etc/rbenv hooks"
  RBENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  RBENV_HOOK_PATH="$path2"
  create_hook exec "ahoy.bash"

  RBENV_HOOK_PATH="$path1:$path2" run rbenv-hooks exec
  assert_success
  assert_output <<OUT
${RBENV_TEST_DIR}/my hooks/rbenv.d/exec/hello.bash
${RBENV_TEST_DIR}/etc/rbenv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  RBENV_HOOK_PATH="${RBENV_TEST_DIR}/rbenv.d"
  create_hook exec "hello.bash"
  mkdir -p "$HOME"

  RBENV_HOOK_PATH="${HOME}/../rbenv.d" run rbenv-hooks exec
  assert_success "${RBENV_TEST_DIR}/rbenv.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${RBENV_TEST_DIR}/rbenv.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"
  touch "${path}/exec/bright.sh"
  ln -s "bright.sh" "${path}/exec/world.bash"

  RBENV_HOOK_PATH="$path" run rbenv-hooks exec
  assert_success
  assert_output <<OUT
${HOME}/hola.bash
${RBENV_TEST_DIR}/rbenv.d/exec/bright.sh
OUT
}
