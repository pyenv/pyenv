#!/usr/bin/env bats

load test_helper

@test "shims linked from elsewhere are chained, other programs at the same paths are unaffected (integration)" {
  bats_require_minimum_version 1.5.0
  progname=shimmed_program
  called_progname=another_program
  create_alt_executable_in_version "custom" "$progname" <<!
echo "called from \$0"
pyenv-exec "$called_progname"
!
  pyenv-rehash
  PATH="$(path_without "$progname" "$called_progname")"
  for disguised_shim_path in "$BATS_TEST_TMPDIR/"{weird-location,even/weirder/location}; do
    mkdir -p "$disguised_shim_path"
    ln -s "${PYENV_ROOT}/shims/$progname" "$disguised_shim_path/$progname"
    PATH="$PATH:$disguised_shim_path"
  done
  create_executable "$disguised_shim_path" "$called_progname" <<!
echo "convoluted call success!"
!
  real_path="$BATS_TEST_TMPDIR/real-location"
  mkdir -p "$real_path"
  ln -s "${PYENV_ROOT}/versions/custom/bin/$progname" "$real_path/$progname"
  PATH="$PATH:$real_path"
  
  run "$progname"
  assert_success
  assert_output <<!
called from $real_path/$progname
convoluted call success!
!

  rm "$real_path/$progname"
  run -127 "$progname"
  assert_failure
  assert_line 0 "pyenv: shimmed_program: command not found"
}
