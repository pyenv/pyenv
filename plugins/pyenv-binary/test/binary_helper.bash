use_records() {
  local plugin="$BATS_TEST_TMPDIR/plugin"
  records="$plugin/share/pyenv-binary/versions"
  mkdir -p "$plugin/libexec" "$records"
  cp "$BATS_TEST_DIRNAME/../libexec/pyenv-binary-"{find,install} "$plugin/libexec/"
  cp "$BATS_TEST_DIRNAME/../share/pyenv-binary/"*.bash "$plugin/share/pyenv-binary/"
  PATH="$BATS_TEST_TMPDIR/stubs:$plugin/libexec:${BATS_TEST_DIRNAME}/../../python-build/bin:$PATH"
  definition_sha="4c4ed1afbfdaa1e4c3bf7bbb82d730cecb7e384da91eea4f3cc093fd545524d6"
}

set_platform() {
  create_stub uname \
    "$(printf 'case "$1" in -s) echo %q;; -m) echo %q;; esac' "$1" "$2")"
  create_stub sw_vers "$(printf 'echo %q' "${3#* }")"
  printf 'ID=%q\nVERSION_ID=%q\n' "${3% *}" "${3##* }" > "$BATS_TEST_TMPDIR/os-release"
  export _PYTHON_BUILD_FAKE_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"
}
