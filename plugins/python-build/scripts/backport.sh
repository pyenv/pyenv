# source this in Bash
# cd to git repo of CPython

_python_build_dir=$(cd "${BASH_SOURCE%/*}/.."; pwd -P)

backport() {
  [[ $# -lt 2 ]] && { echo "usage: $FUNCNAME <commit_hash> <CPython version>..." >&2; return 1; }
  
  (set -euxo pipefail
  sha="${1:?}"
  shift
  for b; do
    git checkout "Branch_v$b" || git checkout -b "Branch_v$b" "v$b"
    git cherry-pick "$sha"
    git format-patch -1
    patch_dir="$_python_build_dir/share/python-build/$b/Python-$b"
    shopt -s nullglob
    pp=("$patch_dir"/*.patch)
    patch_offset=${#pp[@]}
    shopt -u nullglob
    unset pp
    mkdir -p "$patch_dir"
    for f in *.patch; do
      mv "$f" "$patch_dir/$(printf '%04d' $((${f::4}+patch_offset)))${f:4}"
    done
  done)
}