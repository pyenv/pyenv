#!/usr/bin/env bats

load test_helper
load binary_helper

_setup() {
  PATH="${BATS_TEST_TMPDIR}/stubs:${BATS_TEST_DIRNAME}/../../python-build/bin:$PATH"
  use_records
  set_platform Linux x86_64 'ubuntu 24.04'
}

@test "requires one version" {
  create_stub pyenv-help 'echo usage'

  run pyenv-binary-find
  assert_failure "usage"

  run pyenv-binary-find 3.14.7 extra
  assert_failure "usage"
}

@test "rejects names unusable in a path or URL" {
  local name
  for name in '' . .. ../3.14.7 'custom?python' 'custom python' $'3.14.7\tother'; do
    run pyenv-binary-find "$name"
    assert_failure "pyenv-binary: invalid version name \`$name'"
  done
}

@test "prints the package built for the current platform" {
  printf '%s\tother\n' macos-15-arm64 ubuntu-22.04-x86_64 > "$records/3.14.7"
  printf 'ubuntu-24.04-x86_64\tchecksum\n' >> "$records/3.14.7"

  run pyenv-binary-find 3.14.7
  assert_success $'3.14.7-ubuntu-24.04-x86_64\tchecksum'
}

@test "looks up any definition name" {
  local name
  for name in 3.14.7t pypy3.11-7.3.23; do
    printf 'ubuntu-24.04-x86_64\tchecksum\n' > "$records/$name"

    run pyenv-binary-find "$name"
    assert_success "$name-ubuntu-24.04-x86_64"$'\tchecksum'
  done
}

@test "does not resolve a version prefix" {
  create_stub pyenv-latest 'echo 3.14.7'
  printf 'ubuntu-24.04-x86_64\tchecksum\n' > "$records/3.14.7"

  run pyenv-binary-find 3.14
  assert_failure "pyenv-binary: no binary available for 3.14 on Linux/x86_64"
}

@test "fails for a version without a record" {
  run pyenv-binary-find 3.14.7
  assert_failure "pyenv-binary: no binary available for 3.14.7 on Linux/x86_64"
}

@test "fails when no package matches the distribution, release and architecture" {
  printf '%s\tchecksum\n' pop-24.04-x86_64 ubuntu-22.04-x86_64 ubuntu-24.04-aarch64 \
    > "$records/3.14.7"

  run pyenv-binary-find 3.14.7
  assert_failure "pyenv-binary: no binary available for 3.14.7 on Linux/x86_64"
}

@test "matches the macOS major version" {
  set_platform Darwin arm64 'macos 15.7.9'
  printf '%s\tchecksum\n' macos-14-arm64 macos-15-arm64 macos-26-arm64 > "$records/3.14.7"

  run pyenv-binary-find 3.14.7
  assert_success $'3.14.7-macos-15-arm64\tchecksum'
}

@test "fails when the platform cannot be determined" {
  set_platform Linux x86_64 'arch '

  run pyenv-binary-find 3.14.7
  assert_failure "pyenv-binary: could not determine the package platform"
}

@test "does not pass the version to the Python-Build library loader" {
  run pyenv-binary-find --lib
  assert_failure "pyenv-binary: no binary available for --lib on Linux/x86_64"
}
