#!/usr/bin/env bats

load test_helper

@test "creates shims and versions directories" {
  assert [ ! -d "${PYENV_ROOT}/shims" ]
  assert [ ! -d "${PYENV_ROOT}/versions" ]
  run pyenv-init -
  assert_success
  assert [ -d "${PYENV_ROOT}/shims" ]
  assert [ -d "${PYENV_ROOT}/versions" ]
}

@test "auto rehash" {
  run pyenv-init -
  assert_success
  assert_line "command pyenv rehash 2>/dev/null"
}

@test "setup shell completions" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run pyenv-init - bash
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/pyenv.bash'"
}

@test "detect parent shell" {
  SHELL=/bin/false run pyenv-init -
  assert_success
  assert_line "export PYENV_SHELL=bash"
}

@test "detect parent shell from script" {
  mkdir -p "$PYENV_TEST_DIR"
  cd "$PYENV_TEST_DIR"
  cat > myscript.sh <<OUT
#!/bin/sh
eval "\$(pyenv-init -)"
echo \$PYENV_SHELL
OUT
  chmod +x myscript.sh
  run ./myscript.sh /bin/zsh
  assert_success "sh"
}

@test "setup shell completions (fish)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run pyenv-init - fish
  assert_success
  assert_line ". '${root}/test/../libexec/../completions/pyenv.fish'"
}

@test "fish instructions" {
  run pyenv-init fish
  assert [ "$status" -eq 1 ]
  assert_line 'status --is-interactive; and source (pyenv init -|psub)'
}

@test "option to skip rehash" {
  run pyenv-init - --no-rehash
  assert_success
  refute_line "pyenv rehash 2>/dev/null"
}

@test "adds shims to PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run pyenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${PYENV_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run pyenv-init - fish
  assert_success
  assert_line 0 "setenv PATH '${PYENV_ROOT}/shims' \$PATH"
}

@test "can add shims to PATH more than once" {
  export PATH="${PYENV_ROOT}/shims:$PATH"
  run pyenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${PYENV_ROOT}'/shims:${PATH}"'
}

@test "can add shims to PATH more than once (fish)" {
  export PATH="${PYENV_ROOT}/shims:$PATH"
  run pyenv-init - fish
  assert_success
  assert_line 0 "setenv PATH '${PYENV_ROOT}/shims' \$PATH"
}

@test "outputs sh-compatible syntax" {
  run pyenv-init - bash
  assert_success
  assert_line '  case "$command" in'

  run pyenv-init - zsh
  assert_success
  assert_line '  case "$command" in'
}

@test "outputs fish-specific syntax (fish)" {
  run pyenv-init - fish
  assert_success
  assert_line '  switch "$command"'
  refute_line '  case "$command" in'
}
