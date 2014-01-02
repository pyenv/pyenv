#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run pyenv-help
  assert_success
  assert_line "Usage: pyenv <command> [<args>]"
  assert_line "Some useful pyenv commands are:"
}

@test "invalid command" {
  run pyenv-help hello
  assert_failure "pyenv: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${PYENV_TEST_DIR}/bin"
  cat > "${PYENV_TEST_DIR}/bin/pyenv-hello" <<SH
#!shebang
# Usage: pyenv hello <world>
# Summary: Says "hello" to you, from pyenv
# This command is useful for saying hello.
echo hello
SH

  run pyenv-help hello
  assert_success
  assert_output <<SH
Usage: pyenv hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${PYENV_TEST_DIR}/bin"
  cat > "${PYENV_TEST_DIR}/bin/pyenv-hello" <<SH
#!shebang
# Usage: pyenv hello <world>
# Summary: Says "hello" to you, from pyenv
echo hello
SH

  run pyenv-help hello
  assert_success
  assert_output <<SH
Usage: pyenv hello <world>

Says "hello" to you, from pyenv
SH
}

@test "extracts only usage" {
  mkdir -p "${PYENV_TEST_DIR}/bin"
  cat > "${PYENV_TEST_DIR}/bin/pyenv-hello" <<SH
#!shebang
# Usage: pyenv hello <world>
# Summary: Says "hello" to you, from pyenv
# This extended help won't be shown.
echo hello
SH

  run pyenv-help --usage hello
  assert_success "Usage: pyenv hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${PYENV_TEST_DIR}/bin"
  cat > "${PYENV_TEST_DIR}/bin/pyenv-hello" <<SH
#!shebang
# Usage: pyenv hello <world>
#        pyenv hi [everybody]
#        pyenv hola --translate
# Summary: Says "hello" to you, from pyenv
# Help text.
echo hello
SH

  run pyenv-help hello
  assert_success
  assert_output <<SH
Usage: pyenv hello <world>
       pyenv hi [everybody]
       pyenv hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${PYENV_TEST_DIR}/bin"
  cat > "${PYENV_TEST_DIR}/bin/pyenv-hello" <<SH
#!shebang
# Usage: pyenv hello <world>
# Summary: Says "hello" to you, from pyenv
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run pyenv-help hello
  assert_success
  assert_output <<SH
Usage: pyenv hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
