# Anaconda comes with binaries of system packages (e.g. `openssl`, `curl`).
# Creating shims for those binaries will prevent pyenv users to run those
# commands normally when not using Anaconda.
#
# This is a limited edition of https://github.com/yyuu/pyenv-which-ext
# and it will looks for original `PATH` if there is Anaconda/Miniconda
# installed and the command name is blacklisted.

conda_exists() {
  shopt -s nullglob
  local condas=($(echo "${PYENV_ROOT}/versions/"*"/bin/conda" "${PYENV_ROOT}/versions/"*"/envs/"*"/bin/conda"))
  shopt -u nullglob
  [ -n "${condas}" ]
}

conda_shims() {
  ## curl
  cat <<EOS
curl
curl-config
EOS

  ## fontconfig
  cat <<EOS
fc-cache
fc-cat
fc-list
fc-match
fc-pattern
fc-query
fc-scan
fc-validate
EOS

  ## freetype
  cat <<EOS
freetype-config
EOS

  ## libpng
  cat <<EOS
libpng-config
EOS

  ## openssl
  cat <<EOS
openssl
EOS

  ## qtchooser
  cat <<EOS
assistant
designer
lconvert
linguist
lrelease
lupdate
moc
pixeltool
qcollectiongenerator
qdbus
qdbuscpp2xml
qdbusviewer
qdbusxml2cpp
qhelpconverter
qhelpgenerator
qmake
qmlplugindump
qmlviewer
qtconfig
rcc
uic
xmlpatterns
xmlpatternsvalidator
EOS

  ## redis
  cat <<EOS
redis-benchmark
redis-check-aof
redis-check-dump
redis-cli
redis-server
EOS

  ## sqlite3
  cat <<EOS
sqlite3
EOS

  ## libxml2
  cat <<EOS
xml2-config
EOS

  ## libxslt
  cat <<EOS
xslt-config
EOS

  ## xsltproc
  cat <<EOS
xsltproc
EOS
}

expand_path() {
  if [ ! -d "$1" ]; then
    return 1
  fi

  local cwd="$(pwd)"
  cd "$1"
  pwd
  cd "$cwd"
}

remove_from_path() {
  local path_to_remove="$(expand_path "$1")"
  local result=""

  if [ -z "$path_to_remove" ]; then
    echo "${PATH}"
    return
  fi

  local paths
  IFS=: paths=($PATH)

  for path in "${paths[@]}"; do
    path="$(expand_path "$path" || true)"
    if [ -n "$path" ] && [ "$path" != "$path_to_remove" ]; then
      result="${result}${path}:"
    fi
  done

  echo "${result%:}"
}

lookup_from_path() {
  local command_to_lookup="$1"
  local original_path="${PATH}"
  PATH="$(remove_from_path "${PYENV_ROOT}/shims")"
  local result="$(command -v "$command_to_lookup" || true)"
  PATH="${original_path}"
  echo "$result"
}

if [ -n "$PYENV_COMMAND" ]; then
  if conda_exists; then
    if [ -x "$PYENV_COMMAND_PATH" ]; then
      # `curl` bundled with Anaconda does not work on Debian
      # https://github.com/ContinuumIO/anaconda-issues/issues/72
      if [[ "$PYENV_COMMAND" == "curl" ]] && [[ -x "${PYENV_COMMAND_PATH%/*}/curl-config" ]]; then
        if [ ! -f "$("${PYENV_COMMAND_PATH%/*}/curl-config" --ca 2>/dev/null || true)" ]; then
          PYENV_COMMAND_PATH="$(lookup_from_path "$PYENV_COMMAND" || true)"
        fi
      fi
    else
      if conda_shims | grep -q -x "$PYENV_COMMAND"; then
        PYENV_COMMAND_PATH="$(lookup_from_path "$PYENV_COMMAND" || true)"
      fi
    fi
  fi
fi
