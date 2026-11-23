# A name must work as a single path component and as a value in line-based
# metadata.
is_name_safe() {
  case "$1" in
  "" | */* | .. | . | *[[:cntrl:]]* ) return 1 ;;
  esac
}

slug() {
  printf '%s' "$1" |
    tr '[:upper:] ' '[:lower:]-' |
    tr -cd 'a-z0-9._-'
}

# Prints the platform part of a package name from `detect_platform' results.
package_suffix() {
  local distro release arch
  distro="$(slug "${1% *}")" || return
  release="$(slug "${1##* }")" || return
  arch="$(slug "$2")" || return
  # Builds are made for each macOS major version.
  if [ "$distro" = macos ]; then
    release="${release%%.*}"
  fi

  if [ -z "$distro" ] || [ -z "$release" ] || [ -z "$arch" ]; then
    echo "pyenv-binary: could not determine the package platform" >&2
    return 1
  fi

  printf '%s-%s-%s\n' "$distro" "$release" "$arch"
}
