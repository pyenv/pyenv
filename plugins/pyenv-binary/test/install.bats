#!/usr/bin/env bats

load test_helper
load binary_helper

_setup() {
  use_records
  set_platform Linux x86_64 'ubuntu 24.04'
  export TMPDIR="$BATS_TEST_TMPDIR/temp"
  mkdir -p "$TMPDIR"
  create_stub pyenv-latest '[ "$1" = "-f" ] && [ "$2" = "-k" ] && shift 2 && echo "$*"'
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
https://pyenv.github.io/pythons/binaries/3.14.7-ubuntu-24.04-x86_64 ) printf definition > "$output" ;;
* ) exit 1 ;;
esac
STUB
}

@test "completion does not offer source-only versions" {
  create_stub pyenv-install 'echo 3.14.7'

  run pyenv-binary-install --complete
  assert_success ""
}

@test "rejects unsafe names before resolving a version" {
  create_stub pyenv-latest 'touch "$BATS_TEST_TMPDIR/resolved"; exit 1'
  local name
  for name in '' . .. ../3.14.7 $'3.14.7\tother'; do
    run pyenv-binary-install "$name"
    assert_failure "pyenv-binary: invalid version name \`$name'"
  done
  [ ! -e "$BATS_TEST_TMPDIR/resolved" ]
}

@test "rejects a modified published definition before executing it" {
  printf 'ubuntu-24.04-x86_64\t%064d\n' 0 > "$records/3.14.7"
  stub_downloads
  create_stub pyenv-install '[ "$1" = --list ] && exit; touch "$BATS_TEST_TMPDIR/installed"'

  run pyenv-binary-install 3.14.7
  assert_failure "pyenv-binary: checksum mismatch for 3.14.7-ubuntu-24.04-x86_64"
  [ ! -e "$BATS_TEST_TMPDIR/installed" ]
  assert_equal "" "$(find "$TMPDIR" -mindepth 1 -maxdepth 1)"
}

@test "a plugin definition overrides a published binary without its checksum" {
  local entry="3.14.7-ubuntu-24.04-x86_64"
  printf 'ubuntu-24.04-x86_64\t\n' > "$records/3.14.7"
  create_stub curl 'touch "$BATS_TEST_TMPDIR/downloaded"; exit 1'
  PATH="${BATS_TEST_DIRNAME}/../../python-build/bin:$PATH"
  mkdir -p "$PYENV_ROOT/plugins/first/share/python-build" "$PYENV_ROOT/plugins/second/share/python-build"
  printf '%s\n' 'mkdir -p "$PREFIX_PATH"; echo first > "$PREFIX_PATH/marker"' \
    > "$PYENV_ROOT/plugins/first/share/python-build/$entry"
  echo 'exit 1' > "$PYENV_ROOT/plugins/second/share/python-build/$entry"

  run pyenv-binary-install 3.14.7
  assert_success ""
  assert_equal first "$(cat "$PYENV_ROOT/versions/3.14.7/marker")"
  [ ! -e "$BATS_TEST_TMPDIR/downloaded" ]
  assert_equal "" "$(find "$TMPDIR" -mindepth 1 -maxdepth 1 -type d)"
}

@test "an explicit definition path takes precedence over a plugin definition" {
  local entry="3.14.7-ubuntu-24.04-x86_64"
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.7"
  create_stub curl 'touch "$BATS_TEST_TMPDIR/downloaded"; exit 1'
  PATH="${BATS_TEST_DIRNAME}/../../python-build/bin:$PATH"
  export PYTHON_BUILD_DEFINITIONS="$BATS_TEST_TMPDIR/custom definitions"
  mkdir -p "$PYTHON_BUILD_DEFINITIONS" "$PYENV_ROOT/plugins/custom/share/python-build"
  printf '%s\n' 'mkdir -p "$PREFIX_PATH"; echo custom > "$PREFIX_PATH/marker"' \
    > "$PYTHON_BUILD_DEFINITIONS/$entry"
  echo 'exit 1' > "$PYENV_ROOT/plugins/custom/share/python-build/$entry"

  run pyenv-binary-install 3.14.7
  assert_success ""
  assert_equal custom "$(cat "$PYENV_ROOT/versions/3.14.7/marker")"
  [ ! -e "$BATS_TEST_TMPDIR/downloaded" ]
}

@test "installs a matching published binary with an uppercase checksum" {
  local uppercase_sha="$(printf '%s' "$definition_sha" | tr '[:lower:]' '[:upper:]')"
  printf 'ubuntu-24.04-x86_64\t%s\n' "$uppercase_sha" > "$records/3.14.7"
  stub_downloads
  create_stub pyenv-install <<'STUB'
[ "$1" = --list ] && exit
definition="${1%:*}"
printf '%s:%s\n' "${definition##*/}" "${1##*:}"
cat "$definition"
STUB

  run pyenv-binary-install 3.14.7
  assert_success "3.14.7-ubuntu-24.04-x86_64:3.14.7
definition"
  assert_equal "" "$(find "$TMPDIR" -mindepth 1 -maxdepth 1)"
}

@test "a version prefix uses the existing resolver, not the latest published binary" {
  create_stub pyenv-latest '[ "$*" = "-f -k 3.14" ] && echo 3.14.7'
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.7"
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.10"
  stub_downloads
  create_stub pyenv-install '[ "$1" = --list ] && exit; echo "${1##*:}"'

  run pyenv-binary-install 3.14
  assert_success "3.14.7"
}

@test "binary install resolves plugin versions like ordinary install" {
  rm "$BATS_TEST_TMPDIR/stubs/pyenv-latest"
  PATH="${_PYENV_INSTALL_PREFIX}/plugins/python-build/bin:$PATH"
  local definitions="$PYENV_ROOT/plugins/custom/share/python-build"
  mkdir -p "$definitions"
  printf '%s\n' 'mkdir -p "$PREFIX_PATH"; echo source > "$PREFIX_PATH/marker"' \
    > "$definitions/custom-1.0"

  run pyenv-install custom
  assert_success ""
  assert_equal source "$(cat "$PYENV_ROOT/versions/custom-1.0/marker")"
  mv "$PYENV_ROOT/versions/custom-1.0" "$BATS_TEST_TMPDIR/source-install"

  printf 'ubuntu-24.04-x86_64\t%s\n' \
    cff275fca6f9076c33577ef1f9dc33c50e01b57b2ee43570ab494d671bc94c68 > "$records/custom-1.0"
  create_stub curl <<'STUB'
[ "$4" = https://pyenv.github.io/pythons/binaries/custom-1.0-ubuntu-24.04-x86_64 ] || exit 1
printf '%s\n' 'mkdir -p "$PREFIX_PATH"; echo binary > "$PREFIX_PATH/marker"' > "$3"
STUB

  run pyenv-binary-install custom
  assert_success ""
  assert_equal binary "$(cat "$PYENV_ROOT/versions/custom-1.0/marker")"
}

@test "does not fall back to an older binary when the resolved version has none" {
  create_stub pyenv-latest '[ "$*" = "-f -k 3.14" ] && echo 3.14.10'
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.7"

  run pyenv-binary-install 3.14
  assert_failure "pyenv-binary: no binary available for 3.14.10 on Linux/x86_64"
}

@test "a failed definition listing does not download or execute the stock definition" {
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.7"
  create_stub pyenv-install 'echo "listing failed" >&2; exit 1'
  create_stub curl 'touch "$BATS_TEST_TMPDIR/downloaded"; exit 1'

  run pyenv-binary-install 3.14.7
  assert_failure "listing failed"
  [ ! -e "$BATS_TEST_TMPDIR/downloaded" ]
  assert_equal "" "$(find "$TMPDIR" -mindepth 1 -maxdepth 1)"
}

@test "a failed download leaves no temporary definition or installation" {
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.7"
  create_stub pyenv-install '[ "$1" = --list ] && exit; touch "$BATS_TEST_TMPDIR/installed"'
  create_stub curl 'touch "$BATS_TEST_TMPDIR/downloaded"; exit 1'

  run pyenv-binary-install 3.14.7
  assert_failure
  [ -e "$BATS_TEST_TMPDIR/downloaded" ]
  [ ! -e "$BATS_TEST_TMPDIR/installed" ]
  assert_equal "" "$(find "$TMPDIR" -mindepth 1 -maxdepth 1)"
}

@test "an empty stock checksum cannot install a downloaded definition" {
  printf 'ubuntu-24.04-x86_64\t\n' > "$records/3.14.7"
  stub_downloads
  create_stub pyenv-install '[ "$1" = --list ] && exit; touch "$BATS_TEST_TMPDIR/installed"'

  run pyenv-binary-install 3.14.7
  assert_failure "pyenv-binary: checksum mismatch for 3.14.7-ubuntu-24.04-x86_64"
  [ ! -e "$BATS_TEST_TMPDIR/installed" ]
}

@test "stock installation requires a SHA256 tool" {
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.7"
  stub_downloads
  create_stub pyenv-install '[ "$1" = --list ] && exit; touch "$BATS_TEST_TMPDIR/installed"'
  local bin="$BATS_TEST_TMPDIR/bin" command
  mkdir -p "$bin"
  for command in bash tr grep mktemp rm; do
    ln -s "$(command -v "$command")" "$bin/$command"
  done

  run env PATH="$BATS_TEST_TMPDIR/stubs:$BATS_TEST_TMPDIR/plugin/libexec:$bin" pyenv-binary-install 3.14.7
  assert_failure "pyenv-binary: need sha256sum, shasum or openssl to verify 3.14.7-ubuntu-24.04-x86_64"
  [ ! -e "$BATS_TEST_TMPDIR/installed" ]
  assert_equal "" "$(find "$TMPDIR" -mindepth 1 -maxdepth 1)"
}
