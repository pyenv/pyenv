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

  definition="${TMP}/3.6.2"
  stub pyenv-latest "echo $definition"

  cat > "$definition" <<<"echo python-build"
  run pyenv-install "$definition"

  assert_success
  assert_output <<-OUT
before: ${PYENV_ROOT}/versions/3.6.2
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

  mkdir -p "${PYENV_ROOT}/versions/3.6.2"
  run pyenv-uninstall -f 3.6.2

  assert_success
  assert_output <<-OUT
before: ${PYENV_ROOT}/versions/3.6.2
rm -rf ${PYENV_ROOT}/versions/3.6.2
rehashed
pyenv: 3.6.2 uninstalled
after.
OUT

  refute [ -d "${PYENV_ROOT}/versions/3.6.2" ]
}

@test "pyenv-uninstall hooks with multiple versions" {
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
  stub pyenv-rehash "echo rehashed"

  mkdir -p "${PYENV_ROOT}/versions/3.6.2"
  mkdir -p "${PYENV_ROOT}/versions/3.6.3"
  run pyenv-uninstall -f 3.6.2 3.6.3

  assert_success
  assert_output <<-OUT
before: ${PYENV_ROOT}/versions/3.6.2
rm -rf ${PYENV_ROOT}/versions/3.6.2
rehashed
pyenv: 3.6.2 uninstalled
after.
before: ${PYENV_ROOT}/versions/3.6.3
rm -rf ${PYENV_ROOT}/versions/3.6.3
rehashed
pyenv: 3.6.3 uninstalled
after.
OUT

  refute [ -d "${PYENV_ROOT}/versions/3.6.2" ]
  refute [ -d "${PYENV_ROOT}/versions/3.6.3" ]
}
