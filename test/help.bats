#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run rbenv-help
  assert_success
  assert_line "Usage: rbenv <command> [<args>]"
  assert_line "Some useful rbenv commands are:"
}

@test "invalid command" {
  run rbenv-help hello
  assert_failure "rbenv: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${RBENV_TEST_DIR}/bin"
  cat > "${RBENV_TEST_DIR}/bin/rbenv-hello" <<SH
#!shebang
# Usage: rbenv hello <world>
# Summary: Says "hello" to you, from rbenv
# This command is useful for saying hello.
echo hello
SH

  run rbenv-help hello
  assert_success
  assert_output <<SH
Usage: rbenv hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${RBENV_TEST_DIR}/bin"
  cat > "${RBENV_TEST_DIR}/bin/rbenv-hello" <<SH
#!shebang
# Usage: rbenv hello <world>
# Summary: Says "hello" to you, from rbenv
echo hello
SH

  run rbenv-help hello
  assert_success
  assert_output <<SH
Usage: rbenv hello <world>

Says "hello" to you, from rbenv
SH
}

@test "extracts only usage" {
  mkdir -p "${RBENV_TEST_DIR}/bin"
  cat > "${RBENV_TEST_DIR}/bin/rbenv-hello" <<SH
#!shebang
# Usage: rbenv hello <world>
# Summary: Says "hello" to you, from rbenv
# This extended help won't be shown.
echo hello
SH

  run rbenv-help --usage hello
  assert_success "Usage: rbenv hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${RBENV_TEST_DIR}/bin"
  cat > "${RBENV_TEST_DIR}/bin/rbenv-hello" <<SH
#!shebang
# Usage: rbenv hello <world>
#        rbenv hi [everybody]
#        rbenv hola --translate
# Summary: Says "hello" to you, from rbenv
# Help text.
echo hello
SH

  run rbenv-help hello
  assert_success
  assert_output <<SH
Usage: rbenv hello <world>
       rbenv hi [everybody]
       rbenv hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${RBENV_TEST_DIR}/bin"
  cat > "${RBENV_TEST_DIR}/bin/rbenv-hello" <<SH
#!shebang
# Usage: rbenv hello <world>
# Summary: Says "hello" to you, from rbenv
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run rbenv-help hello
  assert_success
  assert_output <<SH
Usage: rbenv hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
