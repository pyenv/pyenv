#!/usr/bin/env bats

load test_helper
_setup() {
  export PYTHON_BUILD_SKIP_MIRROR=1
  export PYTHON_BUILD_CACHE_PATH=
  export PYTHON_BUILD_BUILD_PATH="${BATS_TEST_TMPDIR}/source"
  mkdir -p "${PYTHON_BUILD_BUILD_PATH}"
}

check_script_available() {
  command -v script >/dev/null || skip "'script' not installed"
}

run_with_script() {
  local command
  # `script' outputs CRLF because ttys do so under the hood
  # https://unix.stackexchange.com/questions/343324/why-in-the-output-of-script-1-the-newline-is-cr-lf-dos-style
  case "$(uname -s)" in
    Linux) printf -v command '%q ' "$@"; script -qec "$command" /dev/stdout | tr -d $'\r' ;;
    *) script -q /dev/stdout "$@" | tr -d $'\r' ;;
  esac </dev/null
  return ${PIPESTATUS[0]}
}

@test "failed download displays error message" {
  stub curl false

  install_fixture definitions/without-checksum
  assert_failure
  assert_output_contains "> http://example.com/packages/package-1.0.0.tar.gz"
  assert_output_contains "error: failed to download package-1.0.0.tar.gz"
}

@test "interactive download progress is both shown and logged" {
  check_script_available
  export TMPDIR="$BATS_TEST_TMPDIR"
  stub curl '** -o * ** --no-silent ** http://example.com/* : "'"$BASH"'" -ec '\''echo download-progress >&2; "$FIXTURE_ROOT/fake_downloader" "$@"'\'' "$@"'

  run run_with_script python-build "$FIXTURE_ROOT/definitions/without-checksum" "$INSTALL_ROOT"
  assert_success
  unstub curl

  assert_line download-progress

  run cat "$BATS_TEST_TMPDIR"/python-build.*.log
  assert_success
  assert_line download-progress
}

@test "using aria2c if available" {
  export PYTHON_BUILD_ARIA2_OPTS=
  export -n PYTHON_BUILD_HTTP_CLIENT
  stub aria2c ': "$FIXTURE_ROOT/fake_downloader" aria2c "$@"'
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

@test "interactive aria2c output is emulated by printing summaries" {
  check_script_available
  export TMPDIR="$BATS_TEST_TMPDIR"
  export PYTHON_BUILD_ARIA2_OPTS=
  export -n PYTHON_BUILD_HTTP_CLIENT
  stub aria2c '** --summary-interval=* ** http://example.com/* : "'"$BASH"'" -ec '\''echo download-progress; "$FIXTURE_ROOT/fake_downloader" aria2c "$@"'\'' "$@"'

  run run_with_script python-build "$FIXTURE_ROOT/definitions/without-checksum" "$INSTALL_ROOT"
  assert_success
  unstub aria2c
  assert_line download-progress

  run cat "$BATS_TEST_TMPDIR"/python-build.*.log
  assert_success
  assert_line download-progress
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

@test "verifying git ref against a sha1 (not an annotated tag) (match)" {
  stub git "clone --depth 1 --branch some_tag http://example.com/packages/package.git package-release : mkdir package-release"
  stub git "describe --exact-match : false"
  stub git "rev-parse HEAD : $BASH -ec '[[ \${PWD##*/} == package-release ]]; echo good_sha1'"

  run_inline_definition <<DEF
install_git "package-release" "http://example.com/packages/package.git" some_tag:good_sha1 copy
DEF
  assert_success
  unstub git
}

@test "verifying git ref against a sha1 (not an annotated tag) (no match)" {
  stub git "clone --depth 1 --branch some_tag http://example.com/packages/package.git package-release : mkdir package-release"
  stub git "describe --exact-match : false"
  stub git "rev-parse HEAD : $BASH -ec '[[ \${PWD##*/} == package-release ]]; echo bad_sha1'"
  stub git true

  run_inline_definition <<DEF
install_git "package-release" "http://example.com/packages/package.git" some_tag:good_sha1 copy
DEF
  assert_failure
  assert_line \
"error: ref \`some_tag' SHA-1 mismatch: expected good_sha1, got bad_sha1"
  unstub git
}

@test "verifying git ref against a sha1 (annotated tag, passing tag sha, other tags present) (success)" {
  stub git "clone --depth 1 --branch annotated_tag http://example.com/packages/package.git package-release : mkdir package-release"
  stub git "describe --exact-match : $BASH -ec '[[ \${PWD##*/} == package-release ]]; printf \"%s\\n\" annotated_tag other_tag'"
  stub git "rev-parse annotated_tag : $BASH -ec '[[ \${PWD##*/} == package-release ]]; echo tag_sha1'"
  stub git "rev-parse HEAD : $BASH -ec '[[ \${PWD##*/} == package-release ]]; echo commit_sha1'"

  run_inline_definition <<DEF
install_git "package-release" "http://example.com/packages/package.git" annotated_tag:tag_sha1 copy
DEF
  assert_success
  unstub git
}

@test "verifying git ref against a sha1 (annotated tag, passing commit sha) (success)" {
  stub git "clone --depth 1 --branch annotated_tag http://example.com/packages/package.git package-release : mkdir package-release"
  stub git "describe --exact-match : $BASH -ec '[[ \${PWD##*/} == package-release ]]; echo annotated_tag'"
  stub git "rev-parse annotated_tag : $BASH -ec '[[ \${PWD##*/} == package-release ]]; echo good_tag_sha1'"
  stub git "rev-parse HEAD : $BASH -ec '[[ \${PWD##*/} == package-release ]]; echo commit_sha1'"

  run_inline_definition <<DEF
install_git "package-release" "http://example.com/packages/package.git" annotated_tag:commit_sha1 copy
DEF
  assert_success
  unstub git
}

@test "verifying git ref against a sha1 (annotated tag) (no match)" {
  stub git "clone --depth 1 --branch annotated_tag http://example.com/packages/package.git package-release : mkdir package-release"
  stub git "describe --exact-match : $BASH -ec '[[ \${PWD##*/} == package-release ]]; echo annotated_tag'"
  stub git "rev-parse annotated_tag : $BASH -ec '[[ \${PWD##*/} == package-release ]]; echo bad_tag_sha1'"
  stub git "rev-parse HEAD : $BASH -ec '[[ \${PWD##*/} == package-release ]]; echo bad_commit_sha1'"
  stub git true

  run_inline_definition <<DEF
install_git "package-release" "http://example.com/packages/package.git" annotated_tag:good_sha1 copy
DEF
  assert_failure
  assert_line \
"error: ref \`annotated_tag' SHA-1 mismatch: expected good_sha1, got bad_commit_sha1(commit) and bad_tag_sha1(tag)"
  unstub git
}

@test "verifying git ref against a sha1 (unrelated tag matches commit)" {
  stub git "clone --depth 1 --branch some_tag http://example.com/packages/package.git package-release : mkdir package-release"
  stub git "describe --exact-match : $BASH -ec '[[ \${PWD##*/} == package-release ]]; echo other_tag'"
  stub git "rev-parse HEAD : $BASH -ec '[[ \${PWD##*/} == package-release ]]; echo commit_sha1'"

  run_inline_definition <<DEF
install_git "package-release" "http://example.com/packages/package.git" some_tag:commit_sha1 copy
DEF
  assert_success
  unstub git
}
