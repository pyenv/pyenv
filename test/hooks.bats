#!/usr/bin/env bats

load test_helper

create_hook() {
  mkdir -p "$1/$2"
  touch "$1/$2/$3"
}

@test "prints usage help given no argument" {
  run pyenv-hooks
  assert_failure "Usage: pyenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${PYENV_TEST_DIR}/pyenv.d"
  path2="${PYENV_TEST_DIR}/etc/pyenv_hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path1" exec "ahoy.bash"
  create_hook "$path1" exec "invalid.sh"
  create_hook "$path1" which "boom.bash"
  create_hook "$path2" exec "bueno.bash"

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
  create_hook "$path1" exec "hello.bash"
  create_hook "$path2" exec "ahoy.bash"

  PYENV_HOOK_PATH="$path1:$path2" run pyenv-hooks exec
  assert_success
  assert_output <<OUT
${PYENV_TEST_DIR}/my hooks/pyenv.d/exec/hello.bash
${PYENV_TEST_DIR}/etc/pyenv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  path="${PYENV_TEST_DIR}/pyenv.d"
  create_hook "$path" exec "hello.bash"
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

  PYENV_HOOK_PATH="$path" run pyenv-hooks exec
  assert_success "${HOME}/hola.bash"
}
