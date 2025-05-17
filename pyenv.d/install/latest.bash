pyenv_install_resolve_latest() {
  local DEFINITION_PREFIX DEFINITION_TYPE
  local -a DEFINITION_CANDIDATES
  local DEFINITION="$1"
  
  DEFINITION_PREFIX="${DEFINITION%%:*}"
  DEFINITION_TYPE="${DEFINITION_PREFIX%%-*}" # TODO: support non-CPython versions
  if [[ "${DEFINITION}" != "${DEFINITION_PREFIX}" ]]; then
    DEFINITION_CANDIDATES=(\
      $(python-build --definitions | \
        grep -F "${DEFINITION_PREFIX}" | \
        grep "^${DEFINITION_TYPE}" | \
        sed -E -e '/-dev$/d' -e '/-src$/d' -e '/(b|rc)[0-9]+$/d' -e '/[0-9]+t$/d' | \
        sort -t. -k1,1r -k 2,2nr -k 3,3nr \
      || true))
    DEFINITION="${DEFINITION_CANDIDATES}"
  fi
  echo "$DEFINITION"
}

for i in ${!DEFINITIONS[*]}; do
  DEFINITIONS[$i]="$(pyenv_install_resolve_latest "${DEFINITIONS[$i]}")"
done

unset pyenv_install_resolve_latest
