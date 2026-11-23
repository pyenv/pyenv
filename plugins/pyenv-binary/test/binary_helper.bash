use_records() {
  records="$BATS_TEST_TMPDIR/versions"
  mkdir -p "$records"
  export _PYENV_BINARY_VERSIONS_DIR="$records"
}

# set_platform <uname -s> <uname -m> "<distribution> <release>"
set_platform() {
  create_stub uname \
    "$(printf 'case "$1" in -s) echo %q;; -m) echo %q;; esac' "$1" "$2")"
  create_stub sw_vers "$(printf 'echo %q' "${3##* }")"
  printf 'ID=%q\nVERSION_ID=%q\n' "${3% *}" "${3##* }" > "$BATS_TEST_TMPDIR/os-release"
  export _PYTHON_BUILD_FAKE_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"
}
