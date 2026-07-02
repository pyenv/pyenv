#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${PYENV_ROOT}/versions/$1/bin"
}

platform() {
  echo "$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)"
}

@test "fails with no version given" {
  run pyenv-binary-save
  assert_failure "Usage: pyenv binary save <version> [<output-dir>]"
}

@test "fails for a version that is not installed" {
  run pyenv-binary-save 9.9.9
  assert_failure "pyenv-binary: version \`9.9.9' is not installed"
}

@test "rejects a version name containing a slash" {
  run pyenv-binary-save "foo/bar"
  assert_failure "pyenv-binary: invalid version name \`foo/bar'"
}

@test "rejects a version name that walks out of versions/" {
  run pyenv-binary-save "../../etc"
  assert_failure "pyenv-binary: invalid version name \`../../etc'"
}

@test "packages an installed version" {
  create_version "3.12.7"
  local out="${BATS_TEST_TMPDIR}/dist"
  run pyenv-binary-save "3.12.7" "$out"
  assert_success "Saved 3.12.7-$(platform).tar.gz and 3.12.7-$(platform).meta to $out"
  assert [ -f "${out}/3.12.7-$(platform).tar.gz" ]
  assert [ -f "${out}/3.12.7-$(platform).meta" ]
}

@test "records the platform in the metadata" {
  create_version "3.12.7"
  local out="${BATS_TEST_TMPDIR}/dist"
  pyenv-binary-save "3.12.7" "$out" >/dev/null
  run cat "${out}/3.12.7-$(platform).meta"
  assert_success
  assert_output_contains "version=3.12.7"
  assert_output_contains "platform=$(platform)"
  assert_output_contains "archive=3.12.7-$(platform).tar.gz"
}
