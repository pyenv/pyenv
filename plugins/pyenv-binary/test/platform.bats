#!/usr/bin/env bats

load test_helper

read_platform() {
  source "${BATS_TEST_DIRNAME}/../share/pyenv-binary/platform.bash"
  printf '%s\t%s\t%s\n' "$os" "$arch" "$distro"
}

@test "platform detection prefers os-release on Linux" {
  [ -r /etc/os-release ] || skip "os-release is not available"
  local expected
  expected="$(. /etc/os-release && printf '%s %s' "$ID" "$VERSION_ID" | tr '[:upper:]' '[:lower:]')"
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'
  create_stub lsb_release 'case "$1" in -si) echo Other;; -sr) echo 0;; esac'

  run read_platform
  assert_success "$(printf 'Linux\tx86_64\t%s' "$expected")"
}

@test "platform detection falls back to lsb_release on Linux" {
  [ ! -r /etc/os-release ] || skip "os-release is available"
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'
  create_stub lsb_release 'case "$1" in -si) echo Ubuntu;; -sr) echo 24.04;; esac'

  run read_platform
  assert_success $'Linux\tx86_64\tubuntu 24.04'
}

@test "platform detection stops when lsb_release cannot identify the distribution" {
  [ ! -r /etc/os-release ] || skip "os-release is available"
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'
  create_stub lsb_release <<'STUB'
case "$1" in
-si ) echo Ubuntu; echo "distribution query failed" >&2; exit 9 ;;
-sr ) touch "$BATS_TEST_TMPDIR/release_queried"; echo 24.04 ;;
esac
STUB

  run bash -e -c 'source "$1"' bash "${BATS_TEST_DIRNAME}/../share/pyenv-binary/platform.bash"
  assert_failure "distribution query failed"
  assert_equal 9 "$status"
  [ ! -e "$BATS_TEST_TMPDIR/release_queried" ]
}

@test "platform detection uses sw_vers on macOS" {
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'
  create_stub sw_vers 'echo 26.7'

  run read_platform
  assert_success $'Darwin\tarm64\tmacos 26.7'
}

@test "platform detection uses uname for other systems" {
  create_stub uname 'case "$1" in -s) echo FreeBSD;; -m) echo amd64;; -r) echo 14.2-RELEASE-p3;; esac'

  run read_platform
  assert_success $'FreeBSD\tamd64\tfreebsd 14.2-release-p3'
}
