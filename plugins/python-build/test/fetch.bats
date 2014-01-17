#!/usr/bin/env bats

load test_helper
export PYTHON_BUILD_SKIP_MIRROR=1
export PYTHON_BUILD_CACHE_PATH=

@test "failed download displays error message" {
  stub curl false

  install_fixture definitions/without-checksum
  assert_failure
  assert_output_contains "> http://example.com/packages/package-1.0.0.tar.gz"
  assert_output_contains "error: failed to download package-1.0.0.tar.gz"
}
