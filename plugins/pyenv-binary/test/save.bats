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

@test "rejects the parent directory reference" {
  run pyenv-binary-save ".."
  assert_failure "pyenv-binary: invalid version name \`..'"
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

# Put an executable on PATH that stands in for a system tool during the test.
stub() {
  local name="$1"
  local dir="${BATS_TEST_TMPDIR}/stubs"
  mkdir -p "$dir"
  { echo "#!/usr/bin/env bash"; cat -; } > "${dir}/${name}"
  chmod +x "${dir}/${name}"
  export PATH="${dir}:$PATH"
}

@test "records only the libraries ldd resolves outside the prefix" {
  create_version "3.12.7"
  touch "${PYENV_ROOT}/versions/3.12.7/bin/python3.12"

  # A realistic ldd listing: the vdso and the loader have no `=>' mapping,
  # libpython resolves inside the prefix, and libc/libm are external.
  stub ldd <<'STUB'
prefix="${PYENV_ROOT}/versions/3.12.7"
cat <<EOF
	linux-vdso.so.1 (0x00007ffd1adfe000)
	libpython3.12.so.1.0 => ${prefix}/lib/libpython3.12.so.1.0 (0x00007f4a3c000000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f4a3bc00000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f4a3b800000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f4a3c200000)
EOF
STUB

  run pyenv-binary-save "3.12.7" "${BATS_TEST_TMPDIR}/dist"
  assert_success

  run grep '^dep=' "${BATS_TEST_TMPDIR}/dist/"*.meta
  assert_output "dep=libc.so.6
dep=libm.so.6"
}

@test "records only the libraries otool resolves outside the prefix" {
  create_version "3.12.7"
  touch "${PYENV_ROOT}/versions/3.12.7/bin/python3.12"

  # Take the macOS path by faking the platform, then feed a realistic otool
  # listing: the first line names the file, @rpath and in-prefix entries are
  # bundled, and libSystem is the one external dependency.
  stub uname <<'STUB'
case "$1" in
  -s) echo Darwin ;;
  -m) echo arm64 ;;
  *) exec /usr/bin/uname "$@" ;;
esac
STUB
  stub otool <<'STUB'
prefix="${PYENV_ROOT}/versions/3.12.7"
cat <<EOF
${2}:
	@rpath/libpython3.12.dylib (compatibility version 3.12.0, current version 3.12.0)
	${prefix}/lib/libcrypto.3.dylib (compatibility version 3.0.0, current version 3.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1345.0.0)
EOF
STUB

  run pyenv-binary-save "3.12.7" "${BATS_TEST_TMPDIR}/dist"
  assert_success

  run grep '^dep=' "${BATS_TEST_TMPDIR}/dist/"*.meta
  assert_output "dep=/usr/lib/libSystem.B.dylib"
}
