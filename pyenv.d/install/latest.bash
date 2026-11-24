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
        sed -E -e '/-dev$/d' -e '/-src$/d' -e '/-latest$/d' \
          $(if [[ -z "${PRERELEASE:-}" ]]; then echo "-e /(a|b|rc|c)[0-9]+$/d"; fi) \
          -e '/[0-9]+t$/d' | \
        awk '{
          orig = $0
          flavor = orig
          sub(/[0-9].*$/, "", flavor)
          v = substr(orig, length(flavor) + 1)
          pre_type = 4
          pre_num = 0
          if (match(v, "(rc|a|b|c)[0-9]+$")) {
            tag = substr(v, RSTART)
            v = substr(v, 1, RSTART - 1)
            sub(/[.-]$/, "", v)
            if (tag ~ /^rc/) { pre_type = 3; sub(/^rc/, "", tag); pre_num = tag + 0; }
            else if (tag ~ /^c/) { pre_type = 3; sub(/^c/, "", tag); pre_num = tag + 0; }
            else if (tag ~ /^b/) { pre_type = 2; sub(/^b/, "", tag); pre_num = tag + 0; }
            else if (tag ~ /^a/) { pre_type = 1; sub(/^a/, "", tag); pre_num = tag + 0; }
          }
          n = split(v, p, ".")
          v_pad = (n >= 1 ? p[1] : 0) "." (n >= 2 ? p[2] : 0) "." (n >= 3 ? p[3] : 0) "." (n >= 4 ? p[4] : 0)
          print flavor v_pad "." pre_type "." pre_num "." n "...|" orig
        }' | \
        sort -t. -k1,1r -k 2,2nr -k 3,3nr -k4,4nr -k5,5nr -k6,6nr -k7,7nr -k8,8nr -k9,9nr -k10,10nr | \
        cut -f2 -d '|' \
      || true))
    DEFINITION="${DEFINITION_CANDIDATES[0]:-}"
  fi
  echo "$DEFINITION"
}

for i in ${!DEFINITIONS[*]}; do
  DEFINITIONS[$i]="$(pyenv_install_resolve_latest "${DEFINITIONS[$i]}")"
done

unset pyenv_install_resolve_latest
