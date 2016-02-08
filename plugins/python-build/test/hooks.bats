#!/usr/bin/env bats

load test_helper

setup() {
  export PYENV_ROOT="${TMP}/pyenv"
  export HOOK_PATH="${TMP}/i has hooks"
  mkdir -p "$HOOK_PATH"
}

@test "pyenv-install hooks" {
  cat > "${HOOK_PATH}/install.bash" <<OUT
before_install 'echo before: \$PREFIX'
after_install 'echo after: \$STATUS'
OUT
  stub pyenv-hooks "install : echo '$HOOK_PATH'/install.bash"
  stub pyenv-rehash "echo rehashed"

  definition="${TMP}/3.2.1"
  cat > "$definition" <<<"echo python-build"
  run pyenv-install "$definition"

  assert_success
  assert_output <<-OUT
before: ${PYENV_ROOT}/versions/3.2.1
python-build
after: 0
rehashed
OUT
}

@test "pyenv-uninstall hooks" {
  cat > "${HOOK_PATH}/uninstall.bash" <<OUT
before_uninstall 'echo before: \$PREFIX'
after_uninstall 'echo after.'
rm() {
  echo "rm \$@"
  command rm "\$@"
}
OUT
  stub pyenv-hooks "uninstall : echo '$HOOK_PATH'/uninstall.bash"
  stub pyenv-rehash "echo rehashed"

  mkdir -p "${PYENV_ROOT}/versions/3.2.1"
  run pyenv-uninstall -f 3.2.1

  assert_success
  assert_output <<-OUT
before: ${PYENV_ROOT}/versions/3.2.1
rm -rf ${PYENV_ROOT}/versions/3.2.1
rehashed
after.
OUT

  refute [ -d "${PYENV_ROOT}/versions/3.2.1" ]
}
