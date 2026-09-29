load test_helper

@test "status assertions reject unexpected exit codes" {
  run false
  ! assert_success ""
  run true
  ! assert_failure ""
}
