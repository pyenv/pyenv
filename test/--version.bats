#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$HOME"
  git config --global user.name  "Tester"
  git config --global user.email "tester@test.local"
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

@test "reads version from git repo" {
  mkdir -p "$PYENV_ROOT"
  cd "$PYENV_ROOT"
  git init
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
  git_commit

  cd "$PYENV_TEST_DIR"
  run pyenv---version
  [[ $output == "pyenv 20"* ]]
}
