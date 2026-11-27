#!/usr/bin/env bats

load test_helper

_setup() {
  mkdir -p "${PYENV_TEST_DIR}/myproject"
  cd "${PYENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.python-version" ]
  run pyenv-local
  assert_failure "pyenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .python-version
  run pyenv-local
  assert_success "1.2.3"
}

@test "version with glob characters is handled correctly" {
  cd "$BATS_TEST_TMPDIR"; touch 1.1
  echo "[1-9].?*" > .python-version
  run pyenv-local
  assert_success "[1-9].?*"
}

@test "discovers version file in parent directory" {
  echo "1.2.3" > .python-version
  mkdir -p "subdir" && cd "subdir"
  run pyenv-local
  assert_success "1.2.3"
}

@test "ignores PYENV_DIR" {
  echo "1.2.3" > .python-version
  mkdir -p "$HOME"
  echo "3.4-home" > "${HOME}/.python-version"
  PYENV_DIR="$HOME" run pyenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3"
  run pyenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .python-version)" = "1.2.3" ]
}

@test "fails to set a nonexistent local version" {
  run pyenv-local 1.2.3
  assert_failure "pyenv: version \`1.2.3' not installed"
  assert [ ! -e .python-version ]
}

@test "sets a nonexistent local version with --force" {
  run pyenv-local -f 1.2.3
  assert_success ""
  assert [ "$(cat .python-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .python-version
  mkdir -p "${PYENV_ROOT}/versions/1.2.3"
  run pyenv-local
  assert_success "1.0-pre"
  run pyenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .python-version)" = "1.2.3" ]
}

@test "unsets local version" {
  touch .python-version
  run pyenv-local --unset
  assert_success ""
  assert [ ! -e .python-version ]
}

@test "adds version to existing local version (appends by default)" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3" "${PYENV_ROOT}/versions/2.3.4"
  echo "1.2.3" > .python-version

  run pyenv-local --add 2.3.4
  assert_success ""
  assert_equal "$(cat .python-version)" $'1.2.3\n2.3.4'
}

@test "adds multiple versions with --add --append" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3" "${PYENV_ROOT}/versions/2.3.4" "${PYENV_ROOT}/versions/3.4.5"
  echo "1.2.3" > .python-version

  run pyenv-local --add --append 2.3.4 3.4.5
  assert_success ""
  assert_equal "$(cat .python-version)" $'1.2.3\n2.3.4\n3.4.5'
}

@test "adds multiple versions with --add --prepend" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3" "${PYENV_ROOT}/versions/2.3.4" "${PYENV_ROOT}/versions/3.4.5"
  echo "1.2.3" > .python-version

  run pyenv-local --add --prepend 2.3.4 3.4.5
  assert_success ""
  assert_equal "$(cat .python-version)" $'2.3.4\n3.4.5\n1.2.3'
}

@test "--add deduplicates existing and repeated versions on append" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3" "${PYENV_ROOT}/versions/2.3.4" "${PYENV_ROOT}/versions/3.4.5"
  printf '%s\n' 1.2.3 2.3.4 > .python-version

  run pyenv-local --add 1.2.3 3.4.5 3.4.5 2.3.4
  assert_success ""
  assert_equal "$(cat .python-version)" $'1.2.3\n2.3.4\n3.4.5'
}

@test "--add --prepend moves an existing version to the front without duplicates" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3" "${PYENV_ROOT}/versions/2.3.4" "${PYENV_ROOT}/versions/3.4.5"
  printf '%s\n' 1.2.3 2.3.4 > .python-version

  run pyenv-local --add --prepend 2.3.4 3.4.5 2.3.4
  assert_success ""
  assert_equal "$(cat .python-version)" $'2.3.4\n3.4.5\n1.2.3'
}

@test "--add creates .python-version when none exists" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3" "${PYENV_ROOT}/versions/2.3.4"
  assert [ ! -e .python-version ]

  run pyenv-local --add 1.2.3 2.3.4
  assert_success ""
  assert_equal "$(cat .python-version)" $'1.2.3\n2.3.4'
}

@test "--add handles an empty or comment-only .python-version" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3"
  printf '# comment\n\n' > .python-version

  run pyenv-local --add 1.2.3
  assert_success ""
  assert_equal "$(cat .python-version)" "1.2.3"
}

@test "--add inherits versions from parent .python-version and writes in current directory" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3" "${PYENV_ROOT}/versions/2.3.4"
  echo "1.2.3" > .python-version
  mkdir -p subdir && cd subdir

  run pyenv-local --add 2.3.4
  assert_success ""
  assert_equal "$(cat .python-version)" $'1.2.3\n2.3.4'
  assert_equal "$(cat ../.python-version)" "1.2.3"
}

@test "--add fails for nonexistent version without modifying .python-version" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3"
  echo "1.2.3" > .python-version

  run pyenv-local --add 9.9.9
  assert_failure "pyenv: version \`9.9.9' not installed"
  assert_equal "$(cat .python-version)" "1.2.3"
}

@test "--add works with -f/--force in any option order" {
  echo "1.0-missing" > .python-version

  run pyenv-local -f --add 2.0-missing
  assert_success ""
  assert_equal "$(cat .python-version)" $'1.0-missing\n2.0-missing'

  run pyenv-local --prepend --add --force 3.0-missing
  assert_success ""
  assert_equal "$(cat .python-version)" $'3.0-missing\n1.0-missing\n2.0-missing'
}

@test "--add handles version names containing glob characters" {
  cd "$BATS_TEST_TMPDIR"
  touch 1.1
  echo "[1-9].?*" > .python-version

  run pyenv-local -f --add "2.[0-9]*"
  assert_success ""
  assert_equal "$(cat .python-version)" $'[1-9].?*\n2.[0-9]*'
}

@test "--add fails when no version is provided" {
  run pyenv-local --add
  assert_failure "pyenv: \`--add' requires at least one version"

  run pyenv-local --add --prepend
  assert_failure "pyenv: \`--add' requires at least one version"
}

@test "--append and --prepend require --add and are mutually exclusive" {
  run pyenv-local --append 1.2.3
  assert_failure "pyenv: \`--append' can only be used with \`--add'"

  run pyenv-local --prepend 1.2.3
  assert_failure "pyenv: \`--prepend' can only be used with \`--add'"

  run pyenv-local --add --append --prepend 1.2.3
  assert_failure "pyenv: cannot specify both \`--append' and \`--prepend'"
}

@test "--add and --unset are mutually exclusive and --unset rejects versions" {
  run pyenv-local --add --unset
  assert_failure "pyenv: cannot specify both \`--add' and \`--unset'"

  run pyenv-local --unset --add 1.2.3
  assert_failure "pyenv: cannot specify both \`--add' and \`--unset'"

  touch .python-version
  run pyenv-local --unset 1.2.3
  assert_failure "pyenv: \`--unset' does not accept version arguments"
  assert [ -e .python-version ]
}

@test "completions include --add, --append, --prepend, --unset" {
  mkdir -p "${PYENV_ROOT}/versions/1.2.3"
  run pyenv-local --complete
  assert_success
  assert_output <<OUT
--add
--append
--prepend
--unset
system
1.2.3
OUT
}
