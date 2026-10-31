use_records() {
  local plugin="$BATS_TEST_TMPDIR/plugin"
  records="$plugin/share/pyenv-binary/versions"
  mkdir -p "$plugin/libexec" "$records"
  cp "$BATS_TEST_DIRNAME/../libexec/pyenv-binary-"{find,install,package-name} "$plugin/libexec/"
  cp "$BATS_TEST_DIRNAME/../share/pyenv-binary/"*.bash "$plugin/share/pyenv-binary/"
  PATH="$plugin/libexec:$PATH"
  definition_sha="4c4ed1afbfdaa1e4c3bf7bbb82d730cecb7e384da91eea4f3cc093fd545524d6"
}

set_platform() {
  printf 'os=%q\narch=%q\ndistro=%q\n' "$1" "$2" "$3" \
    > "$BATS_TEST_TMPDIR/plugin/share/pyenv-binary/platform.bash"
}
