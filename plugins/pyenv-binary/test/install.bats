#!/usr/bin/env bats

load test_helper

host_distro() {
  if [ -r /etc/os-release ]; then
    . /etc/os-release
    printf '%s %s' "$ID" "$VERSION_ID" | tr '[:upper:]' '[:lower:]'
  else
    printf '%s %s' "$(lsb_release -si)" "$(lsb_release -sr)" | tr '[:upper:]' '[:lower:]'
  fi
}

use_manifest() {
  local plugin="${BATS_TEST_TMPDIR}/plugin"
  mkdir -p "$plugin/libexec" "$plugin/share/pyenv-binary/versions"
  cp "${BATS_TEST_DIRNAME}/../libexec/pyenv-binary-install" "$plugin/libexec/"
  PATH="$plugin/libexec:$PATH"
  printf 'source_version\tentry\tos\tarch\tdistro\tsha256\n' > "$plugin/share/pyenv-binary/versions/3.14"
  definition_sha="4c4ed1afbfdaa1e4c3bf7bbb82d730cecb7e384da91eea4f3cc093fd545524d6"
}

stub_downloads() {
  create_stub curl <<'STUB'
output=""
while [ "$#" -gt 0 ]; do
  case "$1" in
  -o ) output="$2"; shift ;;
  http* ) url="$1" ;;
  esac
  shift
done
case "$url" in
*/3.14.7-ubuntu-24.04-x86_64 | */3.14.7-macos-15-arm64 | */3.14.10-ubuntu-24.04-x86_64 ) printf definition > "$output" ;;
* ) exit 1 ;;
esac
STUB
}

@test "rejects a modified published definition" {
  create_stub lsb_release 'case "$1" in -si) echo Ubuntu;; -sr) echo 24.04;; esac'
  use_manifest
  printf '3.14.7\t3.14.7-ubuntu-24.04-x86_64\tLinux\tx86_64\t%s\t%064d\n' \
    "$(host_distro)" 0 >> "$BATS_TEST_TMPDIR/plugin/share/pyenv-binary/versions/3.14"
  stub_downloads
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'
  create_stub pyenv-install 'echo installed'

  run pyenv-binary-install 3.14.7
  assert_failure
  [[ "$output" == *'checksum mismatch'* ]]
}

@test "completion does not offer source-only versions" {
  create_stub pyenv-install 'echo 3.14.7'

  run pyenv-binary-install --complete
  assert_success ""
}

@test "installs a matching published binary with an uppercase checksum" {
  create_stub lsb_release 'case "$1" in -si) echo Ubuntu;; -sr) echo 24.04;; esac'
  use_manifest
  local uppercase_sha="$(printf '%s' "$definition_sha" | tr '[:lower:]' '[:upper:]')"
  printf '3.14.7\t3.14.7-macos-15-arm64\tDarwin\tarm64\tmacos 15.7.9\t%s\n' \
    "$definition_sha" >> "$BATS_TEST_TMPDIR/plugin/share/pyenv-binary/versions/3.14"
  printf '3.14.7\t3.14.7-ubuntu-24.04-x86_64\tLinux\tx86_64\t%s\t%s\n' \
    "$(host_distro | tr '[:lower:]' '[:upper:]')" "$uppercase_sha" \
    >> "$BATS_TEST_TMPDIR/plugin/share/pyenv-binary/versions/3.14"
  stub_downloads
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'
  create_stub pyenv-install <<'STUB'
definition="${1%:*}"
printf '%s:%s\n' "${definition##*/}" "${1##*:}"
cat "$definition"
STUB

  run pyenv-binary-install 3.14
  assert_success "3.14.7-ubuntu-24.04-x86_64:3.14.7
definition"
}

@test "a version prefix selects the latest published binary" {
  create_stub lsb_release 'case "$1" in -si) echo Ubuntu;; -sr) echo 24.04;; esac'
  use_manifest
  printf '3.14.10\t3.14.10-ubuntu-24.04-x86_64\tLinux\tx86_64\t%s\t%s\n' \
    "$(host_distro)" "$definition_sha" >> "$BATS_TEST_TMPDIR/plugin/share/pyenv-binary/versions/3.14"
  printf '3.14.7\t3.14.7-ubuntu-24.04-x86_64\tLinux\tx86_64\t%s\t%s\n' \
    "$(host_distro)" "$definition_sha" >> "$BATS_TEST_TMPDIR/plugin/share/pyenv-binary/versions/3.14"
  stub_downloads
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'
  create_stub pyenv-install 'echo "${1##*:}"'

  run pyenv-binary-install 3.14
  assert_success "3.14.10"
}

@test "fails when no published binary matches the host" {
  use_manifest
  printf '3.14.7\t3.14.7-macos-15-arm64\tDarwin\tarm64\tmacos 15.7.9\t%s\n' \
    "$definition_sha" >> "$BATS_TEST_TMPDIR/plugin/share/pyenv-binary/versions/3.14"
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'

  run pyenv-binary-install 3.14.7
  assert_failure "pyenv-binary: no binary available for 3.14.7 on Linux/x86_64"
}

@test "does not select a package for another Linux release" {
  create_stub lsb_release 'case "$1" in -si) echo Ubuntu;; -sr) echo 22.04;; esac'
  use_manifest
  local other_release="ubuntu 24.04"
  [ "$(host_distro)" = "$other_release" ] && other_release="ubuntu 22.04"
  printf '3.14.7\t3.14.7-ubuntu-24.04-x86_64\tLinux\tx86_64\t%s\t%s\n' \
    "$other_release" "$definition_sha" >> "$BATS_TEST_TMPDIR/plugin/share/pyenv-binary/versions/3.14"
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'

  run pyenv-binary-install 3.14.7
  assert_failure "pyenv-binary: no binary available for 3.14.7 on Linux/x86_64"
}

@test "uses a macOS binary built on an older release" {
  use_manifest
  printf '3.14.7\t3.14.7-macos-15-arm64\tDarwin\tarm64\tmacos 15.7.9\t%s\n' \
    "$definition_sha" >> "$BATS_TEST_TMPDIR/plugin/share/pyenv-binary/versions/3.14"
  stub_downloads
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'
  create_stub sw_vers 'echo 26.6.2'
  create_stub pyenv-install 'echo "${1##*:}"'

  run pyenv-binary-install 3.14.7
  assert_success "3.14.7"
}

@test "rejects a macOS binary built on a newer patch release" {
  use_manifest
  printf '3.14.7\t3.14.7-macos-15-arm64\tDarwin\tarm64\tmacos 15.7.9\t%s\n' \
    "$definition_sha" >> "$BATS_TEST_TMPDIR/plugin/share/pyenv-binary/versions/3.14"
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'
  create_stub sw_vers 'echo 15.7.8'
  create_stub pyenv-install 'echo installed'

  run pyenv-binary-install 3.14.7
  assert_failure "pyenv-binary: no binary available for 3.14.7 on Darwin/arm64"
}
