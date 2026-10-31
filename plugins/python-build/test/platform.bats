#!/usr/bin/env bats

load test_helper

read_platform() {
  bash -uc 'eval "$(python-build --lib)"
    detect_platform && printf "%s\t%s\t%s\n" "$os" "$arch" "$distro"'
}

@test "platform detection prefers os-release on Linux" {
  [ -r /etc/os-release ] || skip "os-release is not available"
  local expected
  expected="$(. /etc/os-release && printf '%s %s' "${ID:-}" "${VERSION_ID:-}")"
  stub uname '-s : echo Linux' '-m : echo x86_64'
  stub lsb_release

  run read_platform
  assert_success "$(printf 'Linux\tx86_64\t%s' "$expected")"

  unstub uname
  unstub lsb_release
}

@test "platform detection falls back to lsb_release on Linux" {
  [ ! -r /etc/os-release ] || skip "os-release is available"
  stub uname '-s : echo Linux' '-m : echo x86_64'
  stub lsb_release '-si : echo Ubuntu' '-sr : echo 24.04'

  run read_platform
  assert_success $'Linux\tx86_64\tubuntu 24.04'

  unstub uname
  unstub lsb_release
}

@test "platform detection stops when lsb_release cannot identify the distribution" {
  [ ! -r /etc/os-release ] || skip "os-release is available"
  stub uname '-s : echo Linux' '-m : echo x86_64'
  stub lsb_release '-si : echo "distribution query failed" >&2; exit 9'

  run read_platform
  assert_failure "distribution query failed"
  assert_equal 9 "$status"

  unstub uname
  unstub lsb_release
}

@test "platform detection leaves an unknown Linux distribution empty" {
  [ ! -r /etc/os-release ] || skip "os-release is available"
  stub uname '-s : echo Linux' '-m : echo x86_64'

  PATH="$(path_without lsb_release)" run read_platform
  assert_success $'Linux\tx86_64\t'

  unstub uname
}

@test "platform detection uses the full macOS product version" {
  stub uname '-s : echo Darwin' '-m : echo arm64'
  stub sw_vers '-productVersion : echo 15.5.2'

  run read_platform
  assert_success $'Darwin\tarm64\tmacos 15.5.2'

  unstub uname
  unstub sw_vers
}

@test "platform detection uses uname for other systems" {
  stub uname '-s : echo FreeBSD' '-m : echo amd64' '-r : echo 14.2-RELEASE-p3'

  run read_platform
  assert_success $'FreeBSD\tamd64\tfreebsd 14.2-release-p3'

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
