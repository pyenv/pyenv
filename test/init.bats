#!/usr/bin/env bats

load test_helper

setup() {
  export PATH="${PYENV_TEST_DIR}/bin:$PATH"
}

create_executable() {
  local name="$1"
  local bin="${PYENV_TEST_DIR}/bin"
  mkdir -p "$bin"
  sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

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

@test "auto rehash for --path" {
  run pyenv-init --path
  assert_success
  assert_line "command pyenv rehash 2>/dev/null"
}

@test "setup shell completions" {
  exec_root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run pyenv-init - bash
  assert_success
  assert_line "source '${exec_root}/completions/pyenv.bash'"
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
  run ./myscript.sh
  assert_success "sh"
}

@test "setup shell completions (fish)" {
  exec_root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run pyenv-init - fish
  assert_success
  assert_line "source '${exec_root}/completions/pyenv.fish'"
}

@test "fish instructions" {
  run pyenv-init fish
  assert [ "$status" -eq 1 ]
  assert_line 'pyenv init - fish | source'
}

@test "shell detection for installer" {
  run pyenv-init --detect-shell
  assert_success
  assert_line "PYENV_SHELL_DETECT=bash"
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
  assert_line 'export PATH="'${PYENV_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run pyenv-init - fish
  assert_success
  assert_line "set -gx PATH '${PYENV_ROOT}/shims' \$PATH"
}

@test "removes existing shims from PATH" {
  OLDPATH="$PATH"
  export PATH="${BATS_TEST_DIRNAME}/nonexistent:${PYENV_ROOT}/shims:$PATH"
  run bash -e <<!
eval "\$(pyenv-init -)"
echo "\$PATH"
!
  assert_success
  assert_output "${PYENV_ROOT}/shims:${BATS_TEST_DIRNAME}/nonexistent:${OLDPATH//${PYENV_ROOT}\/shims:/}"
}

@test "removes existing shims from PATH (fish)" {
  command -v fish >/dev/null || skip "-- fish not installed"
  OLDPATH="$PATH"
  export PATH="${BATS_TEST_DIRNAME}/nonexistent:${PYENV_ROOT}/shims:$PATH"
  run fish <<!
set -x PATH "$PATH"
pyenv init - | source
echo "\$PATH"
!
  assert_success
  assert_output "${PYENV_ROOT}/shims:${BATS_TEST_DIRNAME}/nonexistent:${OLDPATH//${PYENV_ROOT}\/shims:/}"
}

@test "adds shims to PATH with --no-push-path if they're not on PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run bash -e <<!
eval "\$(pyenv-init - --no-push-path)"
echo "\$PATH"
!
  assert_success
  assert_output "${PYENV_ROOT}/shims:${PATH}"
}

@test "adds shims to PATH with --no-push-path if they're not on PATH (fish)" {
  command -v fish >/dev/null || skip "-- fish not installed"
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run fish <<!
set -x PATH "$PATH"
pyenv-init - --no-push-path| source
echo "\$PATH"
!
  assert_success
  assert_output "${PYENV_ROOT}/shims:${PATH}"
}

@test "doesn't change PATH with --no-push-path if shims are already on PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:${PYENV_ROOT}/shims:/usr/bin:/bin:/usr/local/bin"
  run bash -e <<!
eval "\$(pyenv-init - --no-push-path)"
echo "\$PATH"
!
  assert_success
  assert_output "${PATH}"
}

@test "doesn't change PATH with --no-push-path if shims are already on PATH (fish)" {
  command -v fish >/dev/null || skip "-- fish not installed"
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:${PYENV_ROOT}/shims:/bin:/usr/local/bin"
  run fish <<!
set -x PATH "$PATH"
pyenv-init - --no-push-path| source
echo "\$PATH"
!
  assert_success
  assert_output "${PATH}"
}

@test "outputs sh-compatible syntax" {
  run pyenv-init - bash
  assert_success
  assert_line '  case "$command" in'

  run pyenv-init - zsh
  assert_success
  assert_line '  case "$command" in'
}

@test "outputs sh-compatible case syntax" {
  create_executable pyenv-commands <<!
#!$BASH
echo -e 'activate\ndeactivate\nrehash\nshell'
!
  run pyenv-init - bash
  assert_success
  assert_line '  activate|deactivate|rehash|shell)'

  create_executable pyenv-commands <<!
#!$BASH
echo
!
  run pyenv-init - bash
  assert_success
  assert_line '  /)'
}

@test "outputs fish-specific syntax (fish)" {
  run pyenv-init - fish
  assert_success
  assert_line '  switch "$command"'
  refute_line '  case "$command" in'
}
