#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$HOME"
  git config --global user.name  "Tester"
  git config --global user.email "tester@test.local"

  mkdir -p "${PYENV_TEST_DIR}/bin"
  cat > "${PYENV_TEST_DIR}/bin/git" <<CMD
#!$BASH
if [[ \$1 == remote && \$PWD != "\$PYENV_TEST_DIR"/* ]]; then
  echo "not allowed" >&2
  exit 1
else
  exec $(which git) "\$@"
fi
CMD
  chmod +x "${PYENV_TEST_DIR}/bin/git"
}

git_commit() {
  git commit --quiet --allow-empty -m "empty"
}

@test "default version" {
  assert [ ! -e "$PYENV_ROOT" ]
  run pyenv---version
  assert_success
  [[ $output == "pyenv 20"* ]]
}

@test "doesn't read version from non-pyenv repo" {
  mkdir -p "$PYENV_ROOT"
  cd "$PYENV_ROOT"
  git init
  git remote add origin https://github.com/homebrew/homebrew.git
  git_commit
  git tag v1.0

  cd "$PYENV_TEST_DIR"
  run pyenv---version
  assert_success
  [[ $output == "pyenv 20"* ]]
}

@test "reads version from git repo" {
  mkdir -p "$PYENV_ROOT"
  cd "$PYENV_ROOT"
  git init
  git remote add origin https://github.com/yyuu/pyenv.git
  git_commit
  git tag v20380119
  git_commit
  git_commit

  cd "$PYENV_TEST_DIR"
  run pyenv---version
  assert_success
  [[ $output == "pyenv 20380119-2-g"* ]]
}

@test "prints default version if no tags in git repo" {
  mkdir -p "$PYENV_ROOT"
  cd "$PYENV_ROOT"
  git init
  git remote add origin https://github.com/yyuu/pyenv.git
  git_commit

  cd "$PYENV_TEST_DIR"
  run pyenv---version
  [[ $output == "pyenv 20"* ]]
}
