PROTOTYPE_SOURCE_SHIM_PATH="${SHIM_PATH}/.pyenv-source-shim"


create_source_prototype_shim() {
  if [ -f "${PROTOTYPE_SOURCE_SHIM_PATH}" ]; then
    return
  fi

  cat > "${PROTOTYPE_SOURCE_SHIM_PATH}" <<SH
[ -n "\$PYENV_DEBUG" ] && set -x
export PYENV_ROOT="${PYENV_ROOT}"
program="\$("$(command -v pyenv)" which "\${BASH_SOURCE##*/}")"
if [ -e "\${program}" ]; then
  . "\${program}" "\$@"
fi
SH
  chmod +x "${PROTOTYPE_SOURCE_SHIM_PATH}"
}

shopt -s nullglob
for shim in $(cat "${BASH_SOURCE%/*}/source.d/"*".list" | sort -u | sed -e 's/#.*$//' | sed -e '/^[[:space:]]*$/d'); do
  if [ -n "${shim##*/}" ]; then
    source_shim="${SHIM_PATH}/${shim}"
    if [ -e "${SOURCE_SHIM}" ]; then
      create_source_prototype_shim
      cp "${PROTOTYPE_SOURCE_SHIM_PATH}" "${source_shim}"
    fi
  fi
done

rm -f "${PROTOTYPE_SOURCE_SHIM_PATH}"
