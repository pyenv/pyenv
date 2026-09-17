#!/usr/bin/env bats

load test_helper

@test "link completions use the dispatcher" {
  run pyenv completions link
  assert_success
  assert_output <<OUT
--help
version
OUT
  run pyenv completions link version
  assert_success
  assert_output <<OUT
--help
--dry
--quiet
OUT
}

@test "link requires a version path" {
  run pyenv-link version
  assert_failure "Usage: pyenv link version [--dry] [--quiet] <path> [<name>]"
}

@test "links an installed binary under its plain version name" {
  create_alt_executable_in_version "3.13.14-linux-x86_64" python 'echo linked-python'
  run pyenv-link version "$PYENV_ROOT/versions/3.13.14-linux-x86_64" 3.13.14
  assert_success "Linked new version named 3.13.14"
  assert_equal "3.13.14-linux-x86_64" "$(readlink "$PYENV_ROOT/versions/3.13.14")"
  PYENV_VERSION=3.13.14 run pyenv exec python
  assert_success "linked-python"
}

@test "links external paths containing spaces into a fresh root" {
  mkdir -p "$PYENV_TEST_DIR/external env/bin"
  run pyenv-link version "$PYENV_TEST_DIR/external env" custom
  assert_success "Linked new version named custom"
  assert_equal "$PYENV_TEST_DIR/external env" "$(readlink "$PYENV_ROOT/versions/custom")"
}

@test "refuses a dangling destination link" {
  mkdir -p "$PYENV_ROOT/versions" "$PYENV_TEST_DIR/source"
  ln -s missing "$PYENV_ROOT/versions/dangling"
  run pyenv-link version "$PYENV_TEST_DIR/source" dangling
  assert_failure "Version dangling already exists"
  assert_equal missing "$(readlink "$PYENV_ROOT/versions/dangling")"
}

@test "rejects invalid version names" {
  mkdir -p "$PYENV_TEST_DIR/source"
  for name in ../outside . .. 'foo/bar' 'foo:bar' system; do
    run pyenv-link version "$PYENV_TEST_DIR/source" "$name"
    assert_failure "pyenv-link: invalid version name \`$name'"
    assert [ ! -e "$PYENV_ROOT/outside" ]
  done
  echo "prompt = '../outside'" > "$PYENV_TEST_DIR/source/pyvenv.cfg"
  run pyenv-link version "$PYENV_TEST_DIR/source"
  assert_failure "pyenv-link: invalid version name \`../outside'"
  assert [ ! -e "$PYENV_ROOT/outside" ]
}
