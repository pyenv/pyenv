#!/bin/sh

set -e

if [ -z "${PREFIX}" ]; then
  PREFIX="/usr/local"
fi

BIN_PATH="${PREFIX}/bin"

mkdir -p "${BIN_PATH}"

for file in bin/*; do
  cp "${file}" "${BIN_PATH}"
done

echo "Installed pyenv-version-ext at ${PREFIX}"
