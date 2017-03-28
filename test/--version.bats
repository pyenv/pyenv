#!/usr/bin/env bats

load test_helper

export GIT_DIR="${PYENV_TEST_DIR}/.git"

setup() {
  mkdir -p "$HOME"
  git config --global user.name  "Tester"
  git config --global user.email "tester@test.local"
  cd "$PYENV_TEST_DIR"
}

git_commit() {
  git commit --quiet --allow-empty -m "empty"
}

@test "default version" {
  assert [ ! -e "$PYENV_ROOT" ]
  run pyenv---version
  assert_success
  [[ $output == "pyenv "?.?.* ]]
}

@test "doesn't read version from non-pyenv repo" {
  git init
  git remote add origin https://github.com/homebrew/homebrew.git
  git_commit
  git tag v1.0

  run pyenv---version
  assert_success
  [[ $output == "pyenv "?.?.* ]]
}

@test "reads version from git repo" {
  git init
  git remote add origin https://github.com/pyenv/pyenv.git
  git_commit
  git tag v0.4.1
  git_commit
  git_commit

  run pyenv---version
  assert_success "pyenv 0.4.1-2-g$(git rev-parse --short HEAD)"
}

@test "prints default version if no tags in git repo" {
  git init
  git remote add origin https://github.com/pyenv/pyenv.git
  git_commit

  run pyenv---version
  [[ $output == "pyenv "?.?.* ]]
}
