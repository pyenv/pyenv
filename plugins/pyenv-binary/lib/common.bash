# A name must work as a single path component and as a value in line-based
# metadata.
is_name_safe() {
  case "$1" in
  "" | */* | .. | . | *[[:cntrl:]]* ) return 1 ;;
  esac
}
