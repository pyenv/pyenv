is_name_safe() {
  case "$1" in
  "" | */* | .. | . | *[[:cntrl:]]* ) return 1 ;;
  * ) return 0 ;;
  esac
}

slug() {
  printf '%s' "$1" |
    tr '[:upper:] ' '[:lower:]-' |
    tr -cd 'a-z0-9._-'
}

package_suffix() {
  local distro="$2" arch="$3" distro_version
  # Bash 3.2 does not preserve errexit inside command substitutions.
  distro_version="$(slug "${distro##* }")" || return
  if [ "$1" = "Darwin" ]; then
    distro_version="${distro_version%%.*}"
  fi
  distro="$(slug "${distro% *}")" || return
  arch="$(slug "$arch")" || return

  if [ -z "$distro" ] || [ -z "$distro_version" ] || [ -z "$arch" ]; then
    echo "pyenv-binary: could not determine the package platform" >&2
    return 1
  fi

  printf '%s-%s-%s\n' "$distro" "$distro_version" "$arch"
}
