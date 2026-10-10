#!/usr/bin/env bats

load test_helper
load binary_helper

_setup() {
  updater="$_PYENV_INSTALL_PREFIX/.github/scripts/update_binary_record.sh"
  records="$BATS_TEST_TMPDIR/binary records"
  entry="3.14.7-ubuntu-24.04-x86_64"
  definition="$BATS_TEST_TMPDIR/$entry"
  definition_sha="4c4ed1afbfdaa1e4c3bf7bbb82d730cecb7e384da91eea4f3cc093fd545524d6"
  mkdir -p "$records"
  printf definition > "$definition"
}

@test "publishing records the definition checksum, not the archive checksum" {
  printf archive > "$definition.tar.xz"
  records="$records/new"

  run bash "$updater" 3.14.7 "$definition" "$records"
  assert_success "$definition_sha"
  assert_equal "ubuntu-24.04-x86_64"$'\t'"$definition_sha" "$(cat "$records/3.14.7")"
  [ ! -e "$records/3.14" ]
}

@test "publishing resolves a prefix before creating the full-name record" {
  use_records
  set_platform Linux x86_64 'ubuntu 24.04'
  PATH="${_PYENV_INSTALL_PREFIX}/plugins/python-build/bin:$PATH"
  export PYTHON_BUILD_ROOT="$BATS_TEST_TMPDIR/python-build"
  mkdir -p "$PYTHON_BUILD_ROOT/share/python-build"
  touch "$PYTHON_BUILD_ROOT/share/python-build/3.14.7"
  create_executable "$BATS_TEST_TMPDIR/bin" pyenv <<'STUB'
case "$1 $2" in
"latest -f" ) shift; exec pyenv-latest "$@" ;;
"binary package-name" ) shift 2; exec pyenv-binary-package-name "$@" ;;
"binary package" )
  [ "$4" = "3.14.7:3.14.7-ubuntu-24.04-x86_64" ] || exit 1
  printf definition > "${4##*:}"
  ;;
* ) exit 1 ;;
esac
STUB
  export VERSION=3.14 GITHUB_WORKSPACE="$BATS_TEST_TMPDIR" GITHUB_ENV="$BATS_TEST_TMPDIR/environment"
  local script="$(awk '
    /^      - name: Build package$/ { build = 1; next }
    build && /^        run: \|$/ { shell = 1; next }
    shell && /^          / { print substr($0, 11); next }
    shell { exit }
  ' "$_PYENV_INSTALL_PREFIX/.github/workflows/publish_binary.yml")"
  cd "$GITHUB_WORKSPACE"

  run bash -e -o pipefail -c "$script"
  assert_success ""
  run cat "$GITHUB_ENV"
  assert_success <<EOF
version=3.14.7
entry=3.14.7-ubuntu-24.04-x86_64
EOF
  source "$GITHUB_ENV"

  run bash "$updater" "$version" "dist/$entry" "$records"
  assert_success "$definition_sha"
  assert_equal "ubuntu-24.04-x86_64"$'\t'"$definition_sha" "$(cat "$records/3.14.7")"
  [ ! -e "$records/3.14" ]
}

@test "publishing a generated macOS package name makes it discoverable" {
  use_records
  create_stub uname 'case "$1" in -s) echo Darwin;; -m) echo arm64;; esac'
  create_stub sw_vers 'echo 15.5'
  create_stub pyenv-latest '[ "$*" = "-f -k 3.14.7" ] && echo 3.14.7'
  entry="$(pyenv-binary-package-name 3.14.7)"
  definition="$BATS_TEST_TMPDIR/$entry"
  printf definition > "$definition"

  run bash "$updater" 3.14.7 "$definition" "$records"
  assert_success "$definition_sha"

  create_stub sw_vers 'echo 15.1'
  run pyenv-binary-find 3.14.7
  assert_success "$(printf '3.14.7\t3.14.7-macos-15-arm64\t%s' "$definition_sha")"
}

@test "publishing adds a target without losing existing targets" {
  printf 'macos-15-arm64\t%064d\n' 0 > "$records/3.14.7"

  run bash "$updater" 3.14.7 "$definition" "$records"
  assert_success "$definition_sha"
  run cat "$records/3.14.7"
  assert_success <<EOF
macos-15-arm64	0000000000000000000000000000000000000000000000000000000000000000
ubuntu-24.04-x86_64	$definition_sha
EOF
}

@test "publishing replaces the matching target without duplicating it" {
  printf 'ubuntu-24.04-x86_64\t%064d\nmacos-15-arm64\t%064d\n' 0 0 > "$records/3.14.7"

  run bash "$updater" 3.14.7 "$definition" "$records"
  assert_success "$definition_sha"
  run cat "$records/3.14.7"
  assert_success <<EOF
ubuntu-24.04-x86_64	$definition_sha
macos-15-arm64	0000000000000000000000000000000000000000000000000000000000000000
EOF
}

@test "publishing an unchanged definition leaves the record unchanged" {
  printf 'ubuntu-24.04-x86_64\t%s\nmacos-15-arm64\t%064d\n' "$definition_sha" 0 > "$records/3.14.7"
  cp "$records/3.14.7" "$BATS_TEST_TMPDIR/before"

  run bash "$updater" 3.14.7 "$definition" "$records"
  assert_success "$definition_sha"
  cmp "$BATS_TEST_TMPDIR/before" "$records/3.14.7"
}

@test "publishing keeps full variant and interpreter names as record keys" {
  local version
  for version in 3.14.7t pypy3.11-7.3.23; do
    printf definition > "$BATS_TEST_TMPDIR/$version-ubuntu-24.04-x86_64"

    run bash "$updater" "$version" "$BATS_TEST_TMPDIR/$version-ubuntu-24.04-x86_64" "$records"
    assert_success "$definition_sha"
    assert_equal "ubuntu-24.04-x86_64"$'\t'"$definition_sha" "$(cat "$records/$version")"
  done
}

@test "publishing rejects unsafe definition names without writing a record" {
  local version
  for version in '' . .. ../3.14.7 $'3.14.7\tother'; do
    run bash "$updater" "$version" "$definition" "$records"
    assert_failure "pyenv-binary: invalid version name \`$version'"
  done
  assert_equal "" "$(ls -A "$records")"
}

@test "publishing requires the build entry to start with the full definition name" {
  run bash "$updater" 3.14 "$definition" "$records"
  assert_failure "pyenv-binary: invalid entry name \`$entry'"
  assert_equal "" "$(ls -A "$records")"
}

@test "publishing rejects empty or unsafe build suffixes" {
  local entry
  for entry in 3.14.7- 3.14.7-.. '3.14.7-ubuntu 24.04-x86_64'; do
    printf definition > "$BATS_TEST_TMPDIR/$entry"

    run bash "$updater" 3.14.7 "$BATS_TEST_TMPDIR/$entry" "$records"
    assert_failure "pyenv-binary: invalid entry name \`$entry'"
  done
  assert_equal "" "$(ls -A "$records")"
}

@test "a missing published definition does not replace an existing record" {
  printf 'ubuntu-24.04-x86_64\t%064d\n' 0 > "$records/3.14.7"
  cp "$records/3.14.7" "$BATS_TEST_TMPDIR/before"
  rm "$definition"

  run bash "$updater" 3.14.7 "$definition" "$records"
  assert_failure
  assert_output_glob "*$definition*"
  cmp "$BATS_TEST_TMPDIR/before" "$records/3.14.7"
  assert_equal 3.14.7 "$(ls -A "$records")"
}

@test "a failed checksum does not replace an existing record" {
  printf 'ubuntu-24.04-x86_64\t%064d\n' 0 > "$records/3.14.7"
  cp "$records/3.14.7" "$BATS_TEST_TMPDIR/before"
  create_stub sha256sum 'echo "checksum failed" >&2; exit 1'

  run bash "$updater" 3.14.7 "$definition" "$records"
  assert_failure "checksum failed"
  cmp "$BATS_TEST_TMPDIR/before" "$records/3.14.7"
  assert_equal 3.14.7 "$(ls -A "$records")"
}

@test "a failed record update leaves the original intact and cleans temporary files" {
  printf 'ubuntu-24.04-x86_64\t%064d\n' 0 > "$records/3.14.7"
  cp "$records/3.14.7" "$BATS_TEST_TMPDIR/before"
  create_stub mv 'echo "record update failed" >&2; exit 1'

  run bash "$updater" 3.14.7 "$definition" "$records"
  assert_failure "record update failed"
  cmp "$BATS_TEST_TMPDIR/before" "$records/3.14.7"
  assert_equal 3.14.7 "$(ls -A "$records")"
}

@test "a failed record rewrite leaves the original intact and cleans temporary files" {
  printf 'ubuntu-24.04-x86_64\t%064d\n' 0 > "$records/3.14.7"
  cp "$records/3.14.7" "$BATS_TEST_TMPDIR/before"
  create_stub awk 'echo "record rewrite failed" >&2; exit 1'

  run bash "$updater" 3.14.7 "$definition" "$records"
  assert_failure "record rewrite failed"
  cmp "$BATS_TEST_TMPDIR/before" "$records/3.14.7"
  assert_equal 3.14.7 "$(ls -A "$records")"
}

@test "publishing requires a checksum tool before writing a record" {
  local bin="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$bin"
  ln -s "$(command -v bash)" "$bin/bash"

  run env PATH="$bin" bash "$updater" 3.14.7 "$definition" "$records"
  assert_failure "pyenv-binary: need sha256sum or shasum to checksum the definition"
  assert_equal "" "$(ls -A "$records")"
}
