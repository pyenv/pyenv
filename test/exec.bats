#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${PYENV_ROOT}/versions/${PYENV_VERSION}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "fails with invalid version" {
  export PYENV_VERSION="3.4"
  run pyenv-exec python -v
  assert_failure "pyenv: version \`3.4' is not installed (set by PYENV_VERSION environment variable)"
}

@test "completes with names of executables" {
  export PYENV_VERSION="3.4"
  create_executable "fab" "#!/bin/sh"
  create_executable "python" "#!/bin/sh"

  pyenv-rehash
  run pyenv-completions exec
  assert_success
  assert_output <<OUT
fab
python
OUT
}

@test "supports hook path with spaces" {
  hook_path="${PYENV_TEST_DIR}/custom stuff/pyenv hooks"
  mkdir -p "${hook_path}/exec"
  echo "export HELLO='from hook'" > "${hook_path}/exec/hello.bash"

  export PYENV_VERSION=system
  PYENV_HOOK_PATH="$hook_path" run pyenv-exec env
  assert_success
  assert_line "HELLO=from hook"
}

@test "carries original IFS within hooks" {
  hook_path="${PYENV_TEST_DIR}/pyenv.d"
  mkdir -p "${hook_path}/exec"
  cat > "${hook_path}/exec/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export PYENV_VERSION=system
  PYENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run pyenv-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export PYENV_VERSION="3.4"
  create_executable "python" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run pyenv-exec python -w "/path to/python script.rb" -- extra args
  assert_success
  assert_output <<OUT
${PYENV_ROOT}/versions/3.4/bin/python
  -w
  /path to/python script.rb
  --
  extra
  args
OUT
}

@test "supports python -S <cmd>" {
  export PYENV_VERSION="3.4"

  # emulate `python -S' behavior
  create_executable "python" <<SH
#!$BASH
if [[ \$1 == "-S"* ]]; then
  found="\$(PATH="\${PYTHONPATH:-\$PATH}" which \$2)"
  # assert that the found executable has python for shebang
  if head -1 "\$found" | grep python >/dev/null; then
    \$BASH "\$found"
  else
    echo "python: no Python script found in input (LoadError)" >&2
    exit 1
  fi
else
  echo 'python 3.4 (pyenv test)'
fi
SH

  create_executable "fab" <<SH
#!/usr/bin/env python
echo hello fab
SH

  pyenv-rehash
  run python -S fab
  assert_success "hello fab"
}
