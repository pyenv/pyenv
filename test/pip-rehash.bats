#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${PYENV_ROOT}/versions/${PYENV_VERSION}/bin"
  mkdir -p "$bin"
  echo "#!/bin/sh" > "${bin}/$1"
  chmod +x "${bin}/$1"
}

copy_src_pyenvd() {
  mkdir -p "${PYENV_ROOT}"
  cp -r "${BATS_TEST_DIRNAME}/../pyenv.d" "${PYENV_ROOT}"
}

@test "pip-rehash triggered when using 'pip'" {
  export PYENV_VERSION="3.7.14"
  create_executable "example"
  create_executable "pip"
  copy_src_pyenvd
  run command -v example 2> /dev/null
  assert_failure
  run pyenv-exec pip install example
  assert_success
  run command -v example 2> /dev/null
  assert_success
}

@test "pip-rehash triggered when using 'pip3'" {
  export PYENV_VERSION="3.7.14"
  create_executable "example"
  create_executable "pip3"
  copy_src_pyenvd
  run command -v example 2> /dev/null
  assert_failure
  run pyenv-exec pip3 install example
  assert_success
  run command -v example 2> /dev/null
  assert_success
}

@test "pip-rehash triggered when using 'pip3.x'" {
  export PYENV_VERSION="3.7.14"
  create_executable "example"
  create_executable "pip3.7"
  copy_src_pyenvd
  run command -v example 2> /dev/null
  assert_failure
  run pyenv-exec pip3.7 install example
  assert_success
  run command -v example 2> /dev/null
  assert_success
}

@test "pip-rehash triggered when using 'python -m pip install'" {
  export PYENV_VERSION="3.7.14"
  create_executable "example"
  create_executable "python"
  copy_src_pyenvd
  run command -v example 2> /dev/null
  assert_failure
  run pyenv-exec python -m pip install example
  assert_success
  run command -v example 2> /dev/null
  assert_success
}
