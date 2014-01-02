#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${PYENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "finds versions where present" {
  create_executable "2.7" "python"
  create_executable "2.7" "fab"
  create_executable "3.4" "python"
  create_executable "3.4" "py.test"

  run pyenv-whence python
  assert_success
  assert_output <<OUT
2.7
3.4
OUT

  run pyenv-whence fab
  assert_success "2.7"

  run pyenv-whence py.test
  assert_success "3.4"
}
