#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin
  if [[ $1 == */* ]]; then bin="$1"
  else bin="${PYENV_ROOT}/versions/${1}/bin"
  fi
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "outputs path to executable" {
  create_executable "2.7" "python"
  create_executable "3.4" "py.test"

  PYENV_VERSION=2.7 run pyenv-which python
  assert_success "${PYENV_ROOT}/versions/2.7/bin/python"

  PYENV_VERSION=3.4 run pyenv-which py.test
  assert_success "${PYENV_ROOT}/versions/3.4/bin/py.test"

  PYENV_VERSION=3.4:2.7 run pyenv-which py.test
  assert_success "${PYENV_ROOT}/versions/3.4/bin/py.test"
}

@test "searches PATH for system version" {
  create_executable "${PYENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${PYENV_ROOT}/shims" "kill-all-humans"

  PYENV_VERSION=system run pyenv-which kill-all-humans
  assert_success "${PYENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims prepended)" {
  create_executable "${PYENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${PYENV_ROOT}/shims" "kill-all-humans"

  PATH="${PYENV_ROOT}/shims:$PATH" PYENV_VERSION=system run pyenv-which kill-all-humans
  assert_success "${PYENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims appended)" {
  create_executable "${PYENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${PYENV_ROOT}/shims" "kill-all-humans"

  PATH="$PATH:${PYENV_ROOT}/shims" PYENV_VERSION=system run pyenv-which kill-all-humans
  assert_success "${PYENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims spread)" {
  create_executable "${PYENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${PYENV_ROOT}/shims" "kill-all-humans"

  PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/shims:/tmp/non-existent:$PATH:${PYENV_ROOT}/shims" \
    PYENV_VERSION=system run pyenv-which kill-all-humans
  assert_success "${PYENV_TEST_DIR}/bin/kill-all-humans"
}

@test "version not installed" {
  create_executable "3.4" "py.test"
  PYENV_VERSION=3.3 run pyenv-which py.test
  assert_failure "pyenv: version \`3.3' is not installed (set by PYENV_VERSION environment variable)"
}

@test "versions not installed" {
  create_executable "3.4" "py.test"
  PYENV_VERSION=2.7:3.3 run pyenv-which py.test
  assert_failure <<OUT
pyenv: version \`2.7' is not installed (set by PYENV_VERSION environment variable)
pyenv: version \`3.3' is not installed (set by PYENV_VERSION environment variable)
OUT
}

@test "no executable found" {
  create_executable "2.7" "py.test"
  PYENV_VERSION=2.7 run pyenv-which fab
  assert_failure "pyenv: fab: command not found"
}

@test "executable found in other versions" {
  create_executable "2.7" "python"
  create_executable "3.3" "py.test"
  create_executable "3.4" "py.test"

  PYENV_VERSION=2.7 run pyenv-which py.test
  assert_failure
  assert_output <<OUT
pyenv: py.test: command not found

The \`py.test' command exists in these Python versions:
  3.3
  3.4
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${PYENV_TEST_DIR}/pyenv.d"
  mkdir -p "${hook_path}/which"
  cat > "${hook_path}/which/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  PYENV_HOOK_PATH="$hook_path" IFS=$' \t\n' PYENV_VERSION=system run pyenv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "discovers version from pyenv-version-name" {
  mkdir -p "$PYENV_ROOT"
  cat > "${PYENV_ROOT}/version" <<<"3.4"
  create_executable "3.4" "python"

  mkdir -p "$PYENV_TEST_DIR"
  cd "$PYENV_TEST_DIR"

  PYENV_VERSION= run pyenv-which python
  assert_success "${PYENV_ROOT}/versions/3.4/bin/python"
}
