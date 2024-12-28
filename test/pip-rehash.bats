#!/usr/bin/env bats

# Test the automatic rehashing after doing a pip install.

# Tell test_helper.bash to create an isolated environment.
export ISOLATED_ENVIRONMENT=1
load test_helper

# Run once before all tests.
# Sets up a fresh environment for testing.
setup_file() {
  eval "$(pyenv init -)"
  assert_success

  run pyenv install 3.12.8
  assert_success

  pyenv global 3.12.8
  assert_success

  # Add a dummy executable in case the computer running
  # the tests has black installed in system python.
  echo -e "#!/bin/bash\nexit 1" > "${PYENV_TEST_DIR}/bin/black"
  chmod +x "${PYENV_TEST_DIR}/bin/black"
}

@test "auto rehash on pip install" {
  # 1) Confirm that black is not found yet
  run black --version
  assert_failure
  
  # 2) Install black using pip
  run pip install black
  assert_success

  # 3) Confirm that black is found after install (i.e. rehash happened)
  run black --version
  assert_success

  # 4) Uninstall black using pip
  run pip uninstall black -y
  assert_success

  # 5) Confirm that black is not found after uninstall
  run black --version
  assert_failure
}

@test "auto rehash on pip3 install" {
  run black --version
  assert_failure

  run pip3 install black
  assert_success

  run black --version
  assert_success

  run pip3 uninstall black -y
  assert_success

  run black --version
  assert_failure
}

@test "auto rehash on pip3.12 install" {
  run black --version
  assert_failure

  run pip3.12 install black
  assert_success

  run black --version
  assert_success

  run pip3.12 uninstall black -y
  assert_success

  run black --version
  assert_failure
}

@test "auto rehash on python -m pip install" {
  run black --version
  assert_failure

  run python -m pip install black
  assert_success

  run black --version
  assert_success

  run python -m pip uninstall black -y
  assert_success

  run black --version
  assert_failure
}

@test "auto rehash on python3 -m pip install" {
  run black --version
  assert_failure

  run python3 -m pip install black
  assert_success

  run black --version
  assert_success

  run python3 -m pip uninstall black -y
  assert_success

  run black --version
  assert_failure
}

@test "auto rehash on python3.12 -m pip install" {
  run black --version
  assert_failure

  run python3.12 -m pip install black
  assert_success

  run black --version
  assert_success

  run python3.12 -m pip uninstall black -y
  assert_success

  run black --version
  assert_failure
}
