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

  # xz-utils
  cat <<EOS
xz
EOS
}

# Remove conda shims
filter_conda_shims() {
  { cat
    conda_shims
  } | sort | uniq -c | awk '$1=="1"{print $2}' | tr '\n' ' '
}

deregister_conda_shims() {
  registered_shims="$(for shim in $registered_shims; do echo "${shim}"; done | filter_conda_shims)"
}

if conda_exists; then
  deregister_conda_shims
fi
