#!/usr/bin/env bats

load test_helper

@test "creates shims and versions directories" {
  assert [ ! -d "${RBENV_ROOT}/shims" ]
  assert [ ! -d "${RBENV_ROOT}/versions" ]
  run rbenv-init -
  assert_success
  assert [ -d "${RBENV_ROOT}/shims" ]
  assert [ -d "${RBENV_ROOT}/versions" ]
}

@test "auto rehash" {
  run rbenv-init -
  assert_success
  assert_line "rbenv rehash 2>/dev/null"
}

@test "setup shell completions" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run rbenv-init - bash
  assert_success
  assert_line "source '${root}/libexec/../completions/rbenv.bash'"
}

@test "detect parent shell" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  SHELL=/bin/false run rbenv-init -
  assert_success
  assert_line "export RBENV_SHELL=bash"
}

@test "setup shell completions (fish)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run rbenv-init - fish
  assert_success
  assert_line ". '${root}/libexec/../completions/rbenv.fish'"
}

@test "fish instructions" {
  run rbenv-init fish
  assert [ "$status" -eq 1 ]
  assert_line 'status --is-interactive; and . (rbenv init -|psub)'
}

@test "option to skip rehash" {
  run rbenv-init - --no-rehash
  assert_success
  refute_line "rbenv rehash 2>/dev/null"
}

@test "adds shims to PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin"
  run rbenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${RBENV_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin"
  run rbenv-init - fish
  assert_success
  assert_line 0 "setenv PATH '${RBENV_ROOT}/shims' \$PATH"
}

@test "doesn't add shims to PATH more than once" {
  export PATH="${RBENV_ROOT}/shims:$PATH"
  run rbenv-init - bash
  assert_success
  refute_line 'export PATH="'${RBENV_ROOT}'/shims:${PATH}"'
}

@test "doesn't add shims to PATH more than once (fish)" {
  export PATH="${RBENV_ROOT}/shims:$PATH"
  run rbenv-init - fish
  assert_success
  refute_line 'setenv PATH "'${RBENV_ROOT}'/shims" $PATH ;'
}
