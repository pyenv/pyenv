#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$HOME"
  git config --global user.name  "Tester"
  git config --global user.email "tester@test.local"

  mkdir -p "${RBENV_TEST_DIR}/bin"
  cat > "${RBENV_TEST_DIR}/bin/git" <<CMD
#!$BASH
if [[ \$1 == remote && \$PWD != "\$RBENV_TEST_DIR"/* ]]; then
  echo "not allowed" >&2
  exit 1
else
  exec $(which git) "\$@"
fi
CMD
  chmod +x "${RBENV_TEST_DIR}/bin/git"
}

git_commit() {
  git commit --quiet --allow-empty -m "empty"
}

@test "default version" {
  assert [ ! -e "$RBENV_ROOT" ]
  run rbenv---version
  assert_success
  [[ $output == "rbenv 0."* ]]
}

@test "doesn't read version from non-rbenv repo" {
  mkdir -p "$RBENV_ROOT"
  cd "$RBENV_ROOT"
  git init
  git remote add origin https://github.com/homebrew/homebrew.git
  git_commit
  git tag v1.0

  cd "$RBENV_TEST_DIR"
  run rbenv---version
  assert_success
  [[ $output == "rbenv 0."* ]]
}

@test "reads version from git repo" {
  mkdir -p "$RBENV_ROOT"
  cd "$RBENV_ROOT"
  git init
  git remote add origin https://github.com/sstephenson/rbenv.git
  git_commit
  git tag v0.4.1
  git_commit
  git_commit

  cd "$RBENV_TEST_DIR"
  run rbenv---version
  assert_success
  [[ $output == "rbenv 0.4.1-2-g"* ]]
}

@test "prints default version if no tags in git repo" {
  mkdir -p "$RBENV_ROOT"
  cd "$RBENV_ROOT"
  git init
  git remote add origin https://github.com/sstephenson/rbenv.git
  git_commit

  cd "$RBENV_TEST_DIR"
  run rbenv---version
  [[ $output == "rbenv 0."* ]]
}
