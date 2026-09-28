load test_helper

@test "assert_failure rejects successful status" {
  run true
  ! assert_failure
}
