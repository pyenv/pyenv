#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${RBENV_ROOT}/versions/${RBENV_VERSION}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "fails with invalid version" {
  export RBENV_VERSION="2.0"
  run rbenv-exec ruby -v
  assert_failure "rbenv: version \`2.0' is not installed (set by RBENV_VERSION environment variable)"
}

@test "fails with invalid version set from file" {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
  echo 1.9 > .ruby-version
  run rbenv-exec rspec
  assert_failure "rbenv: version \`1.9' is not installed (set by $PWD/.ruby-version)"
}

@test "completes with names of executables" {
  export RBENV_VERSION="2.0"
  create_executable "ruby" "#!/bin/sh"
  create_executable "rake" "#!/bin/sh"

  rbenv-rehash
  run rbenv-completions exec
  assert_success
  assert_output <<OUT
--help
rake
ruby
OUT
}

@test "carries original IFS within hooks" {
  create_hook exec hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export RBENV_VERSION=system
  IFS=$' \t\n' run rbenv-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export RBENV_VERSION="2.0"
  create_executable "ruby" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run rbenv-exec ruby -w "/path to/ruby script.rb" -- extra args
  assert_success
  assert_output <<OUT
${RBENV_ROOT}/versions/2.0/bin/ruby
  -w
  /path to/ruby script.rb
  --
  extra
  args
OUT
}

@test "supports ruby -S <cmd>" {
  export RBENV_VERSION="2.0"

  # emulate `ruby -S' behavior
  create_executable "ruby" <<SH
#!$BASH
if [[ \$1 == "-S"* ]]; then
  found="\$(PATH="\${RUBYPATH:-\$PATH}" which \$2)"
  # assert that the found executable has ruby for shebang
  if head -n1 "\$found" | grep ruby >/dev/null; then
    \$BASH "\$found"
  else
    echo "ruby: no Ruby script found in input (LoadError)" >&2
    exit 1
  fi
else
  echo 'ruby 2.0 (rbenv test)'
fi
SH

  create_executable "rake" <<SH
#!/usr/bin/env ruby
echo hello rake
SH

  rbenv-rehash
  run ruby -S rake
  assert_success "hello rake"
}
