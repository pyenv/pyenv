#!/usr/bin/env bats

load test_helper
load binary_helper

_setup() {
  use_records
  set_platform Linux x86_64 'ubuntu 24.04'
}

@test "find completion does not list source definitions" {
  run pyenv-binary-find --complete
  assert_success ""
}

@test "find requires one definition name" {
  create_stub pyenv-help 'echo usage'

  run pyenv-binary-find
  assert_failure "usage"

  run pyenv-binary-find 3.14.7 extra
  assert_failure "usage"
}

@test "find rejects unsafe definition names" {
  local name
  for name in '' . .. ../3.14.7 $'3.14.7\tother' 'custom?python' 'custom python'; do
    run pyenv-binary-find "$name"
    assert_failure "pyenv-binary: invalid version name \`$name'"
  done
}

@test "find reads an exact record without resolving, downloading or installing" {
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.7"
  create_stub pyenv-latest 'touch "$BATS_TEST_TMPDIR/resolved"; exit 1'
  create_stub curl 'touch "$BATS_TEST_TMPDIR/downloaded"; exit 1'
  create_stub pyenv-install 'touch "$BATS_TEST_TMPDIR/installed"; exit 1'
  create_stub mktemp 'touch "$BATS_TEST_TMPDIR/allocated"; exit 1'

  run pyenv-binary-find 3.14.7
  assert_success "$(printf '3.14.7\t3.14.7-ubuntu-24.04-x86_64\t%s' "$definition_sha")"
  [ ! -e "$BATS_TEST_TMPDIR/resolved" ]
  [ ! -e "$BATS_TEST_TMPDIR/downloaded" ]
  [ ! -e "$BATS_TEST_TMPDIR/installed" ]
  [ ! -e "$BATS_TEST_TMPDIR/allocated" ]
}

@test "find does not treat an exact name as a version prefix" {
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.7"

  run pyenv-binary-find 3.14
  assert_failure "pyenv-binary: no binary available for 3.14 on Linux/x86_64"
}

@test "find supports full variant and interpreter definition names" {
  local name
  for name in 3.14.7t pypy3.11-7.3.23 jython-2.7.4; do
    printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/$name"

    run pyenv-binary-find "$name"
    assert_success "$(printf '%s\t%s-ubuntu-24.04-x86_64\t%s' "$name" "$name" "$definition_sha")"
  done
}

@test "find reports an absent definition even when another one has a binary" {
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.7"

  run pyenv-binary-find 3.14.10
  assert_failure "pyenv-binary: no binary available for 3.14.10 on Linux/x86_64"
}

@test "find picks the matching target rather than the first row" {
  printf 'macos-15-arm64\t%064d\nubuntu-24.04-x86_64\t%s\nubuntu-22.04-x86_64\t%064d\n' \
    0 "$definition_sha" 0 > "$records/3.14.7"

  run pyenv-binary-find 3.14.7
  assert_success "$(printf '3.14.7\t3.14.7-ubuntu-24.04-x86_64\t%s' "$definition_sha")"
}

@test "find does not select a different Linux distribution or release" {
  printf 'debian-12-x86_64\t%s\nubuntu-22.04-x86_64\t%s\n' \
    "$definition_sha" "$definition_sha" > "$records/3.14.7"

  run pyenv-binary-find 3.14.7
  assert_failure "pyenv-binary: no binary available for 3.14.7 on Linux/x86_64"
}

@test "find does not select a different architecture" {
  printf 'ubuntu-24.04-aarch64\t%s\n' "$definition_sha" > "$records/3.14.7"

  run pyenv-binary-find 3.14.7
  assert_failure "pyenv-binary: no binary available for 3.14.7 on Linux/x86_64"
}

@test "find matches the macOS major version, not the build host patch" {
  set_platform Darwin arm64 'macos 15.1'
  printf 'macos-14-arm64\t%064d\nmacos-15-arm64\t%s\nmacos-26-arm64\t%064d\n' \
    0 "$definition_sha" 0 > "$records/3.14.7"

  run pyenv-binary-find 3.14.7
  assert_success "$(printf '3.14.7\t3.14.7-macos-15-arm64\t%s' "$definition_sha")"
}

@test "find does not select an older macOS major version" {
  set_platform Darwin arm64 'macos 26.6.2'
  printf 'macos-15-arm64\t%s\n' "$definition_sha" > "$records/3.14.7"

  run pyenv-binary-find 3.14.7
  assert_failure "pyenv-binary: no binary available for 3.14.7 on Darwin/arm64"
}

@test "find reports unsupported platforms as unavailable" {
  set_platform FreeBSD amd64 'freebsd 14.2-release-p3'
  printf 'freebsd-14.2-release-p3-amd64\t%s\n' "$definition_sha" > "$records/3.14.7"

  run pyenv-binary-find 3.14.7
  assert_failure "pyenv-binary: no binary available for 3.14.7 on FreeBSD/amd64"
}

@test "find reports a Linux distribution without a release as unavailable" {
  set_platform Linux x86_64 'arch '

  run pyenv-binary-find 3.14.7
  assert_failure "pyenv-binary: no binary available for 3.14.7 on Linux/x86_64"

  printf 'arch--x86_64\t%s\n' "$definition_sha" > "$records/3.14.7"
  run pyenv-binary-find 3.14.7
  assert_failure "pyenv-binary: no binary available for 3.14.7 on Linux/x86_64"
}

@test "find rejects duplicate matching targets" {
  printf 'ubuntu-24.04-x86_64\t%s\nubuntu-24.04-x86_64\t%s\n' \
    "$definition_sha" "$definition_sha" > "$records/3.14.7"

  run pyenv-binary-find 3.14.7
  assert_failure "pyenv-binary: multiple binaries available for 3.14.7 on Linux/x86_64"
}

@test "find rejects malformed rows and unsafe build suffixes" {
  local row
  for row in ubuntu-24.04-x86_64 $'ubuntu-24.04-x86_64\tchecksum\textra' \
    $'../ubuntu-24.04-x86_64\tchecksum' $'ubuntu?24.04-x86_64\tchecksum'; do
    printf '%s\n' "$row" > "$records/3.14.7"

    run pyenv-binary-find 3.14.7
    assert_failure "pyenv-binary: invalid binary record for 3.14.7"
  done
}

@test "find leaves stock checksum validation to the installer" {
  printf 'ubuntu-24.04-x86_64\t\n' > "$records/3.14.7"

  run pyenv-binary-find 3.14.7
  assert_success $'3.14.7\t3.14.7-ubuntu-24.04-x86_64\t'
}

@test "find rejects a URL-unsafe definition name even when its record is valid" {
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/custom?python"

  run pyenv-binary-find 'custom?python'
  assert_failure "pyenv-binary: invalid version name \`custom?python'"
}

@test "find reads the last row without a trailing newline" {
  printf 'ubuntu-24.04-x86_64\t%s' "$definition_sha" > "$records/3.14.7"

  run pyenv-binary-find 3.14.7
  assert_success "$(printf '3.14.7\t3.14.7-ubuntu-24.04-x86_64\t%s' "$definition_sha")"
}
