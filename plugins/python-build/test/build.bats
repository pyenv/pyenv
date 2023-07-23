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
  local configure="$path/configure"
  shift 1

  executable "$configure" <<OUT
#!$BASH
echo "$name: CPPFLAGS=\\"\$CPPFLAGS\\" LDFLAGS=\\"\$LDFLAGS\\" PKG_CONFIG_PATH=\\"\$PKG_CONFIG_PATH\\"" >> build.log
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
    "install : echo \"$MAKE \$@\" >> build.log && cat build.log >> '$INSTALL_ROOT/build.log'"
}

assert_build_log() {
  run cat "$INSTALL_ROOT/build.log"
  assert_output
}

@test "yaml is installed for python" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "Python-3.6.2"

  for i in {1..9}; do stub uname '-s : echo Linux'; done
  stub brew false
  stub_make_install
  stub_make_install

  install_fixture definitions/needs-yaml
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
yaml-0.1.6: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "apply python patch before building" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "Python-3.6.2"

  for i in {1..9}; do stub uname '-s : echo Linux'; done
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
yaml-0.1.6: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
patch -p0 --force -i $TMP/python-patch.XXX
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "apply python patch from git diff before building" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "Python-3.6.2"

  for i in {1..9}; do stub uname '-s : echo Linux'; done
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
yaml-0.1.6: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
yaml-0.1.6: --prefix=$INSTALL_ROOT
make -j 2
make install
patch -p1 --force -i $TMP/python-patch.XXX
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "homebrew with uncommon prefix is added to search path" {
  cached_tarball "Python-3.6.2"

  BREW_PREFIX="$TMP/homebrew-prefix"
  mkdir -p "$BREW_PREFIX"

  for i in {1..8}; do stub uname '-s : echo Darwin'; done
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
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include -I$BREW_PREFIX/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib -L$BREW_PREFIX/lib -Wl,-rpath,$BREW_PREFIX/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "yaml is linked from Homebrew" {
  cached_tarball "Python-3.6.2"

  brew_libdir="$TMP/homebrew-yaml"
  mkdir -p "$brew_libdir"

  for i in {1..9}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 1010'; done
  stub brew "--prefix libyaml : echo '$brew_libdir'"
  for i in {1..4}; do stub brew false; done
  stub_make_install

  install_fixture definitions/needs-yaml
  assert_success

  unstub uname
  unstub sw_vers
  unstub brew
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CPPFLAGS="-I$brew_libdir/include -I${TMP}/install/include" LDFLAGS="-L$brew_libdir/lib -L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "yaml is not linked from Homebrew in non-MacOS" {
  cached_tarball "yaml-0.1.6"
  cached_tarball "Python-3.6.2"

  for i in {1..9}; do stub uname '-s : echo Linux'; done
  stub brew true; brew
  stub_make_install
  stub_make_install

  install_fixture definitions/needs-yaml
  assert_success

  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
yaml-0.1.6: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
yaml-0.1.6: --prefix=${TMP}/install
make -j 2
make install
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "readline is linked from Homebrew" {
  cached_tarball "Python-3.6.2"

  readline_libdir="$TMP/homebrew-readline"
  mkdir -p "$readline_libdir"
  for i in {1..7}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 1010'; done
  for i in {1..2}; do stub brew false; done
  stub brew "--prefix readline : echo '$readline_libdir'"
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
Python-3.6.2: CPPFLAGS="-I$readline_libdir/include -I${TMP}/install/include" LDFLAGS="-L$readline_libdir/lib -L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "openssl is linked from Ports in FreeBSD if present" {
  cached_tarball "Python-3.6.2"

  for i in {1..7}; do stub uname '-s : echo FreeBSD'; done
  stub uname '-r : echo 11.0-RELEASE'
  for i in {1..2}; do stub uname '-s : echo FreeBSD'; done
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
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
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
    for i in {1..2}; do stub uname '-s : echo FreeBSD'; done
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
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include -I/usr/local/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib -L/usr/local/lib -Wl,-rpath,/usr/local/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 1
make install
OUT
    rm "$INSTALL_ROOT/build.log"
  done
}

@test "no library searches performed during normal operation touch homebrew in non-MacOS" {
  cached_tarball "Python-3.6.2"

  for i in {1..8}; do stub uname '-s : echo Linux'; done
  stub brew true; brew
  stub_make_install

  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub brew
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "no library searches performed during normal operation touch homebrew if envvar is set" {
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
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
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

  for i in {1..7}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 1010'; done

  for i in {1..3}; do stub brew false; done
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
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
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
  for i in {1..2}; do stub brew "--prefix tcl-tk : echo '$tcl_tk_libdir'"; done
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
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH="${TMP}/homebrew-tcl-tk/lib/pkgconfig"
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
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
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
  for i in {1..2}; do stub brew "--prefix tcl-tk : echo '${tcl_tk_libdir}'"; done
  for i in {1..2}; do stub brew false; done

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
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH="${TMP}/homebrew-tcl-tk/lib/pkgconfig"
Python-3.6.2: --prefix=${TMP}/install --enable-shared --libdir=${TMP}/install/lib
make -j 2
make install
OUT
}
@test "number of CPU cores defaults to 2" {
  cached_tarball "Python-3.6.2"

  for i in {1..9}; do stub uname '-s : echo Darwin'; done
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
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install
OUT
}

@test "number of CPU cores is detected on Mac" {
  cached_tarball "Python-3.6.2"

  for i in {1..9}; do stub uname '-s : echo Darwin'; done
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
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 4
make install
OUT
}

@test "number of CPU cores is detected on FreeBSD" {
  cached_tarball "Python-3.6.2"

  for i in {1..7}; do stub uname '-s : echo FreeBSD'; done
  stub uname '-r : echo 11.0-RELEASE'
  for i in {1..2}; do stub uname '-s : echo FreeBSD'; done
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
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 1
make install
OUT
}

@test "setting PYTHON_MAKE_INSTALL_OPTS to a multi-word string" {
  cached_tarball "Python-3.6.2"

  for i in {1..8}; do stub uname '-s : echo Linux'; done

  stub_make_install

  export PYTHON_MAKE_INSTALL_OPTS="DOGE=\"such wow\""
  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib
make -j 2
make install DOGE="such wow"
OUT
}

@test "(PYTHON_)CONFIGURE_OPTS and (PYTHON_)MAKE_OPTS take priority over automatically added options" {
  cached_tarball "Python-3.6.2"

  for i in {1..8}; do stub uname '-s : echo Linux'; done

  stub_make_install

  export CONFIGURE_OPTS="--custom-configure"
  export PYTHON_CONFIGURE_OPTS='--custom-python-configure'
  export MAKE_OPTS="${MAKE_OPTS:+$MAKE_OPTS }--custom-make"
  export PYTHON_MAKE_OPTS="--custom-python-make"
  export PYTHON_MAKE_INSTALL_OPTS="--custom-make-install"
  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=$INSTALL_ROOT/lib --custom-configure --custom-python-configure
make -j 2 --custom-make --custom-python-make
make install --custom-make-install
OUT
}

@test "--enable-shared is not added if --disable-shared is passed" {
  cached_tarball "Python-3.6.2"

  for i in {1..8}; do stub uname '-s : echo Linux'; done

  stub_make_install

  export PYTHON_CONFIGURE_OPTS='--disable-shared'
  run_inline_definition <<DEF
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --libdir=$INSTALL_ROOT/lib --disable-shared
make -j 2
make install
OUT
}

@test "configuring with dSYM in MacOS" {
  cached_tarball "Python-3.6.2"

  for i in {1..9}; do stub uname '-s : echo Darwin'; done
  for i in {1..2}; do stub sw_vers '-productVersion : echo 1010'; done
  for i in {1..4}; do stub brew false; done
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
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
Python-3.6.2: --prefix=$INSTALL_ROOT --enable-shared --libdir=${TMP}/install/lib --with-dsymutil
make -j 2
make install
OUT
}

@test "configuring with dSYM has no effect in non-MacOS" {
  cached_tarball "Python-3.6.2"

  for i in {1..9}; do stub uname '-s : echo Linux'; done
  stub_make_install

  run_inline_definition <<DEF
export PYTHON_BUILD_CONFIGURE_WITH_DSYMUTIL=1
install_package "Python-3.6.2" "http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.gz"
DEF
  assert_success

  unstub uname
  unstub make

  assert_build_log <<OUT
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
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
  for i in {1..2}; do stub uname "-s : echo FreeBSD"; done

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
  for i in {1..2}; do stub uname "-s : echo FreeBSD"; done

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
  for i in {1..2}; do stub uname "-s : echo FreeBSD"; done

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

  for i in {1..8}; do stub uname '-s : echo Linux'; done
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
Python-3.6.2: CPPFLAGS="-I${TMP}/install/include" LDFLAGS="-L${TMP}/install/lib -Wl,-rpath,${TMP}/install/lib" PKG_CONFIG_PATH=""
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

@test "mruby strategy overwrites non-writable files" {
  # nop
}

@test "mruby strategy fetches rake if missing" {
  # nop
}

@test "rbx uses bundle then rake" {
  # nop
}

@test "fixes rbx binstubs" {
  # nop
}

@test "JRuby build" {
  # nop
}

@test "JRuby+Graal does not install launchers" {
  # nop
}

@test "JRuby Java 7 missing" {
  # nop
}

@test "JRuby Java is outdated" {
  # nop
}

@test "JRuby Java 7 up-to-date" {
  # nop
}

@test "Java version string not on first line" {
  # nop
}

@test "Java version string on OpenJDK" {
  # nop
}

@test "JRuby Java 9 version string" {
  # nop
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
