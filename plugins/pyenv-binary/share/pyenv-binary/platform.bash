os="$(uname -s)"
arch="$(uname -m)"
distro=""

case "$os" in
Linux )
  if [ -r /etc/os-release ]; then
    distro="$(. /etc/os-release && printf '%s %s' "${ID:-}" "${VERSION_ID:-}")"
  elif type -p lsb_release >/dev/null; then
    distro="$(lsb_release -si)"
    distro="$distro $(lsb_release -sr)"
  fi
  ;;
Darwin )
  distro="macos $(sw_vers -productVersion)"
  ;;
* )
  distro="$os $(uname -r)"
  ;;
esac

distro="$(printf '%s' "$distro" | tr '[:upper:]' '[:lower:]')"
