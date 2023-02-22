#!/usr/bin/env bats

load test_helper

bats_bin="${BATS_TEST_DIRNAME}/../bin/python-build"
static_version="$(grep VERSION "$bats_bin" | head -n1 | cut -d'"' -f 2)"

@test "python-build static version" {
  stub git 'echo "ASPLODE" >&2; exit 1'
  run python-build --version
  assert_success "python-build ${static_version}"
  unstub git
}

@test "python-build git version" {
  stub git \
    'remote -v : echo origin https://github.com/pyenv/pyenv.git' \
    "describe --tags HEAD : echo v1984-12-gSHA"
  run python-build --version
  assert_success "python-build 1984-12-gSHA"
  unstub git
}

@test "git describe fails" {
  stub git \
    'remote -v : echo origin https://github.com/pyenv/pyenv.git' \
    "describe --tags HEAD : echo ASPLODE >&2; exit 1"
  run python-build --version
  assert_success "python-build ${static_version}"
  unstub git
}

@test "git remote doesn't match" {
  stub git \
    'remote -v : echo origin https://github.com/Homebrew/homebrew.git'
  run python-build --version
  assert_success "python-build ${static_version}"
}
