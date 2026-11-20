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
  assert_line "command pyenv rehash"
}

@test "auto rehash for --path" {
  run pyenv-init --path
  assert_success
  assert_line "command pyenv rehash"
}

@test "setup shell completions" {
  run pyenv-init - bash
  assert_success
  assert_line "source '${_PYENV_INSTALL_PREFIX}/completions/pyenv.bash'"
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
  run pyenv-init - fish
  assert_success
  assert_line "source '${_PYENV_INSTALL_PREFIX}/completions/pyenv.fish'"
}

@test "fish instructions" {
  run pyenv-init fish
  assert [ "$status" -eq 1 ]
  assert_line 'pyenv init - fish | source'
}

@test "setup shell completions (pwsh)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run pyenv-init - pwsh
  assert_success
  assert_line "iex (gc ${root}/completions/pyenv.pwsh -Raw)"
}

@test "pwsh instructions" {
  run pyenv-init pwsh
  assert [ "$status" -eq 1 ]
  assert_line 'iex ((pyenv init -) -join "`n")'
}

@test "shell detection for installer" {
  run pyenv-init --detect-shell
  assert_success
  assert_line "PYENV_SHELL_DETECT=bash"
}

@test "shell detection for fish startup file" {
  run pyenv-init --detect-shell fish
  assert_success
  assert_line "PYENV_SHELL_DETECT=fish"
  assert_line "PYENV_PROFILE_DETECT=~/.config/fish/config.fish"
  assert_line "PYENV_RC_DETECT=~/.config/fish/config.fish"
}

@test "completion includes install option" {
  run pyenv-init --complete
  assert_success
  assert_line "--install"
}

@test "install setup for detected shell startup files (default PYENV_ROOT)" {
  export PYENV_ROOT="$HOME/.pyenv"
  mkdir -p "$PYENV_ROOT"

  run pyenv-init --install
  assert_success
  assert_output <<OUT
pyenv: shell detected as bash
pyenv: adding configuration to $HOME/.bashrc
pyenv: adding configuration to $HOME/.profile
OUT

  expected_setup=$'export PYENV_ROOT="$HOME/.pyenv"\n[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"\neval "$(pyenv init - bash)"'
  assert_equal "$expected_setup" "$(cat "$HOME/.bashrc")"
  assert_equal "$expected_setup" "$(cat "$HOME/.profile")"
}

@test "install setup for bash uses existing bash_profile (default PYENV_ROOT)" {
  export PYENV_ROOT="$HOME/.pyenv"
  mkdir -p "$PYENV_ROOT"
  touch "$HOME/.bash_profile"

  run pyenv-init --install bash
  assert_success

  expected_setup=$'export PYENV_ROOT="$HOME/.pyenv"\n[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"\neval "$(pyenv init - bash)"'
  assert_equal "$expected_setup" "$(cat "$HOME/.bashrc")"
  assert_equal "$expected_setup" "$(cat "$HOME/.bash_profile")"
  assert [ ! -e "$HOME/.profile" ]
}

@test "install setup for zsh startup files (default PYENV_ROOT)" {
  export PYENV_ROOT="$HOME/.pyenv"
  mkdir -p "$PYENV_ROOT"

  run pyenv-init --install zsh
  assert_success
  assert_output <<OUT
pyenv: configuring for zsh
pyenv: adding configuration to $HOME/.zshrc
pyenv: adding configuration to $HOME/.zprofile
OUT

  expected_setup=$'export PYENV_ROOT="$HOME/.pyenv"\n[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"\neval "$(pyenv init - zsh)"'
  assert_equal "$expected_setup" "$(cat "$HOME/.zshrc")"
  assert_equal "$expected_setup" "$(cat "$HOME/.zprofile")"
}

@test "install setup for fish startup file (default PYENV_ROOT)" {
  export PYENV_ROOT="$HOME/.pyenv"
  mkdir -p "$PYENV_ROOT"
  create_stub fish <<OUT
printf '%s\n' "\$2" > "$PYENV_TEST_DIR/fish-script"
OUT

  run pyenv-init --install fish
  assert_success
  assert_output <<OUT
pyenv: configuring for fish
pyenv: setting fish universal variables for PYENV_ROOT and PATH
pyenv: adding configuration to $HOME/.config/fish/config.fish
OUT

  expected_fish_script=$'set -Ux PYENV_ROOT $HOME/.pyenv\nif functions -q fish_add_path\n  test -d $PYENV_ROOT/bin; and fish_add_path $PYENV_ROOT/bin\nelse\n  test -d $PYENV_ROOT/bin; and set -U fish_user_paths $PYENV_ROOT/bin $fish_user_paths\nend'
  expected_setup='pyenv init - fish | source'
  assert_equal "$expected_fish_script" "$(cat "$PYENV_TEST_DIR/fish-script")"
  assert_equal "$expected_setup" "$(cat "$HOME/.config/fish/config.fish")"
}

@test "install setup for pwsh startup file (default PYENV_ROOT)" {
  export PYENV_ROOT="$HOME/.pyenv"
  mkdir -p "$PYENV_ROOT"

  run pyenv-init --install pwsh
  assert_success

  expected_setup=$'$Env:PYENV_ROOT="$Env:HOME/.pyenv"\nif (Test-Path -LP "$Env:PYENV_ROOT/bin" -PathType Container) {\n  $Env:PATH="$Env:PYENV_ROOT/bin:$Env:PATH" }\niex ((pyenv init -) -join "`n")'
  assert_equal "$expected_setup" "$(cat "$HOME/.config/powershell/profile.ps1")"
}

@test "init honors custom PYENV_ROOT and quotes it according to each shell's rules" {
  export PYENV_ROOT='/tmp/pyenv$root/"quote"'
  run pyenv-init bash
  assert [ "$status" -eq 1 ]
  assert_line 'export PYENV_ROOT="/tmp/pyenv\$root/\"quote\""'

  run pyenv-init fish
  assert [ "$status" -eq 1 ]
  assert_line 'set -Ux PYENV_ROOT "/tmp/pyenv\$root/\"quote\""'

  export PYENV_ROOT="/tmp/pyenv'root"
  run pyenv-init pwsh
  assert [ "$status" -eq 1 ]
  assert_line "\$Env:PYENV_ROOT='/tmp/pyenv''root'"
}

@test "install refuses to modify files with pyenv-related code" {
  mkdir -p "$HOME"
  echo 'eval "$(pyenv init -)"' > "$HOME/.bashrc"

  run pyenv-init --install bash
  assert_failure
  assert_output <<OUT
pyenv: configuring for bash
pyenv: cannot automatically apply changes to $HOME/.bashrc: it appears to already contain Pyenv-related code.
pyenv: no files were changed.
pyenv: review the files listed above and apply changes manually if necessary.
pyenv: run \`pyenv init bash\` to see the suggested setup.
OUT

  assert_equal 'eval "$(pyenv init -)"' "$(cat "$HOME/.bashrc")"
  assert [ ! -e "$HOME/.profile" ]
}

@test "install checks the second startup file before changing the first" {
  mkdir -p "$HOME"
  echo 'eval "$(pyenv init -)"' > "$HOME/.profile"

  run pyenv-init --install bash
  assert_failure
  assert_line "pyenv: cannot automatically apply changes to $HOME/.profile: it appears to already contain Pyenv-related code."
  assert_line "pyenv: no files were changed."

  assert [ ! -e "$HOME/.bashrc" ]
  assert_equal 'eval "$(pyenv init -)"' "$(cat "$HOME/.profile")"
}

@test "install lists every startup file with pyenv-related code" {
  mkdir -p "$HOME"
  echo 'eval "$(pyenv init -)"' > "$HOME/.zshrc"
  echo 'export PYENV_ROOT="$HOME/.pyenv"' > "$HOME/.zprofile"

  run pyenv-init --install zsh
  assert_failure
  assert_output <<OUT
pyenv: configuring for zsh
pyenv: cannot automatically apply changes to $HOME/.zshrc: it appears to already contain Pyenv-related code.
pyenv: cannot automatically apply changes to $HOME/.zprofile: it appears to already contain Pyenv-related code.
pyenv: no files were changed.
pyenv: review the files listed above and apply changes manually if necessary.
pyenv: run \`pyenv init zsh\` to see the suggested setup.
OUT

  assert_equal 'eval "$(pyenv init -)"' "$(cat "$HOME/.zshrc")"
  assert_equal 'export PYENV_ROOT="$HOME/.pyenv"' "$(cat "$HOME/.zprofile")"
}

@test "install refuses a non-regular file without partial writes" {
  mkdir -p "$HOME"
  mkfifo "$HOME/.profile"

  run pyenv-init --install bash
  assert_failure
  assert_line "pyenv: $HOME/.profile is not a regular file"
  assert_line "pyenv: no files were changed."

  assert [ ! -e "$HOME/.bashrc" ]
  assert [ -p "$HOME/.profile" ]
}

@test "install refuses unreadable startup file without partial writes" {
  mkdir -p "$HOME"
  touch "$HOME/.bashrc"
  chmod a-r "$HOME/.bashrc"
  skip_if_nonposix_security -r "$HOME/.bashrc"

  run pyenv-init --install bash
  assert_failure
  assert_line "pyenv: failed to inspect $HOME/.bashrc"

  assert [ ! -e "$HOME/.profile" ]
  assert [ ! -s "$HOME/.bashrc" ]
}

@test "install refuses a non-writable startup file without partial writes" {
  mkdir -p "$HOME"
  touch "$HOME/.profile"
  chmod a-w "$HOME/.profile"
  skip_if_nonposix_security -w "$HOME/.profile"

  run pyenv-init --install bash
  assert_failure
  assert_line "pyenv: $HOME/.profile is not writable"
  assert_line "pyenv: no files were changed."

  assert [ ! -e "$HOME/.bashrc" ]
  assert [ ! -s "$HOME/.profile" ]
}

@test "install refuses a startup file it cannot create, before setting fish variables" {
  mkdir -p "$HOME"
  touch "$HOME/.config"
  create_stub fish <<OUT
touch "$PYENV_TEST_DIR/fish-called"
OUT

  run pyenv-init --install fish
  assert_failure
  assert_line "pyenv: cannot create $HOME/.config/fish/config.fish"
  assert_line "pyenv: no files were changed."

  assert [ ! -e "$PYENV_TEST_DIR/fish-called" ]
  assert [ ! -s "$HOME/.config" ]
}

@test "install treats a broken symlink as a missing startup file" {
  export PYENV_ROOT="$HOME/.pyenv"
  mkdir -p "$PYENV_ROOT" "$HOME/dotfiles"
  ln -s "$HOME/dotfiles/profile" "$HOME/.profile"

  run pyenv-init --install bash
  assert_success

  expected_setup=$'export PYENV_ROOT="$HOME/.pyenv"\n[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"\neval "$(pyenv init - bash)"'
  assert [ -L "$HOME/.profile" ]
  assert_equal "$expected_setup" "$(cat "$HOME/dotfiles/profile")"
}

@test "install refuses a broken symlink whose target directory is missing" {
  mkdir -p "$HOME"
  ln -s "$HOME/missing/profile" "$HOME/.profile"

  run pyenv-init --install bash
  assert_failure
  assert_line "pyenv: cannot create $HOME/.profile"
  assert_line "pyenv: no files were changed."

  assert [ ! -e "$HOME/.bashrc" ]
  assert [ ! -e "$HOME/missing" ]
  #assert the symlink is untouched
  assert_equal "$HOME/missing/profile" "$(readlink "$HOME/.profile")"
}

@test "install treats PYENV_ROOT as pyenv-related code" {
  mkdir -p "$HOME"
  echo 'export PYENV_ROOT="$HOME/tools/python-env"' > "$HOME/.bashrc"

  run pyenv-init --install bash
  assert_failure
  assert_line "pyenv: cannot automatically apply changes to $HOME/.bashrc: it appears to already contain Pyenv-related code."
}

@test "install setup keeps fish block intact when generic lines already exist" {
  mkdir -p "$HOME/.config/fish"
  create_stub fish <<OUT
exit 0
OUT
  echo "end" > "$HOME/.config/fish/config.fish"

  run pyenv-init --install fish
  assert_success

  expected_setup=$'end\npyenv init - fish | source'
  assert_equal "$expected_setup" "$(cat "$HOME/.config/fish/config.fish")"
}

@test "install setup fails gracefully for unsupported shell" {
  mkdir -p "$HOME"

  run pyenv-init --install nu
  assert_failure
  assert_output <<'OUT'
pyenv: configuring for nu
pyenv: cannot automatically configure startup files for nu
OUT
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

@test "adds shims to PATH (pwsh)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run pyenv-init - pwsh
  assert_success
  assert_line '$Env:PATH="'${PYENV_ROOT}'/shims:$Env:PATH"'
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

@test "removes existing shims from PATH (pwsh)" {
  command -v pwsh >/dev/null || skip "-- pwsh not installed"
  OLDPATH="$PATH"
  export PATH="${BATS_TEST_DIRNAME}/nonexistent:${PYENV_ROOT}/shims:$PATH"
  run pwsh -noni -c - <<!
\$Env:PATH="$PATH"
iex ((pyenv init -) -join "\`n")
echo "\$Env:PATH"
!
  assert_success
  assert_output "${PYENV_ROOT}/shims:${BATS_TEST_DIRNAME}/nonexistent:${OLDPATH//${PYENV_ROOT}\/shims:/}"
}

@test "removes existing shims from PATH (zsh)" {
  command -v zsh >/dev/null || skip "-- zsh not installed"
  OLDPATH="$PATH"
  export PATH="${BATS_TEST_DIRNAME}/nonexistent:${PYENV_ROOT}/shims:$PATH"
  run zsh -df - <<!
eval "\$(pyenv-init -)"
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

@test "adds shims to PATH with --no-push-path if they're not on PATH (pwsh)" {
  command -v pwsh >/dev/null || skip "-- pwsh not installed"
  PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run pwsh -nop -c - <<!
#Powershell silently prepends its own PATH entry upon start
\$Env:PATH="$PATH"
iex ((pyenv init - --no-push-path) -join "\`n")
echo "\$Env:PATH"
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

@test "doesn't change PATH with --no-push-path if shims are already on PATH (pwsh)" {
  command -v pwsh >/dev/null || skip "-- pwsh not installed"
  PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:${PYENV_ROOT}/shims:/bin:/usr/local/bin"
  run pwsh -nop -c - <<!
#Powershell silently prepends its own PATH entry upon start
\$Env:PATH="$PATH"
iex ((pyenv init - --no-push-path) -join "\`n")
echo "\$Env:PATH"
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
  create_stub pyenv-commands <<!
echo -e 'activate\ndeactivate\nrehash\nshell'
!
  run pyenv-init - bash
  assert_success
  assert_line '  activate|deactivate|rehash|shell)'

  create_stub pyenv-commands <<!
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

@test "outputs pwsh-specific syntax (pwsh)" {
  run pyenv-init - pwsh
  assert_success
  refute_line '  switch "$command"'
  refute_line '  case "$command" in'
}
