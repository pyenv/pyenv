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
  distro_version="$(slug "${distro##* }")"
  if [ "$1" = "Darwin" ]; then
    distro_version="${distro_version%%.*}"
  fi
  distro="$(slug "${distro% *}")"
  arch="$(slug "$arch")"

  if [ -z "$distro" ] || [ -z "$distro_version" ] || [ -z "$arch" ]; then
    echo "pyenv-binary: could not determine the package platform" >&2
    return 1
  fi

  printf '%s-%s-%s\n' "$distro" "$distro_version" "$arch"
}
