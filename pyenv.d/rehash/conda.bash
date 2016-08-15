# Anaconda comes with binaries of system packages (e.g. `openssl`, `curl`).
# Creating shims for those binaries will prevent pyenv users to run those
# commands normally when not using Anaconda.
#
# This hooks is intended to skip creating shims for those executables.

conda_exists() {
  shopt -s nullglob
  local condas=($(echo "${PYENV_ROOT}/versions/"*"/bin/conda" "${PYENV_ROOT}/versions/"*"/envs/"*"/bin/conda"))
  shopt -u nullglob
  [ -n "${condas}" ]
}

conda_shim() {
  case "${1##*/}" in
  "curl" | "curl-config" )
    return 0 # curl
    ;;
  "fc-cache" | "fc-cat" | "fc-list" | "fc-match" | "fc-pattern" | "fc-query" | "fc-scan" | "fc-validate" )
    return 0 # fontconfig
    ;;
  "freetype-config" )
    return 0 # freetype
    ;;
  "libpng-config" )
    return 0 # libpng
    ;;
  "openssl" )
    return 0 # openssl
    ;;
  "assistant" | "designer" | "lconvert" | "linguist" | "lrelease" | "lupdate" | "moc" | "pixeltool" | "qcollectiongenerator" | "qdbus" | "qdbuscpp2xml" | "qdbusviewer" | "qdbusxml2cpp" | "qhelpconverter" | "qhelpgenerator" | "qmake" | "qmlplugindump" | "qmlviewer" | "qtconfig" | "rcc" | "uic" | "xmlpatterns" | "xmlpatternsvalidator" )
    return 0 # qtchooser
    ;;
  "redis-benchmark" | "redis-check-aof" | "redis-check-dump" | "redis-cli" | "redis-server" )
    return 0 # redis
    ;;
  "sqlite3" )
    return 0 # sqlite3
    ;;
  "xml2-config" )
    return 0 # libxml2
    ;;
  "xslt-config" )
    return 0 # libxslt
    ;;
  "xsltproc" )
    return 0 # xsltproc
    ;;
  "unxz" | "xz" | "xzcat" | "xzcmd" | "xzdiff" | "xzegrep" | "xzfgrep" | "xzgrep" | "xzless" | "xzmore" )
    return 0 # xz-utils
    ;;
  esac
  return 1
}

# override `make_shims` to avoid conflict between pyenv-virtualenv's `envs.bash`
# https://github.com/yyuu/pyenv-virtualenv/blob/v20160716/etc/pyenv.d/rehash/envs.bash
make_shims() {
  local file shim
  for file do
    shim="${file##*/}"
    if ! conda_shim "${shim}" 1>&2; then
      register_shim "$shim"
    fi
  done
}

deregister_conda_shims() {
  local shim
  local shims=()
  for shim in ${registered_shims}; do
    if ! conda_shim "${shim}" 1>&2; then
      shims[${#shims[*]}]="${shim}"
    fi
  done
  registered_shims=" ${shims[@]} "
}

if conda_exists; then
  deregister_conda_shims
fi
