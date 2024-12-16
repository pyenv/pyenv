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

@test "doesn't include current directory in PATH search" {
  mkdir -p "$PYENV_TEST_DIR"
  cd "$PYENV_TEST_DIR"
  touch kill-all-humans
  chmod +x kill-all-humans
  PATH="$(path_without "kill-all-humans")" PYENV_VERSION=system run pyenv-which kill-all-humans
  assert_failure "pyenv: kill-all-humans: command not found"
}

@test "version not installed" {
  create_executable "3.4" "py.test"
  PYENV_VERSION=3.3 run pyenv-which py.test
  assert_failure <<OUT
pyenv: version \`3.3' is not installed (set by PYENV_VERSION environment variable)
pyenv: py.test: command not found
   
The \`py.test' command exists in these Python versions:
  3.4

 Note: See 'pyenv help global' for tips on allowing both
       python2 and python3 to be found.
OUT
}

@test "versions not installed" {
  create_executable "3.4" "py.test"
  PYENV_VERSION=2.7:3.3 run pyenv-which py.test
  assert_failure <<OUT
pyenv: version \`2.7' is not installed (set by PYENV_VERSION environment variable)
pyenv: version \`3.3' is not installed (set by PYENV_VERSION environment variable)
pyenv: py.test: command not found
   
The \`py.test' command exists in these Python versions:
  3.4

 Note: See 'pyenv help global' for tips on allowing both
       python2 and python3 to be found.
OUT
}

@test "no executable found" {
  create_executable "2.7" "py.test"
  PYENV_VERSION=2.7 run pyenv-which fab
  assert_failure "pyenv: fab: command not found"
}

@test "no executable found for system version" {
  PATH="$(path_without "rake")" PYENV_VERSION=system run pyenv-which rake
  assert_failure "pyenv: rake: command not found"
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

Note: See 'pyenv help global' for tips on allowing both
      python2 and python3 to be found.
OUT
}

@test "carries original IFS within hooks" {
  create_hook which hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' PYENV_VERSION=system run pyenv-which anything
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

@test "tolerates nonexistent versions from pyenv-version-name" {
  mkdir -p "$PYENV_ROOT"
  cat > "${PYENV_ROOT}/version" <<EOF
2.7
3.4
EOF
  create_executable "3.4" "python"

  mkdir -p "$PYENV_TEST_DIR"
  cd "$PYENV_TEST_DIR"

  PYENV_VERSION= run pyenv-which python
  assert_success "${PYENV_ROOT}/versions/3.4/bin/python"
}

@test "resolves pyenv-latest prefixes" {
  create_executable "3.4.2" "python"
  
  PYENV_VERSION=3.4 run pyenv-which python
  assert_success "${PYENV_ROOT}/versions/3.4.2/bin/python"
}

@test "hooks get resolved version name" {
  create_hook which echo.bash <<!
echo version=\$version
exit
!

  create_executable "3.4.2" "python"

  PYENV_VERSION=3.4 run pyenv-which python
  assert_success "version=3.4.2"
}

@test "skip advice supresses error messages" {
  create_executable "2.7" "python"
  create_executable "3.3" "py.test"
  create_executable "3.4" "py.test"

  PYENV_VERSION=2.7 run pyenv-which py.test --skip-advice
  assert_failure
  assert_output <<OUT
pyenv: py.test: command not found
OUT
}
