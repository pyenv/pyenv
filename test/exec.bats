#!/usr/bin/env bats

load test_helper

@test "fails with invalid version" {
  bats_require_minimum_version 1.5.0
  export PYENV_VERSION="3.4"
  run -127 pyenv-exec nonexistent
  assert_failure <<EOF
pyenv: version \`3.4' is not installed (set by PYENV_VERSION environment variable)
pyenv: nonexistent: command not found
EOF
}

@test "fails with invalid version set from file" {
  bats_require_minimum_version 1.5.0
  mkdir -p "$PYENV_TEST_DIR"
  cd "$PYENV_TEST_DIR"
  echo 2.7 > .python-version
  run -127 pyenv-exec nonexistent
  assert_failure <<EOF
pyenv: version \`2.7' is not installed (set by $PWD/.python-version)
pyenv: nonexistent: command not found
EOF
}

@test "completes with names of executables" {
  export PYENV_VERSION="3.4"
  create_alt_executable "fab"
  create_alt_executable "python"

  pyenv-rehash
  run pyenv-completions exec
  assert_success
  assert_output <<OUT
--help
fab
python
OUT
}

@test "carries original IFS within hooks" {
  create_hook exec hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export PYENV_VERSION=system
  IFS=$' \t\n' run pyenv-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export PYENV_VERSION="3.4"
  create_alt_executable "python" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run pyenv-exec python -w "/path to/python script.rb" -- extra args
  assert_success
  assert_output <<OUT
${PYENV_ROOT}/versions/3.4/bin/python
  -w
  /path to/python script.rb
  --
  extra
  args
OUT
}

@test "sys.executable with system version (#98)" {
  create_path_executable "python3" "echo system"

  system_python="$(python3 </dev/null)"
  assert_equal "${system_python}" "system"

  export PYENV_VERSION="custom"
  create_alt_executable "python3" "echo custom"

  pyenv-rehash

  custom_python="$(pyenv-exec python3)"
  assert_equal "${custom_python}" "custom"
}

@test 'PATH is not modified with system Python' {
  # Create a wrapper executable that verifies PATH.
  create_alt_executable_in_version "custom" "python3" <<!
[[ \$PATH == "\${PYENV_ROOT}/versions/custom/bin:"* ]] \
  || { echo "unexpected:\$PATH"; exit 2;}
!
  pyenv-rehash

  # Path is not modified with system Python.
  create_path_executable "python3" "echo \$PATH"

  pyenv-rehash
  run pyenv-exec python3
  assert_success "$PATH"

  # Path is modified with custom Python.
  PYENV_VERSION=custom run pyenv-exec python3
  assert_success

  # Path is modified with custom:system Python.
  PYENV_VERSION=custom:system run pyenv-exec python3
  assert_success

  # Path is not modified with system:custom Python.
  PYENV_VERSION=system:custom run pyenv-exec python3
  assert_success "$PATH"
}

@test "sets/adds to _PYENV_SHIM_PATHS_{PROGRAM} when _PYENV_SHIM_PATH is set, unsets _PYENV_SHIM_PATH" {
  progname='123;wacky-prog.name ^%$#'
  envvarname="_PYENV_SHIM_PATHS_123_WACKY_PROG_NAME_____"
  create_path_executable "$progname" <<!
echo $envvarname="\$$envvarname"
echo _PYENV_SHIM_PATH="\$_PYENV_SHIM_PATH"
!
  _PYENV_SHIM_PATH=/unusual/shim/location run pyenv-exec "$progname"
  assert_success
  assert_output <<!
$envvarname=/unusual/shim/location
_PYENV_SHIM_PATH=
!

  eval "export ${envvarname}=/another/shim/location"
  _PYENV_SHIM_PATH=/unusual/shim/location run pyenv-exec "$progname"
  assert_success
  assert_output <<!
$envvarname=/unusual/shim/location:/another/shim/location
_PYENV_SHIM_PATH=
!
}
