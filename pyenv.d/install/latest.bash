DEFINITION_PREFIX="${DEFINITION%%:*}"
DEFINITION_TYPE="${DEFINITION_PREFIX%%-*}" # TODO: support non-CPython versions
if [[ "${DEFINITION}" != "${DEFINITION_PREFIX}" ]]; then
  DEFINITION_CANDIDATES=(\
    $(python-build --definitions | \
      grep -F "${DEFINITION_PREFIX}" | \
      grep "^${DEFINITION_TYPE}" | \
      sed -E -e '/-dev$/d' -e '/-src$/d' -e '/(b|rc)[0-9]+$/d' | \
      sort -t. -k1,1r -k 2,2nr -k 3,3nr \
    || true))
  DEFINITION="${DEFINITION_CANDIDATES}"
  VERSION_NAME="${DEFINITION##*/}"
fi
