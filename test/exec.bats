#!/usr/bin/env bats

load test_helper

@test "supports hook path with spaces" {
  hook_path="${RBENV_TEST_DIR}/custom stuff/rbenv hooks"
  mkdir -p "${hook_path}/exec"
  echo "export HELLO='from hook'" > "${hook_path}/exec/hello.bash"

  export RBENV_VERSION=system
  RBENV_HOOK_PATH="$hook_path" run rbenv-exec env
  assert_success
  assert_line "HELLO=from hook"
}
