#!/usr/bin/env bats

load test_helper

_setup() {
  prerequisites="make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev curl git llvm libncurses5-dev \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev \
liblzma-dev libzstd-dev"
}

@test "completion does not install packages" {
  stub apt-get

  PATH="${BATS_TEST_DIRNAME}/../../../libexec:$PATH" \
    run pyenv completions install-prerequisites

  assert_success "--help"
  unstub apt-get
}

@test "supports help" {
  stub pyenv-help 'install-prerequisites : echo "Usage: pyenv install-prerequisites"'

  run pyenv-install-prerequisites --help

  assert_success "Usage: pyenv install-prerequisites"
  unstub pyenv-help
}

@test "rejects arguments" {
  stub pyenv-help 'install-prerequisites : echo "Usage: pyenv install-prerequisites"'

  run pyenv-install-prerequisites unexpected

  assert_failure "Usage: pyenv install-prerequisites"
  unstub pyenv-help
}

@test "installs build prerequisites with apt-get as root" {
  stub id '-u : echo 0'
  stub apt-get \
    'update -q : true' \
    "install -yq ${prerequisites} : true"

  run pyenv-install-prerequisites

  assert_success
  unstub apt-get
  unstub id
}

@test "uses sudo when not running as root" {
  stub id '-u : echo 1000'
  stub apt-get
  stub sudo \
    'apt-get update -q : true' \
    "apt-get install -yq ${prerequisites} : true"

  run pyenv-install-prerequisites

  assert_success
  unstub sudo
  unstub apt-get
  unstub id
}

@test "fails when apt-get is unavailable" {
  PATH="$(path_without apt-get)" run pyenv-install-prerequisites

  assert_failure "pyenv: installing build prerequisites is not supported on this system"
}

@test "fails when sudo is unavailable for an unprivileged user" {
  stub id '-u : echo 1000'
  stub apt-get

  PATH="$(path_without sudo)" run pyenv-install-prerequisites

  assert_failure "pyenv: sudo is required to install build prerequisites"
  unstub apt-get
  unstub id
}
