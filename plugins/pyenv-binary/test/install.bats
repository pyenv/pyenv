#!/usr/bin/env bats

load test_helper
load binary_helper

_setup() {
  PATH="${BATS_TEST_TMPDIR}/stubs:${BATS_TEST_DIRNAME}/../../python-build/bin:$PATH"
  use_records
  set_platform Linux x86_64 'ubuntu 24.04'
  create_stub pyenv-latest '[ "$1 $2" = "-f -k" ] && echo "$3"'
  # The checksum of the definition that `stub_downloads' serves
  definition_sha="4c4ed1afbfdaa1e4c3bf7bbb82d730cecb7e384da91eea4f3cc093fd545524d6"
}

stub_downloads() {
  create_stub curl <<'STUB'
output=
while [ "$#" -gt 0 ]; do
  case "$1" in
  -o ) output="$2"; shift ;;
  http* ) url="$1" ;;
  esac
  shift
done
case "$url" in
*/3.14.7-ubuntu-24.04-x86_64 ) printf definition > "$output" ;;
* ) exit 1 ;;
esac
STUB
}

@test "rejects a modified published definition" {
  printf 'ubuntu-24.04-x86_64\t%064d\n' 0 > "$records/3.14.7"
  stub_downloads
  create_stub pyenv-install 'echo installed'

  run pyenv-binary-install 3.14.7
  assert_failure "pyenv-binary: checksum mismatch for 3.14.7-ubuntu-24.04-x86_64"
}

@test "completion does not offer source-only versions" {
  create_stub pyenv-install 'echo 3.14.7'

  run pyenv-binary-install --complete
  assert_success ""
}

@test "rejects unsafe version names" {
  local name
  for name in '' . .. ../3.14.7 $'3.14.7\nother'; do
    run pyenv-binary-install "$name"
    assert_failure "pyenv-binary: invalid version name \`$name'"
  done
}

@test "a plugin binary definition overrides a published binary without its checksum" {
  export TMPDIR="$BATS_TEST_TMPDIR/temp"
  mkdir -p "$TMPDIR"
  local entry="3.14.7-ubuntu-24.04-x86_64"
  printf 'ubuntu-24.04-x86_64\t\n' > "$records/3.14.7"
  create_stub curl 'touch "$BATS_TEST_TMPDIR/downloaded"; exit 1'
  mkdir -p "$PYENV_ROOT/plugins/first/share/pyenv-binary/definitions" "$PYENV_ROOT/plugins/second/share/pyenv-binary/definitions"
  printf '%s\n' 'mkdir -p "$PREFIX_PATH"; echo first > "$PREFIX_PATH/marker"' \
    > "$PYENV_ROOT/plugins/first/share/pyenv-binary/definitions/$entry"
  echo 'exit 1' > "$PYENV_ROOT/plugins/second/share/pyenv-binary/definitions/$entry"

  run pyenv-binary-install 3.14.7
  assert_success ""
  assert_equal first "$(cat "$PYENV_ROOT/versions/3.14.7/marker")"
  [ ! -e "$BATS_TEST_TMPDIR/downloaded" ]
  assert_equal "" "$(find "$TMPDIR" -mindepth 1 -maxdepth 1 -type d)"
}

@test "source definition directories do not override a published binary" {
  local entry="3.14.7-ubuntu-24.04-x86_64"
  printf 'ubuntu-24.04-x86_64\t%s\n' \
    cff275fca6f9076c33577ef1f9dc33c50e01b57b2ee43570ab494d671bc94c68 > "$records/3.14.7"
  create_stub curl <<'STUB'
[ "$4" = https://pyenv.github.io/pythons/binaries/3.14.7-ubuntu-24.04-x86_64 ] || exit 1
printf '%s\n' 'mkdir -p "$PREFIX_PATH"; echo binary > "$PREFIX_PATH/marker"' > "$3"
STUB
  export PYTHON_BUILD_DEFINITIONS="$BATS_TEST_TMPDIR/custom definitions"
  mkdir -p "$PYTHON_BUILD_DEFINITIONS" "$PYENV_ROOT/plugins/custom/share/python-build"
  echo 'exit 1' > "$PYTHON_BUILD_DEFINITIONS/$entry"
  echo 'exit 1' > "$PYENV_ROOT/plugins/custom/share/python-build/$entry"

  run pyenv-binary-install 3.14.7
  assert_success ""
  assert_equal binary "$(cat "$PYENV_ROOT/versions/3.14.7/marker")"
}

@test "installs a matching published binary with an uppercase checksum" {
  local uppercase_sha="$(printf '%s' "$definition_sha" | tr '[:lower:]' '[:upper:]')"
  printf 'ubuntu-24.04-x86_64\t%s\n' "$uppercase_sha" > "$records/3.14.7"
  stub_downloads
  create_stub pyenv-install <<'STUB'
definition="${1%:*}"
printf '%s:%s\n' "${definition##*/}" "${1##*:}"
cat "$definition"
STUB

  run pyenv-binary-install 3.14.7
  assert_success "3.14.7-ubuntu-24.04-x86_64:3.14.7
definition"
}

@test "resolves a version prefix before looking up a binary" {
  create_stub pyenv-latest '[ "$*" = "-f -k 3.14" ] && echo 3.14.7'
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.7"
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.10"
  stub_downloads
  create_stub pyenv-install 'echo "${1##*:}"'

  run pyenv-binary-install 3.14
  assert_success "3.14.7"
}

@test "does not fall back to an older binary when the resolved version has none" {
  create_stub pyenv-latest '[ "$*" = "-f -k 3.14" ] && echo 3.14.10'
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.7"

  run pyenv-binary-install 3.14
  assert_failure "pyenv-binary: no binary available for 3.14.10 on Linux/x86_64"
}

@test "a failed source listing does not download or install a binary" {
  rm "$BATS_TEST_TMPDIR/stubs/pyenv-latest"
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.7"
  create_stub pyenv-install 'echo "listing failed" >&2; exit 1'
  create_stub curl 'touch "$BATS_TEST_TMPDIR/downloaded"; exit 1'

  run pyenv-binary-install 3.14.7
  assert_failure "listing failed"
  [ ! -e "$BATS_TEST_TMPDIR/downloaded" ]
}

@test "an empty published checksum is refused before downloading" {
  printf 'ubuntu-24.04-x86_64\t\n' > "$records/3.14.7"
  create_stub curl 'touch "$BATS_TEST_TMPDIR/downloaded"'

  run pyenv-binary-install 3.14.7
  assert_failure "pyenv-binary: invalid checksum for 3.14.7-ubuntu-24.04-x86_64"
  [ ! -e "$BATS_TEST_TMPDIR/downloaded" ]
}

@test "a failed download leaves no temporary files" {
  export TMPDIR="$BATS_TEST_TMPDIR/temp"
  mkdir -p "$TMPDIR"
  printf 'ubuntu-24.04-x86_64\t%s\n' "$definition_sha" > "$records/3.14.7"
  create_stub curl 'exit 1'

  run pyenv-binary-install 3.14.7
  assert_failure
  assert_equal "" "$(find "$TMPDIR" -mindepth 1)"
}
