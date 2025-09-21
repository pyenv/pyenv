#!/usr/bin/env bash
set -e

if [ -n "$PYENV_NATIVE_EXT" ]; then
  src/configure
  make -C src
fi

exec bats ${CI:+--tap} ${BATS_TEST_FILTER:+--filter "${BATS_TEST_FILTER}"} test/${BATS_FILE_FILTER}
