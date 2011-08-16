#compdef _rbenv rbenv

function _rbenv_commands() {
  cmds_str="$(rbenv commands)"
  cmds=("${(ps:\n:)cmds_str}")
  _describe '_rbenv_commands' cmds
}

_rbenv_versions() {
  versions_str="$(rbenv versions --bare)"
  versions=(system "${(ps:\n:)versions_str}")
  _describe '_rbenv_versions' versions
}

_rbenv() {
  case "$words[2]" in
    set-local | set-default | prefix ) _rbenv_versions ;;
    * ) _rbenv_commands ;;
  esac
}
