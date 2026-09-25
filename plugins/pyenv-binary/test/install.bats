#!/usr/bin/env bats

load test_helper

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
*/index.tsv ) cp "$BATS_TEST_TMPDIR/index.tsv" "$output" ;;
*/3.14.7-ubuntu-24.04-x86_64 | */3.14.7-macos-15-arm64 | */3.14.10-ubuntu-24.04-x86_64 ) printf definition > "$output" ;;
* ) exit 1 ;;
esac
STUB
}

@test "completion does not offer source-only versions" {
  create_stub pyenv-install 'echo 3.14.7'

  run pyenv-binary-install --complete
  assert_success ""
}

@test "installs a matching published binary under the requested version" {
  cat > "${BATS_TEST_TMPDIR}/index.tsv" <<'EOF'
source_version	entry	os	arch	distro
3.14.7	3.14.7-macos-15-arm64	Darwin	arm64	macos 15.7.9
3.14.7	3.14.7-ubuntu-24.04-x86_64	Linux	x86_64	ubuntu 24.04
EOF
  stub_downloads
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'
  create_stub lsb_release 'case "$1" in -si) echo Ubuntu;; -sr) echo 24.04;; esac'
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
  cat > "${BATS_TEST_TMPDIR}/index.tsv" <<'EOF'
source_version	entry	os	arch	distro
3.14.10	3.14.10-ubuntu-24.04-x86_64	Linux	x86_64	ubuntu 24.04
3.14.7	3.14.7-ubuntu-24.04-x86_64	Linux	x86_64	ubuntu 24.04
EOF
  stub_downloads
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'
  create_stub lsb_release 'case "$1" in -si) echo Ubuntu;; -sr) echo 24.04;; esac'
  create_stub pyenv-install 'echo "${1##*:}"'

  run pyenv-binary-install 3.14
  assert_success "3.14.10"
}

@test "fails when no published binary matches the host" {
  cat > "${BATS_TEST_TMPDIR}/index.tsv" <<'EOF'
source_version	entry	os	arch	distro
3.14.7	3.14.7-macos-15-arm64	Darwin	arm64	macos 15.7.9
EOF
  stub_downloads
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'

  run pyenv-binary-install 3.14.7
  assert_failure "pyenv-binary: no binary available for 3.14.7 on Linux/x86_64"
}

@test "does not select a package for another Linux release" {
  cat > "${BATS_TEST_TMPDIR}/index.tsv" <<'EOF'
source_version	entry	os	arch	distro
3.14.7	3.14.7-ubuntu-24.04-x86_64	Linux	x86_64	ubuntu 24.04
EOF
  stub_downloads
  create_stub uname 'case "$1" in -s) echo Linux;; -m) echo x86_64;; esac'
  create_stub lsb_release 'case "$1" in -si) echo Ubuntu;; -sr) echo 22.04;; esac'

  run pyenv-binary-install 3.14.7
  assert_failure "pyenv-binary: no binary available for 3.14.7 on Linux/x86_64"
}

@test "uses a macOS binary built on an older release" {
  cat > "${BATS_TEST_TMPDIR}/index.tsv" <<'EOF'
source_version	entry	os	arch	distro
3.14.7	3.14.7-macos-15-arm64	Darwin	arm64	macos 15.7.9
EOF
  stub_downloads
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'
  create_stub sw_vers 'echo 26.6.2'
  create_stub pyenv-install 'echo "${1##*:}"'

  run pyenv-binary-install 3.14.7
  assert_success "3.14.7"
}

@test "rejects a macOS binary built on a newer patch release" {
  cat > "${BATS_TEST_TMPDIR}/index.tsv" <<'EOF'
source_version	entry	os	arch	distro
3.14.7	3.14.7-macos-15-arm64	Darwin	arm64	macos 15.7.9
EOF
  stub_downloads
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'
  create_stub sw_vers 'echo 15.7.8'
  create_stub pyenv-install 'echo installed'

  run pyenv-binary-install 3.14.7
  assert_failure "pyenv-binary: no binary available for 3.14.7 on Darwin/arm64"
}
