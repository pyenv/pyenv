#!/usr/bin/env bats

load test_helper

read_platform() {
  bash -uc 'eval "$(python-build --lib)"
    detect_platform && printf "%s\n" "$os" "$arch" "$distro"'
}

@test "platform detection in macOS" {
  stub uname '-s : echo Darwin' '-m : echo arm64'
  stub sw_vers '-productVersion : echo 15.5.2'

  run read_platform
  assert_success <<!
Darwin
arm64
macos 15.5.2
!

  unstub uname
  unstub sw_vers
}

@test "platform detection prefers os-release in other OSes, takes the rest from uname" {
  cat >"${BATS_TEST_TMPDIR}/os-release" <<!
ID=BolgenOS
VERSION_ID=99.99
!
  export _PYTHON_BUILD_FAKE_OS_RELEASE="${BATS_TEST_TMPDIR}/os-release"
  local expected
  stub uname '-s : echo YetAnotherBSD' '-m : echo hal_9000'
  stub lsb_release

  run read_platform
  assert_success <<!
YetAnotherBSD
hal_9000
bolgenos 99.99
!

  unstub uname
  unstub lsb_release
}

@test "platform detection prefers os-release (integration)" {
  [[ -r /etc/os-release ]] || skip "/etc/os-release is not present"
  local expected
  expected="$(. /etc/os-release && printf '%s %s' "${ID:-}" "${VERSION_ID:-}")"
  stub uname '-s : echo Linux' '-m : echo x86_64'
  stub lsb_release

  run read_platform
  assert_success <<!
Linux
x86_64
$expected
!

  unstub uname
  unstub lsb_release
}

@test "platform detection falls back to lsb_release" {
  export _PYTHON_BUILD_SKIP_OS_RELEASE=1
  stub uname '-s : echo Linux' '-m : echo x86_64'
  stub lsb_release '-si : echo Ubuntu' '-sr : echo 24.04'

  run read_platform
  assert_success <<!
Linux
x86_64
ubuntu 24.04
!

  unstub uname
  unstub lsb_release
}

@test "platform detection falls back to uname -r" {
  export _PYTHON_BUILD_SKIP_OS_RELEASE=1
  stub uname '-s : echo Linux' '-m : echo x86_64' '-r : echo 99.99-whatever'

  PATH=$(path_without lsb_release) run read_platform
  assert_success <<!
Linux
x86_64
linux 99.99-whatever
!

  unstub uname
}

@test "platform detection propagates uname failures" {
  stub uname '-s : echo "OS query failed" >&2; exit 9'

  run read_platform
  assert_failure "OS query failed"
  assert_equal 9 "$status"

  unstub uname
}

@test "platform detection propagates sw_vers failures" {
  stub uname '-s : echo Darwin' '-m : echo arm64'
  stub sw_vers '-productVersion : echo "release query failed" >&2; exit 9'

  run read_platform
  assert_failure "release query failed"
  assert_equal 9 "$status"

  unstub uname
  unstub sw_vers
}
