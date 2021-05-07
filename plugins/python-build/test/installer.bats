#!/usr/bin/env bats

load test_helper

@test "installs python-build into PREFIX" {
  cd "$TMP"
  PREFIX="${PWD}/usr" run "${BATS_TEST_DIRNAME}/../install.sh"
  assert_success ""

  cd usr

  assert [ -x bin/python-build ]
  assert [ -x bin/pyenv-install ]
  assert [ -x bin/pyenv-uninstall ]

  assert [ -e share/python-build/2.7.2 ]
  assert [ -e share/python-build/pypy-2.0 ]
}

@test "build definitions don't have the executable bit" {
  cd "$TMP"
  PREFIX="${PWD}/usr" run "${BATS_TEST_DIRNAME}/../install.sh"
  assert_success ""

  run $BASH -c 'ls -l usr/share/python-build | tail -2 | cut -c1-10'
  assert_output <<OUT
-rw-r--r--
-rw-r--r--
OUT
}

@test "overwrites old installation" {
  cd "$TMP"
  mkdir -p bin share/python-build
  touch bin/python-build
  touch share/python-build/2.7.2

  PREFIX="$PWD" run "${BATS_TEST_DIRNAME}/../install.sh"
  assert_success ""

  assert [ -x bin/python-build ]
  run grep "install_package" share/python-build/2.7.2
  assert_success
}

@test "unrelated files are untouched" {
  cd "$TMP"
  mkdir -p bin share/bananas
  chmod g-w bin
  touch bin/bananas
  touch share/bananas/docs

  PREFIX="$PWD" run "${BATS_TEST_DIRNAME}/../install.sh"
  assert_success ""

  assert [ -e bin/bananas ]
  assert [ -e share/bananas/docs ]

  run ls -ld bin
  assert_equal "-" "${output:5:1}"
}
