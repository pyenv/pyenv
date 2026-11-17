#!/usr/bin/env bats

load test_helper

@test "invocation without 2 arguments prints usage" {
  run pyenv-do
  assert_failure "Usage: pyenv do <version> <command> [arg1 arg2...]"
  run pyenv-do 3.4
  assert_failure "Usage: pyenv do <version> <command> [arg1 arg2...]"
}

@test "runs the command with the given version" {
  create_alt_executable_in_version "3.4" "python" <<SH
echo "\$PYENV_VERSION"
printf "%s\n" "\$@"
SH

  run pyenv-do 3.4 python -c "import sys"
  assert_success
  assert_output <<OUT
3.4
-c
import sys
OUT
}

@test "completes versions, then executables" {
  create_alt_executable_in_version "3.4" "python"
  pyenv-rehash

  run pyenv-completions do
  assert_success
  assert_output <<OUT
--help
system
3.4
OUT

  run pyenv-completions do 3.4
  assert_success
  assert_output <<OUT
--help
--environment
python
OUT
}
