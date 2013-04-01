#!/usr/bin/env bats

load test_helper

create_executable() {
  bin="${RBENV_ROOT}/versions/${RBENV_VERSION}/bin"
  mkdir -p "$bin"
  echo "$2" > "${bin}/$1"
  chmod +x "${bin}/$1"
}

@test "fails with invalid version" {
  export RBENV_VERSION="2.0"
  run rbenv-exec ruby -v
  assert_failure "rbenv: version \`2.0' is not installed"
}

@test "completes with names of executables" {
  export RBENV_VERSION="2.0"
  create_executable "ruby"
  create_executable "rake"

  rbenv-rehash
  run rbenv-completions exec
  assert_success "\
    rake
    ruby"
}

@test "supports hook path with spaces" {
  hook_path="${RBENV_TEST_DIR}/custom stuff/rbenv hooks"
  mkdir -p "${hook_path}/exec"
  echo "export HELLO='from hook'" > "${hook_path}/exec/hello.bash"

  export RBENV_VERSION=system
  RBENV_HOOK_PATH="$hook_path" run rbenv-exec env
  assert_success
  assert_line "HELLO=from hook"
}

@test "forwards all arguments" {
  export RBENV_VERSION="2.0"
  create_executable "ruby" "#!$BASH
    echo \$0
    for arg; do
      # hack to avoid bash builtin echo which can't output '-e'
      printf \"%s\\n\" \"\$arg\"
    done"

  run rbenv-exec ruby -w -e "puts 'hello world'" -- extra args
  assert_success "\
    ${RBENV_ROOT}/versions/2.0/bin/ruby
    -w
    -e
    puts 'hello world'
    --
    extra
    args"
}

@test "supports ruby -S <cmd>" {
  export RBENV_VERSION="2.0"
  create_executable "ruby" "#!$BASH
    if [[ \$1 = '-S' ]]; then
      head -1 \$(which \$2) | grep ruby >/dev/null
      exit \$?
    else
      echo 'ruby 2.0 (rbenv test)'
    fi"
  create_executable "rake" "#!/usr/bin/env ruby"

  rbenv-rehash
  run ruby -S rake
  assert_success
}
