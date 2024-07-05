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
  assert_line "command rbenv rehash 2>/dev/null"
}

@test "setup shell completions" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run rbenv-init - bash
  assert_success
  assert_line "source '${root}/test/../completions/rbenv.bash'"
}

@test "detect parent shell" {
  SHELL=/bin/false run rbenv-init -
  assert_success
  assert_line "export RBENV_SHELL=bash"
}

@test "detect parent shell from script" {
  mkdir -p "$RBENV_TEST_DIR"
  cd "$RBENV_TEST_DIR"
  cat > myscript.sh <<OUT
#!/bin/sh
eval "\$(rbenv-init -)"
echo \$RBENV_SHELL
OUT
  chmod +x myscript.sh
  run ./myscript.sh
  assert_success "sh"
}

@test "skip shell completions (fish)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run rbenv-init - fish
  assert_success
  local line="$(grep '^source' <<<"$output")"
  [ -z "$line" ] || flunk "did not expect line: $line"
}

@test "set up bash" {
  assert [ ! -e ~/.bash_profile ]
  run rbenv-init bash
  assert_success "writing ~/.bash_profile: now configured for rbenv."
  run cat ~/.bash_profile
  # shellcheck disable=SC2016
  assert_line 'eval "$(rbenv init - --no-rehash bash)"'
}

@test "set up bash (bashrc)" {
  mkdir -p "$HOME"
  touch ~/.bashrc
  assert [ ! -e ~/.bash_profile ]
  run rbenv-init bash
  assert_success "writing ~/.bashrc: now configured for rbenv."
  run cat ~/.bashrc
  # shellcheck disable=SC2016
  assert_line 'eval "$(rbenv init - --no-rehash bash)"'
}

@test "set up zsh" {
  unset ZDOTDIR
  assert [ ! -e ~/.zprofile ]
  run rbenv-init zsh
  assert_success "writing ~/.zprofile: now configured for rbenv."
  run cat ~/.zprofile
  # shellcheck disable=SC2016
  assert_line 'eval "$(rbenv init - --no-rehash zsh)"'
}

@test "set up zsh (zshrc)" {
  unset ZDOTDIR
  mkdir -p "$HOME"
  cat > ~/.zshrc <<<"# rbenv"
  run rbenv-init zsh
  assert_success "writing ~/.zshrc: now configured for rbenv."
  run cat ~/.zshrc
  # shellcheck disable=SC2016
  assert_line 'eval "$(rbenv init - --no-rehash zsh)"'
}

@test "set up fish" {
  unset XDG_CONFIG_HOME
  run rbenv-init fish
  assert_success "writing ~/.config/fish/config.fish: now configured for rbenv."
  run cat ~/.config/fish/config.fish
  assert_line 'status --is-interactive; and rbenv init - --no-rehash fish | source'
}

@test "set up multiple shells at once" {
  unset ZDOTDIR
  unset XDG_CONFIG_HOME
  run rbenv-init bash zsh fish
  assert_success
  assert_output <<OUT
writing ~/.bash_profile: now configured for rbenv.
writing ~/.zprofile: now configured for rbenv.
writing ~/.config/fish/config.fish: now configured for rbenv.
OUT
}

@test "option to skip rehash" {
  run rbenv-init - --no-rehash
  assert_success
  refute_line "rbenv rehash 2>/dev/null"
}

@test "adds shims to PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run rbenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${RBENV_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run rbenv-init - fish
  assert_success
  assert_line 0 "set -gx PATH '${RBENV_ROOT}/shims' \$PATH"
}

@test "can add shims to PATH more than once" {
  export PATH="${RBENV_ROOT}/shims:$PATH"
  run rbenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${RBENV_ROOT}'/shims:${PATH}"'
}

@test "can add shims to PATH more than once (fish)" {
  export PATH="${RBENV_ROOT}/shims:$PATH"
  run rbenv-init - fish
  assert_success
  assert_line 0 "set -gx PATH '${RBENV_ROOT}/shims' \$PATH"
}

@test "outputs sh-compatible syntax" {
  run rbenv-init - bash
  assert_success
  assert_line '  case "$command" in'

  run rbenv-init - zsh
  assert_success
  assert_line '  case "$command" in'
}

@test "outputs fish-specific syntax (fish)" {
  run rbenv-init - fish
  assert_success
  assert_line '  switch "$command"'
  refute_line '  case "$command" in'
}
