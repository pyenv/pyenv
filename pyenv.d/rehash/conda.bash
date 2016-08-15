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

shims=()
for shim in $(cat "${BASH_SOURCE%/*}/conda.txt"); do
  if [ -n "${shim%%#*}" ]; then
    shims[${#shims[*]}]="${shim})return 0;;"
  fi
done
eval "conda_shim(){ case \"\$1\" in ${shims[@]} *)return 1;;esac;}"

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
