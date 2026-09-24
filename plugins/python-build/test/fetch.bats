#!/usr/bin/env bats

load test_helper
_setup() {
  export PYTHON_BUILD_SKIP_MIRROR=1
  export PYTHON_BUILD_CACHE_PATH=
  export PYTHON_BUILD_BUILD_PATH="${BATS_TEST_TMPDIR}/source"
  mkdir -p "${PYTHON_BUILD_BUILD_PATH}"
}

@test "failed download displays error message" {
  stub curl false

  install_fixture definitions/without-checksum
  assert_failure
  assert_output_contains "> http://example.com/packages/package-1.0.0.tar.gz"
  assert_output_contains "error: failed to download package-1.0.0.tar.gz"
}

@test "interactive download progress is logged" {
  command -v script >/dev/null || skip "script is required to allocate a terminal"
  export TMPDIR="$BATS_TEST_TMPDIR"
  stub curl "-q -o * -sSLf --progress-bar http://example.com/* : echo download-progress >&2; cp $FIXTURE_ROOT/\${6##*/} \$3"

  local script_command
  if script -q /dev/null touch "$BATS_TEST_TMPDIR/script-args" </dev/null >/dev/null 2>&1 &&
      [ -e "$BATS_TEST_TMPDIR/script-args" ]; then
    run script -q /dev/null python-build "$FIXTURE_ROOT/definitions/without-checksum" "$INSTALL_ROOT" </dev/null
  elif printf -v script_command '%q ' touch "$BATS_TEST_TMPDIR/script-command" &&
      script -qec "$script_command" /dev/null </dev/null >/dev/null 2>&1 &&
      [ -e "$BATS_TEST_TMPDIR/script-command" ]; then
    printf -v script_command '%q ' python-build "$FIXTURE_ROOT/definitions/without-checksum" "$INSTALL_ROOT"
    run script -qec "$script_command" /dev/null </dev/null
  else
    skip "script cannot run a command in a pseudo-terminal"
  fi
  assert_success
  assert grep -F download-progress "$BATS_TEST_TMPDIR"/python-build.*.log
  unstub curl
}

@test "using aria2c if available" {
  export PYTHON_BUILD_ARIA2_OPTS=
  export -n PYTHON_BUILD_HTTP_CLIENT
  stub aria2c "--allow-overwrite=true --no-conf=true -d * -o * http://example.com/* : cp $FIXTURE_ROOT/\${7##*/} \$6"

  install_fixture definitions/without-checksum
  assert_success
  assert_output <<OUT
Downloading package-1.0.0.tar.gz...
-> http://example.com/packages/package-1.0.0.tar.gz
Installing package-1.0.0...
Installed package-1.0.0 to ${BATS_TEST_TMPDIR}/install
OUT
  unstub aria2c
}

@test "fetching from git repository" {
  stub git "clone --depth 1 --branch master http://example.com/packages/package.git package-dev : mkdir package-dev"

  run_inline_definition <<DEF
install_git "package-dev" "http://example.com/packages/package.git" master copy
DEF
  assert_success
  assert_output <<OUT
Cloning http://example.com/packages/package.git...
Installing package-dev...
Installed package-dev to ${BATS_TEST_TMPDIR}/install
OUT
  unstub git
}

@test "updating existing git repository" {
  mkdir -p "${PYTHON_BUILD_BUILD_PATH}/package-dev"
  stub git \
    "fetch --depth 1 origin +master : true" \
    "checkout -q -B master origin/master : true"

  run_inline_definition <<DEF
install_git "package-dev" "http://example.com/packages/package.git" master copy
DEF
  assert_success
  assert_output <<OUT
Cloning http://example.com/packages/package.git...
Installing package-dev...
Installed package-dev to ${BATS_TEST_TMPDIR}/install
OUT
  unstub git
}
