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

@test "--add appends to existing local versions by default" {
  mkdir -p "${PYENV_ROOT}/versions/3.11.0" "${PYENV_ROOT}/versions/3.12.0" "${PYENV_ROOT}/versions/3.13.0"
  printf "3.11.0\n3.12.0\n" > .python-version
  run pyenv-local --add 3.13.0
  assert_success ""
  assert_equal "$(cat .python-version)" $'3.11.0\n3.12.0\n3.13.0'
}

@test "--add --append appends multiple versions in order" {
  mkdir -p "${PYENV_ROOT}/versions/3.11.0" "${PYENV_ROOT}/versions/3.12.0" "${PYENV_ROOT}/versions/3.13.0"
  echo "3.11.0" > .python-version
  run pyenv-local --add --append 3.12.0 3.13.0
  assert_success ""
  assert_equal "$(cat .python-version)" $'3.11.0\n3.12.0\n3.13.0'
}

@test "--add --prepend inserts at top and promotes existing version without duplicating" {
  mkdir -p "${PYENV_ROOT}/versions/3.11.0" "${PYENV_ROOT}/versions/3.12.0" "${PYENV_ROOT}/versions/3.13.0"
  printf "3.11.0\n3.12.0\n" > .python-version
  run pyenv-local --add --prepend 3.13.0 3.12.0
  assert_success ""
  assert_equal "$(cat .python-version)" $'3.13.0\n3.12.0\n3.11.0'
}

@test "--add creates .python-version when none exists" {
  mkdir -p "${PYENV_ROOT}/versions/3.12.0"
  assert [ ! -e .python-version ]
  run pyenv-local --add 3.12.0
  assert_success ""
  assert_equal "$(cat .python-version)" "3.12.0"
}

@test "--add suppresses duplicate versions idempotently" {
  mkdir -p "${PYENV_ROOT}/versions/3.11.0" "${PYENV_ROOT}/versions/3.12.0" "${PYENV_ROOT}/versions/3.13.0"
  printf "3.11.0\n3.12.0\n" > .python-version
  run pyenv-local --add 3.12.0 3.13.0 3.13.0
  assert_success ""
  assert_equal "$(cat .python-version)" $'3.11.0\n3.12.0\n3.13.0'
}

@test "--add preserves glob characters in existing .python-version" {
  cd "$BATS_TEST_TMPDIR"
  touch 1.1
  mkdir -p "${PYENV_ROOT}/versions/3.12.0"
  echo "[1-9].?*" > .python-version
  run pyenv-local --add 3.12.0
  assert_success ""
  assert_equal "$(cat .python-version)" $'[1-9].?*\n3.12.0'
}

@test "--add fails on nonexistent version without modifying .python-version" {
  mkdir -p "${PYENV_ROOT}/versions/3.11.0"
  echo "3.11.0" > .python-version
  run pyenv-local --add 3.99.0
  assert_failure "pyenv: version \`3.99.0' not installed"
  assert_equal "$(cat .python-version)" "3.11.0"
}

@test "-f --add and --add -f force nonexistent versions" {
  echo "3.11.0" > .python-version
  run pyenv-local -f --add 3.98.0
  assert_success ""
  assert_equal "$(cat .python-version)" $'3.11.0\n3.98.0'

  run pyenv-local --add -f --prepend 3.99.0
  assert_success ""
  assert_equal "$(cat .python-version)" $'3.99.0\n3.11.0\n3.98.0'
}

@test "rejects invalid flag combinations with usage" {
  mkdir -p "${PYENV_ROOT}/versions/3.12.0"

  run pyenv-local --unset --add 3.12.0
  assert_failure
  assert_line 0 "Usage: pyenv local [-f|--force] [<version> [...]]"

  run pyenv-local --add
  assert_failure
  assert_line 0 "Usage: pyenv local [-f|--force] [<version> [...]]"

  run pyenv-local --append 3.12.0
  assert_failure
  assert_line 0 "Usage: pyenv local [-f|--force] [<version> [...]]"

  run pyenv-local --prepend 3.12.0
  assert_failure
  assert_line 0 "Usage: pyenv local [-f|--force] [<version> [...]]"

  run pyenv-local --add --append --prepend 3.12.0
  assert_failure
  assert_line 0 "Usage: pyenv local [-f|--force] [<version> [...]]"

  run pyenv-local --unset 3.12.0
  assert_failure
  assert_line 0 "Usage: pyenv local [-f|--force] [<version> [...]]"
}

@test "--complete includes --add, --append, --prepend, --force, and --unset" {
  mkdir -p "${PYENV_ROOT}/versions/3.12.0"
  run pyenv-local --complete
  assert_success
  assert_line "--unset"
  assert_line "--add"
  assert_line "--append"
  assert_line "--prepend"
  assert_line "--force"
  assert_line "system"
  assert_line "3.12.0"
}
