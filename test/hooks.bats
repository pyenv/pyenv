#!/usr/bin/env bats

load test_helper

@test "prints usage help given no argument" {
  run pyenv-hooks
  assert_failure "Usage: pyenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${PYENV_TEST_DIR}/pyenv.d"
  path2="${PYENV_TEST_DIR}/etc/pyenv_hooks"
  PYENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  create_hook exec "ahoy.bash"
  create_hook exec "invalid.sh"
  create_hook which "boom.bash"
  PYENV_HOOK_PATH="$path2"
  create_hook exec "bueno.bash"

  PYENV_HOOK_PATH="$path1:$path2" run pyenv-hooks exec
  assert_success
  assert_output <<OUT
${PYENV_TEST_DIR}/pyenv.d/exec/ahoy.bash
${PYENV_TEST_DIR}/pyenv.d/exec/hello.bash
${PYENV_TEST_DIR}/etc/pyenv_hooks/exec/bueno.bash
OUT
}

@test "supports hook paths with spaces" {
  path1="${PYENV_TEST_DIR}/my hooks/pyenv.d"
  path2="${PYENV_TEST_DIR}/etc/pyenv hooks"
  PYENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  PYENV_HOOK_PATH="$path2"
  create_hook exec "ahoy.bash"

  PYENV_HOOK_PATH="$path1:$path2" run pyenv-hooks exec
  assert_success
  assert_output <<OUT
${PYENV_TEST_DIR}/my hooks/pyenv.d/exec/hello.bash
${PYENV_TEST_DIR}/etc/pyenv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  PYENV_HOOK_PATH="${PYENV_TEST_DIR}/pyenv.d"
  create_hook exec "hello.bash"
  mkdir -p "$HOME"

  PYENV_HOOK_PATH="${HOME}/../pyenv.d" run pyenv-hooks exec
  assert_success "${PYENV_TEST_DIR}/pyenv.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${PYENV_TEST_DIR}/pyenv.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"
  touch "${path}/exec/bright.sh"
  ln -s "bright.sh" "${path}/exec/world.bash"

  PYENV_HOOK_PATH="$path" run pyenv-hooks exec
  assert_success
  assert_output <<OUT
${HOME}/hola.bash
${PYENV_TEST_DIR}/pyenv.d/exec/bright.sh
OUT
}
