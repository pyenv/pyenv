# Anaconda comes with binaries of system packages (e.g. `openssl`, `curl`).
# Creating shims for those binaries will prevent pyenv users to run those
# commands normally when not using Anaconda.
#
# This hooks is intended to skip creating shims for those executables.

conda_exists() {
  shopt -s dotglob nullglob
  local condas=($(echo "${PYENV_ROOT}/versions/"*"/bin/conda" "${PYENV_ROOT}/versions/"*"/envs/"*"/bin/conda"))
  shopt -u dotglob nullglob
  [ -n "${condas}" ]
}

if conda_exists; then

  # Reads the list of `blacklisted` conda binaries
  # from `conda.d/default.list` and creates a function
  # `conda_shim` to skip creating shims for those binaries.
  build_conda_exclusion_list() {
    shims=()
    for shim in $(sed 's/#.*$//; /^[[:space:]]*$/d' "${BASH_SOURCE%/*}/conda.d/default.list"); do
      if [ -n "${shim##*/}" ]; then
        shims[${#shims[*]}]="${shim})return 0;;"
      fi
    done
    eval \
"conda_shim() {
  case \"\${1##*/}\" in
    ${shims[@]}
    *) return 1;;
  esac
}"
  }

  # override `make_shims` to avoid conflict between pyenv-virtualenv's `envs.bash`
  # https://github.com/pyenv/pyenv-virtualenv/blob/v20160716/etc/pyenv.d/rehash/envs.bash
  # The only difference between this `make_shims` and the `make_shims` defined
  # in `libexec/pyenv-rehash` is that this one calls `conda_shim` to check
  # if shim is blacklisted. If blacklisted -> skip creating shim.
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
    # adapted for Bash 4.x's associative array (#1749)
    if declare -p registered_shims 2> /dev/null | grep -Eq '^(declare|typeset) -A'; then
      for shim in ${!registered_shims[*]}; do
        if conda_shim "${shim}" 1>&2; then
          unset registered_shims[${shim}]
        fi
      done
    else
      local shim
      local shims=()
      for shim in ${registered_shims}; do
        if ! conda_shim "${shim}" 1>&2; then
          shims[${#shims[*]}]="${shim}"
        fi
      done
      registered_shims=" ${shims[@]} "
    fi
  }

  build_conda_exclusion_list
  deregister_conda_shims
fi
