compctl -K _rbenv rbenv

function _rbenv_commands() {
  local cmds_str="$(rbenv commands)"
  reply=("${(ps:\n:)cmds_str}")
}

_rbenv_versions() {
  local versions_str="$(rbenv versions --bare)"
  reply=(system "${(ps:\n:)versions_str}")
}

_rbenv() {
  read -cA words
  case "$words[2]" in
    set-* | global | local | shell | prefix ) _rbenv_versions ;;
    * ) _rbenv_commands ;;
  esac
}
