#!/usr/bin/env bats

load test_helper
export PYTHON_BUILD_CACHE_PATH="$TMP/cache"
export MAKE=make
export MAKE_OPTS="-j 2"
export CC=cc
export -n PYTHON_CONFIGURE_OPTS

setup() {
  mkdir -p "$INSTALL_ROOT"
  stub md5 false
  stub curl false
}

executable() {
  local file="$1"
  mkdir -p "${file%/*}"
  cat > "$file"
  chmod +x "$file"
}

cached_tarball() {
  mkdir -p "$PYTHON_BUILD_CACHE_PATH"
  pushd "$PYTHON_BUILD_CACHE_PATH" >/dev/null
  tarball "$@"
  popd >/dev/null
}

tarball() {
  local name="$1"
  local path="$PWD/$name"
  local configure="$path/${2:-configure}"
  shift 1

  executable "$configure" <<OUT
#!$BASH
echo "$name: CFLAGS=\\"\$CFLAGS\\" CPPFLAGS=\\"\$CPPFLAGS\\" LDFLAGS=\\"\$LDFLAGS\\" PKG_CONFIG_PATH=\\"\$PKG_CONFIG_PATH\\"" >> build.log
echo "$name: \$@" \${PYTHONOPT:+PYTHONOPT=\$PYTHONOPT} >> build.log
OUT

  for file; do
    mkdir -p "$(dirname "${path}/${file}")"
    touch "${path}/${file}"
  done

  tar czf "${path}.tar.gz" -C "${path%/*}" "$name"
}

stub_make_install() {
  stub "$MAKE" \
    " : echo \"$MAKE \$@\" >> build.log" \
    "${1:-install} : echo \"$MAKE \$@\" >> build.log && cat build.log >> '$INSTALL_ROOT/build.log'"
}

assert_build_log() {
  run cat "$INSTALL_ROOT/build.log"
  assert_output
}

@test "yaml is installed for python" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "Python-3.6.2"

  for i in {1..10}; do stub uname '-s : echo Linux'; done
  stub brew false
  stub_make_install
  stub_make_install

  install_fixture definitions/needs-yaml
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
yaml-0.1.6: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "apply global and package-specific flags, package flags come later to have precedence" {
  local yaml_configure="yaml_configure"

  export YAML_CONFIGURE="./$yaml_configure"
  export YAML_PREFIX_PATH=yaml_prefix_path
  export YAML_CONFIGURE_OPTS="yaml_configure_opt1 yaml_configure_opt2"
  export YAML_MAKE_OPTS="yaml_make_opt1 yaml_make_opt2"
  export YAML_CFLAGS="yaml_cflag1 yaml_cflag2"
  export YAML_CPPFLAGS="yaml_cppflag1 yaml_cppflag2"
  export YAML_LDFLAGS="yaml_ldflag1 yaml_ldflag2"
  export CONFIGURE_OPTS="configure_opt1 configure_opt2"
  export MAKE_OPTS="make_opt1 make_opt2"
  export MAKE_INSTALL_OPTS="make_install_opt1 make_install_opt2"
  export PYTHON_MAKE_INSTALL_OPTS="python_make_install_opt1 python_make_install_opt2"
  export PYTHON_MAKE_INSTALL_TARGET="python_make_install_target"

  cached_tarball "yaml-0.1.6" "$yaml_configure"
  cached_tarball "Python-3.6.2"

  for i in {1..10}; do stub uname '-s : echo Linux'; done
  stub brew false
  stub_make_install
  stub_make_install "$PYTHON_MAKE_INSTALL_TARGET"
  

  install_fixture definitions/needs-yaml
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
yaml-0.1.6: CFLAGS="yaml_cflag1 yaml_cflag2" CPPFLAGS="-I${TMP}/install/include yaml_cppflag1 yaml_cppflag2" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib yaml_ldflag1 yaml_ldflag2" PKG_CONFIG_PATH=""
yaml-0.1.6: --prefix=yaml_prefix_path configure_opt1 configure_opt2 yaml_configure_opt1 yaml_configure_opt2
make make_opt1 make_opt2 yaml_make_opt1 yaml_make_opt2
make install make_install_opt1 make_install_opt2
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib configure_opt1 configure_opt2
make make_opt1 make_opt2
make python_make_install_target make_install_opt1 make_install_opt2 python_make_install_opt1 python_make_install_opt2
OUT
}

@test "apply python patch before building" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "Python-3.6.2"

  for i in {1..10}; do stub uname '-s : echo Linux'; done
  stub brew false
  stub_make_install
  stub_make_install
  stub patch ' : echo patch "$@" | sed -E "s/\.[[:alnum:]]+$/.XXX/" >> build.log'

  TMPDIR="$TMP" install_fixture --patch definitions/needs-yaml <<<""
  assert_success

  unstub uname
  unstub make
  unstub patch

  assert_build_log <<OUT
yaml-0.1.6: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
patch -p0 --force -i $TMP/python-patch.XXX
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "apply python patch from git diff before building" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "Python-3.6.2"

  for i in {1..10}; do stub uname '-s : echo Linux'; done
  stub brew false
  stub_make_install
  stub_make_install
  stub patch ' : echo patch "$@" | sed -E "s/\.[[:alnum:]]+$/.XXX/" >> build.log'

  TMPDIR="$TMP" install_fixture --patch definitions/needs-yaml <<<"diff --git a/script.py"
  assert_success

  unstub uname
  unstub make
  unstub patch

  assert_build_log <<OUT
yaml-0.1.6: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
patch -p1 --force -i $TMP/python-patch.XXX
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "homebrew with uncommon prefix is added to search path" {
  cached_tarball "Python-3.6.2"

  BREW_PREFIX="$TMP/homebrew-prefix"
  mkdir -p "$BREW_PREFIX"

  for i in {1..9}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 1010'; done
  stub brew "--prefix : echo '$BREW_PREFIX'" false
  stub_make_install

  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sw_vers
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include -I$BREW_PREFIX/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib -L$BREW_PREFIX/lib -Wl,-rpath,$BREW_PREFIX/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "yaml is linked from Homebrew" {
  cached_tarball "Python-3.6.2"

  brew_libdir="$TMP/homebrew-yaml"
  mkdir -p "$brew_libdir"

  for i in {1..10}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 1010'; done
  stub brew "--prefix libyaml : echo '$brew_libdir'"
  for i in {1..6}; do stub brew false; done
  stub_make_install

  install_fixture definitions/needs-yaml
  assert_success

  unstub uname
  unstub sw_vers
  unstub brew
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I$brew_libdir/include -I${TMP}/install/include" LDFLAGS="-L$brew_libdir/lib -L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "readline is linked from Homebrew" {
  cached_tarball "Python-3.6.2"

  readline_libdir="$TMP/homebrew-readline"
  mkdir -p "$readline_libdir"
  for i in {1..8}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 1010'; done
  for i in {1..3}; do stub brew false; done
  stub brew "--prefix readline : echo '$readline_libdir'"
  for i in {1..2}; do stub brew false; done
  stub_make_install

  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sw_vers
  unstub brew
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I$readline_libdir/include -I${TMP}/install/include" LDFLAGS="-L$readline_libdir/lib -L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "ncurses is linked from Homebrew" {
  cached_tarball "Python-3.6.2"

  ncurses_libdir="$TMP/homebrew-ncurses"
  mkdir -p "$ncurses_libdir"
  for i in {1..9}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 1010'; done
  for i in {1..4}; do stub brew false; done
  stub brew "--prefix ncurses : echo '$ncurses_libdir'"
  stub brew false
  stub_make_install

  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sw_vers
  unstub brew
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I$ncurses_libdir/include -I${TMP}/install/include" LDFLAGS="-L$ncurses_libdir/lib -L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "openssl is linked from Ports in FreeBSD if present" {
  cached_tarball "Python-3.6.2"

  for i in {1..7}; do stub uname '-s : echo FreeBSD'; done
  stub uname '-r : echo 11.0-RELEASE'
  for i in {1..3}; do stub uname '-s : echo FreeBSD'; done
  stub sysctl '-n hw.ncpu : echo 1'

  stub pkg "info -e openssl : true"
  for in in {1..2}; do stub pkg false; done

  stub_make_install

  export -n MAKE_OPTS
  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make
  unstub pkg
  unstub sysctl

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib --with-openssl=/usr/local
make -j 1
make install
OUT
}

@test "readline and sqlite3 are linked from Ports in FreeBSD" {
  cached_tarball "Python-3.6.2"

  for lib in readline sqlite3; do

    for i in {1..7}; do stub uname '-s : echo FreeBSD'; done
    stub uname '-r : echo 11.0-RELEASE'
    for i in {1..3}; do stub uname '-s : echo FreeBSD'; done
    stub sysctl '-n hw.ncpu : echo 1'

    stub pkg false
    stub pkg "$([[ $lib == readline ]] && echo "info -e $lib : true" || echo false)"
    if [[ $lib == sqlite3 ]]; then stub pkg "info -e $lib : true"; fi

    stub_make_install

    export -n MAKE_OPTS
    run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
    assert_success

    unstub uname
    unstub make
    unstub pkg
    unstub sysctl

    assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include -I/usr/local/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib -L/usr/local/lib -Wl,-rpath,/usr/local/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 1
make install
OUT
    rm "$INSTALL_ROOT/build.log"
  done
}

@test "homebrew is not touched if PYTHON_BUILD_SKIP_HOMEBREW is set" {
  cached_tarball "Python-3.6.2"

  for i in {1..4}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 1010'; done
  stub brew true; brew
  stub_make_install
  export PYTHON_BUILD_SKIP_HOMEBREW=1

  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "homebrew is used in Linux if PYTHON_BUILD_USE_HOMEBREW is set" {
  cached_tarball "Python-3.6.2"

  BREW_PREFIX="$TMP/homebrew-prefix"
  mkdir -p "$BREW_PREFIX"

  for i in {1..4}; do stub uname '-s : echo Linux'; done
  stub brew "--prefix : echo '$BREW_PREFIX'"
  for i in {1..5}; do stub brew false; done
  stub_make_install
  export PYTHON_BUILD_USE_HOMEBREW=1

  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include -I$BREW_PREFIX/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib -L$BREW_PREFIX/lib -Wl,-rpath,$BREW_PREFIX/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "homebrew is used in Linux if Pyenv is installed with Homebrew" {
  cached_tarball "Python-3.6.2"

  BREW_PREFIX="$(type -p python-build)"
  BREW_PREFIX="${BREW_PREFIX%/*}"
  BREW_PREFIX="${BREW_PREFIX%/*}"

  for i in {1..4}; do stub uname '-s : echo Linux'; done
  stub brew "--prefix : echo '$BREW_PREFIX'"
  for i in {1..5}; do stub brew false; done
  stub_make_install
  export PYTHON_BUILD_USE_HOMEBREW=1

  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include -I$BREW_PREFIX/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib -L$BREW_PREFIX/lib -Wl,-rpath,$BREW_PREFIX/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "homebrew is not used in Linux if Pyenv is not installed with Homebrew" {
  cached_tarball "Python-3.6.2"

  BREW_PREFIX="$TMP/homebrew-prefix"
  mkdir -p "$BREW_PREFIX"

  for i in {1..9}; do stub uname '-s : echo Linux'; done
  for i in {1..5}; do stub brew "--prefix : echo '$BREW_PREFIX'"; done
  stub_make_install

  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "readline is not linked from Homebrew when explicitly defined" {
  cached_tarball "Python-3.6.2"

  # python-build
  readline_libdir="$TMP/custom"
  mkdir -p "$readline_libdir/include/readline"
  touch "$readline_libdir/include/readline/rlconf.h"

  for i in {1..8}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 1010'; done

  for i in {1..5}; do stub brew false; done
  stub_make_install

  export PYTHON_CONFIGURE_OPTS="CPPFLAGS=-I$readline_libdir/include LDFLAGS=-L$readline_libdir/lib"
  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sw_vers
  unstub brew
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib CPPFLAGS=-I$readline_libdir/include LDFLAGS=-L$readline_libdir/lib
make -j 2
make install
OUT
}

@test "tcl-tk is linked from Homebrew" {
  cached_tarball "Python-3.6.2"
  tcl_tk_version=8.6
  tcl_tk_libdir="$TMP/homebrew-tcl-tk"
  mkdir -p "$tcl_tk_libdir/lib"
  echo "TCL_VERSION='$tcl_tk_version'" >>"$tcl_tk_libdir/lib/tclConfig.sh"

  for i in {1..9}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 1010'; done

  stub brew false
  stub brew "--prefix tcl-tk@8 : echo '$tcl_tk_libdir'"
  for i in {1..3}; do stub brew false; done

  stub_make_install

  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sw_vers
  unstub brew
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH="${TMP}/homebrew-tcl-tk/lib/pkgconfig"
Python-3.6.2: --prefix=${TMP}/install --enable-shared --libdir=${TMP}/install/lib --with-tcltk-libs=-L${TMP}/homebrew-tcl-tk/lib -ltcl$tcl_tk_version -ltk$tcl_tk_version --with-tcltk-includes=-I${TMP}/homebrew-tcl-tk/include
make -j 2
make install
OUT
}

@test "tcl-tk is not linked from Homebrew when explicitly defined" {
  cached_tarball "Python-3.6.2"

  # python build
  tcl_tk_version_long="8.6.10"
  tcl_tk_version="${tcl_tk_version_long%.*}"

  for i in {1..8}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 1010'; done

  for i in {1..4}; do stub brew false; done
  stub_make_install

  export PYTHON_CONFIGURE_OPTS="--with-tcltk-libs='-L${TMP}/custom-tcl-tk/lib -ltcl$tcl_tk_version -ltk$tcl_tk_version'"
  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sw_vers
  unstub brew
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib --with-tcltk-libs=-L${TMP}/custom-tcl-tk/lib -ltcl8.6 -ltk8.6
make -j 2
make install
OUT
}

@test "tcl-tk is linked from Homebrew via pkgconfig only when envvar is set" {
  cached_tarball "Python-3.6.2"

  for i in {1..9}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 1010'; done

  tcl_tk_libdir="$TMP/homebrew-tcl-tk"
  mkdir -p "$tcl_tk_libdir/lib"

  stub brew false
  stub brew "--prefix tcl-tk@8 : echo '${tcl_tk_libdir}'"
  for i in {1..3}; do stub brew false; done

  stub_make_install

  run_inline_definition <<DEF
export PYTHON_BUILD_TCLTK_USE_PKGCONFIG=1
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sw_vers
  unstub brew
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH="${TMP}/homebrew-tcl-tk/lib/pkgconfig"
Python-3.6.2: --prefix=${TMP}/install --enable-shared --libdir=${TMP}/install/lib
make -j 2
make install
OUT
}
@test "number of CPU cores defaults to 2" {
  cached_tarball "Python-3.6.2"

  for i in {1..10}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 10.10'; done

  stub sysctl false
  stub_make_install

  export -n MAKE_OPTS
  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sw_vers
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "number of CPU cores is detected on Mac" {
  cached_tarball "Python-3.6.2"

  for i in {1..10}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 10.10'; done

  stub sysctl '-n hw.ncpu : echo 4'
  stub_make_install

  export -n MAKE_OPTS
  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sw_vers
  unstub sysctl
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 4
make install
OUT
}

@test "number of CPU cores is detected on FreeBSD" {
  cached_tarball "Python-3.6.2"

  for i in {1..7}; do stub uname '-s : echo FreeBSD'; done
  stub uname '-r : echo 11.0-RELEASE'
  for i in {1..3}; do stub uname '-s : echo FreeBSD'; done
  for i in {1..3}; do stub pkg false; done

  stub sysctl '-n hw.ncpu : echo 1'
  stub_make_install

  export -n MAKE_OPTS
  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub sysctl
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 1
make install
OUT
}

@test "setting PYTHON_MAKE_INSTALL_OPTS to a multi-word string" {
  cached_tarball "Python-3.6.2"

  for i in {1..9}; do stub uname '-s : echo Linux'; done

  stub_make_install

  export PYTHON_MAKE_INSTALL_OPTS="DOGE=\"such wow\""
  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install DOGE="such wow"
OUT
}

@test "--enable-shared is not added if --disable-shared is passed" {
  cached_tarball "Python-3.6.2"

  for i in {1..9}; do stub uname '-s : echo Linux'; done

  stub_make_install

  export PYTHON_CONFIGURE_OPTS='--disable-shared'
  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib --disable-shared
make -j 2
make install
OUT
}

@test "configuring with dSYM in MacOS" {
  cached_tarball "Python-3.6.2"

  for i in {1..10}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 1010'; done
  for i in {1..6}; do stub brew false; done
  stub_make_install

  run_inline_definition <<DEF
export PYTHON_BUILD_CONFIGURE_WITH_DSYMUTIL=1
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub sw_vers
  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=${TMP}/install/lib --with-dsymutil
make -j 2
make install
OUT
}

@test "configuring with dSYM has no effect in non-MacOS" {
  cached_tarball "Python-3.6.2"

  for i in {1..10}; do stub uname '-s : echo Linux'; done
  stub_make_install

  run_inline_definition <<DEF
export PYTHON_BUILD_CONFIGURE_WITH_DSYMUTIL=1
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=${TMP}/install/lib
make -j 2
make install
OUT
}

@test "custom relative install destination" {
  export PYTHON_BUILD_CACHE_PATH="$FIXTURE_ROOT"

  cd "$TMP"
  install_fixture definitions/without-checksum ./here
  assert_success
  assert [ -x ./here/bin/package ]
}

@test "make on FreeBSD 9 defaults to gmake" {
  cached_tarball "Python-3.6.2"

  stub uname "-s : echo FreeBSD" "-r : echo 9.1"
  for i in {1..6}; do stub uname "-s : echo FreeBSD"; done
  stub uname "-r : echo 9.1"
  for i in {1..3}; do stub uname "-s : echo FreeBSD"; done

  MAKE=gmake stub_make_install

  MAKE= install_fixture definitions/vanilla-python
  assert_success

  unstub gmake
  unstub uname
}

@test "make on FreeBSD 10" {
  cached_tarball "Python-3.6.2"

  stub uname "-s : echo FreeBSD" "-r : echo 10.0-RELEASE"
  for i in {1..6}; do stub uname "-s : echo FreeBSD"; done
  stub uname "-r : echo 10.0-RELEASE"
  for i in {1..3}; do stub uname "-s : echo FreeBSD"; done

  stub_make_install

  MAKE= install_fixture definitions/vanilla-python
  assert_success

  unstub uname
}

@test "make on FreeBSD 11" {
  cached_tarball "Python-3.6.2"

  stub uname "-s : echo FreeBSD" "-r : echo 11.0-RELEASE"
  for i in {1..6}; do stub uname "-s : echo FreeBSD"; done
  stub uname "-r : echo 11.0-RELEASE"
  for i in {1..3}; do stub uname "-s : echo FreeBSD"; done

  stub_make_install

  MAKE= install_fixture definitions/vanilla-python
  assert_success

  unstub uname
}

@test "can use PYTHON_CONFIGURE to apply a patch" {
  cached_tarball "Python-3.6.2"

  executable "${TMP}/custom-configure" <<CONF
#!$BASH
apply -p1 -i /my/patch.diff
exec ./configure "\$@"
CONF

  for i in {1..9}; do stub uname '-s : echo Linux'; done
  stub apply 'echo apply "$@" >> build.log'
  stub_make_install

  export PYTHON_CONFIGURE="${TMP}/custom-configure"
  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make
  unstub apply

  assert_build_log <<OUT
apply -p1 -i /my/patch.diff
Python-3.6.2: CFLAGS="" CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "copy strategy forces overwrite" {
  export PYTHON_BUILD_CACHE_PATH="$FIXTURE_ROOT"

  mkdir -p "$INSTALL_ROOT/bin"
  touch "$INSTALL_ROOT/bin/package"
  chmod -w "$INSTALL_ROOT/bin/package"

  install_fixture definitions/without-checksum
  assert_success

  run "$INSTALL_ROOT/bin/package" "world"
  assert_success "hello world"
}

@test "non-writable TMPDIR aborts build" {
  export TMPDIR="${TMP}/build"
  mkdir -p "$TMPDIR"
  chmod -w "$TMPDIR"

  touch "${TMP}/build-definition"
  run python-build "${TMP}/build-definition" "$INSTALL_ROOT"
  assert_failure "python-build: TMPDIR=$TMPDIR is set to a non-accessible location"
}

@test "non-executable TMPDIR aborts build" {
  export TMPDIR="${TMP}/build"
  mkdir -p "$TMPDIR"
  chmod -x "$TMPDIR"

  touch "${TMP}/build-definition"
  run python-build "${TMP}/build-definition" "$INSTALL_ROOT"
  assert_failure "python-build: TMPDIR=$TMPDIR is set to a non-accessible location"
}
