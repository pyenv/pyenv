#!/usr/bin/env bash
# Summary: Explain how the current Ruby version is set
set -e
[ -n "$RBENV_DEBUG" ] && set -x

unset RBENV_VERSION_ORIGIN

IFS=$'\n' read -d '' -r -a scripts <<<"$(rbenv-hooks version-origin)" || true
for script in "${scripts[@]}"; do
  # shellcheck disable=SC1090
  source "$script"
done

if [ -n "$RBENV_VERSION_ORIGIN" ]; then
  echo "$RBENV_VERSION_ORIGIN"
elif [ -n "$RBENV_VERSION" ]; then
  echo "RBENV_VERSION environment variable"
else
  rbenv-version-file
fi
