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
  create_executable "1.8" "python"
  create_executable "2.0" "rspec"

  PYENV_VERSION=1.8 run pyenv-which python
  assert_success "${PYENV_ROOT}/versions/1.8/bin/python"

  PYENV_VERSION=2.0 run pyenv-which rspec
  assert_success "${PYENV_ROOT}/versions/2.0/bin/rspec"
}

@test "searches PATH for system version" {
  create_executable "${PYENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${PYENV_ROOT}/shims" "kill-all-humans"

  PYENV_VERSION=system run pyenv-which kill-all-humans
  assert_success "${PYENV_TEST_DIR}/bin/kill-all-humans"
}

@test "version not installed" {
  create_executable "2.0" "rspec"
  PYENV_VERSION=1.9 run pyenv-which rspec
  assert_failure "pyenv: version \`1.9' is not installed"
}

@test "no executable found" {
  create_executable "1.8" "rspec"
  PYENV_VERSION=1.8 run pyenv-which rake
  assert_failure "pyenv: rake: command not found"
}

@test "executable found in other versions" {
  create_executable "1.8" "python"
  create_executable "1.9" "rspec"
  create_executable "2.0" "rspec"

  PYENV_VERSION=1.8 run pyenv-which rspec
  assert_failure
  assert_output <<OUT
pyenv: rspec: command not found

The \`rspec' command exists in these Python versions:
  1.9
  2.0
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

  PYENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run pyenv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}
