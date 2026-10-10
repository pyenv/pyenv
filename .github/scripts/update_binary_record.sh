#!/usr/bin/env bash
set -e

version="$1"
definition="$2"
records="$3"

source "${BASH_SOURCE%/*}/../../plugins/pyenv-binary/share/pyenv-binary/common.bash"
if ! is_name_safe "$version"; then
  echo "pyenv-binary: invalid version name \`$version'" >&2
  exit 1
fi

entry="${definition##*/}"
suffix="${entry#"$version"-}"
if [ "$suffix" = "$entry" ] || ! is_name_safe "$suffix" || [[ "$entry" = *[!A-Za-z0-9._-]* ]]; then
  echo "pyenv-binary: invalid entry name \`$entry'" >&2
  exit 1
fi

if command -v sha256sum >/dev/null 2>&1; then
  checksum="$(sha256sum "$definition")"; checksum="${checksum%% *}"
elif command -v shasum >/dev/null 2>&1; then
  checksum="$(shasum -a 256 "$definition")"; checksum="${checksum%% *}"
else
  echo "pyenv-binary: need sha256sum or shasum to checksum the definition" >&2
  exit 1
fi
mkdir -p "$records"
record="$records/$version"
tempfile="$(mktemp "$record.XXXXXX")"
trap 'rm -f "$tempfile"' EXIT

if [ -e "$record" ]; then
  awk -F '\t' -v suffix="$suffix" -v checksum="$checksum" '
    $1 == suffix { $0 = suffix "\t" checksum; found = 1 }
    { print }
    END { if (!found) print suffix "\t" checksum }
  ' "$record" > "$tempfile"
else
  printf '%s\t%s\n' "$suffix" "$checksum" > "$tempfile"
fi
mv "$tempfile" "$record"
echo "$checksum"
