#!/usr/bin/env bash
# Summary: Show the current Ruby version and its origin
#
# Shows the currently selected Ruby version and how it was
# selected. To obtain only the version string, use `rbenv
# version-name'.

set -e
[ -n "$RBENV_DEBUG" ] && set -x

version_name="$(rbenv-version-name)"
version_origin="$(rbenv-version-origin)"

if [ "$version_origin" = "${RBENV_ROOT}/version" ] && [ ! -e "$version_origin" ]; then
  echo "$version_name"
else
  echo "$version_name (set by $version_origin)"
fi
