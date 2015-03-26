# python-build

python-build is a [pyenv](https://github.com/yyuu/pyenv) plugin
that provides a `pyenv install` command to compile and install
different versions of Python on UNIX-like systems.

You can also use python-build without pyenv in environments where you
need precise control over Python version installation.


## Installation

### Installing as an pyenv plugin (recommended)

You need nothing to do since python-build is bundled with pyenv by
default.

### Installing as a standalone program (advanced)

Installing python-build as a standalone program will give you access to
the `python-build` command for precise control over Python version
installation. If you have pyenv installed, you will also be able to
use the `pyenv install` command.

    git clone git://github.com/yyuu/pyenv.git
    cd pyenv/plugins/python-build
    ./install.sh

This will install python-build into `/usr/local`. If you do not have
write permission to `/usr/local`, you will need to run `sudo
./install.sh` instead. You can install to a different prefix by
setting the `PREFIX` environment variable.

To update python-build after it has been installed, run `git pull` in
your cloned copy of the repository, then re-run the install script.


## Usage

### Using `pyenv install` with pyenv

To install a Python version for use with pyenv, run `pyenv install` with
the exact name of the version you want to install. For example,

    pyenv install 2.7.4

Python versions will be installed into a directory of the same name
under `~/.pyenv/versions`.

To see a list of all available Python versions, run `pyenv install --list`.
You may also tab-complete available Python
versions if your pyenv installation is properly configured.

### Using `python-build` standalone

If you have installed python-build as a standalone program, you can use
the `python-build` command to compile and install Python versions into
specific locations.

Run the `python-build` command with the exact name of the version you
want to install and the full path where you want to install it. For
example,

    python-build 2.7.4 ~/local/python-2.7.4

To see a list of all available Python versions, run `python-build
--definitions`.

Pass the `-v` or `--verbose` flag to `python-build` as the first
argument to see what's happening under the hood.

### Custom definitions

Both `pyenv install` and `python-build` accept a path to a custom
definition file in place of a version name. Custom definitions let you
develop and install versions of Python that are not yet supported by
python-build.

See the [python-build built-in
definitions](https://github.com/yyuu/pyenv/tree/master/plugins/python-build/share/python-build)
as a starting point for custom definition files.

### Special environment variables

You can set certain environment variables to control the build
process.

* `TMPDIR` sets the location where python-build stores temporary files.
* `PYTHON_BUILD_BUILD_PATH` sets the location in which sources are
  downloaded and built. By default, this is a subdirectory of
  `TMPDIR`.
* `PYTHON_BUILD_CACHE_PATH`, if set, specifies a directory to use for
  caching downloaded package files.
* `PYTHON_BUILD_MIRROR_URL` overrides the default mirror URL root to one
  of your choosing.
* `PYTHON_BUILD_SKIP_MIRROR`, if set, forces python-build to download
  packages from their original source URLs instead of using a mirror.
* `CC` sets the path to the C compiler.
* `CONFIGURE_OPTS` lets you pass additional options to `./configure`.
* `MAKE` lets you override the command to use for `make`. Useful for
  specifying GNU make (`gmake`) on some systems.
* `MAKE_OPTS` (or `MAKEOPTS`) lets you pass additional options to
  `make`.
* `PYTHON_CONFIGURE_OPTS` and `PYTHON_MAKE_OPTS` allow you to specify
  configure and make options for buildling CPython. These variables will
  be passed to Python only, not any dependent packages (e.g. libyaml).

### Building as `--enable-shared`

You can build CPython with `--enable-shared` to install a version with
shared object.

If `--enabled-shared` was found in `PYTHON_CONFIGURE_OPTS` or `CONFIGURE_OPTS`,
`python-build` will automatically set `RPATH` to the pyenv's prefix directory.
This means you don't have to set `LD_LIBRARY_PATH` or `DYLD_LIBRARY_PATH` for
the version(s) installed with `--enable-shared`.

```sh
$ env PYTHON_CONFIGURE_OPTS="--enable-shared` pyenv install 2.7.9
```

### Checksum verification

If you have the `shasum`, `openssl`, or `sha256sum` tool installed,
python-build will automatically verify the SHA2 checksum of each
downloaded package before installing it.

Checksums are optional and specified as anchors on the package URL in
each definition. (All bundled definitions include checksums.)

### Package download mirrors

python-build will first attempt to download package files from a mirror
hosted on Amazon CloudFront. If a package is not available on the
mirror, if the mirror is down, or if the download is corrupt,
python-build will fall back to the official URL specified in the
defintion file.

You can point python-build to another mirror by specifying the
`PYTHON_BUILD_MIRROR_URL` environment variable--useful if you'd like to
run your own local mirror, for example. Package mirror URLs are
constructed by joining this variable with the SHA2 checksum of the
package file.

If you don't have an SHA2 program installed, python-build will skip the
download mirror and use official URLs instead. You can force
python-build to bypass the mirror by setting the
`PYTHON_BUILD_SKIP_MIRROR` environment variable.

The official python-build download mirror is provided by [Git Hub Pages](http://yyuu.github.io/pythons/).

### Package download caching

You can instruct python-build to keep a local cache of downloaded
package files by setting the `PYTHON_BUILD_CACHE_PATH` environment
variable. When set, package files will be kept in this directory after
the first successful download and reused by subsequent invocations of
`python-build` and `pyenv install`.

The `pyenv install` command defaults this path to `~/.pyenv/cache`, so
in most cases you can enable download caching simply by creating that
directory.

### Keeping the build directory after installation

Both `python-build` and `pyenv install` accept the `-k` or `--keep`
flag, which tells python-build to keep the downloaded source after
installation. This can be useful if you need to use `gdb` and
`memprof` with Python.

Source code will be kept in a parallel directory tree
`~/.pyenv/sources` when using `--keep` with the `pyenv install`
command. You should specify the location of the source code with the
`PYTHON_BUILD_BUILD_PATH` environment variable when using `--keep` with
`python-build`.


## Getting Help

Please see the [python-build
wiki](https://github.com/yyuu/pyenv/wiki) for solutions to
common problems.

If you can't find an answer on the wiki, open an issue on the [issue
tracker](https://github.com/yyuu/pyenv/issues). Be sure to
include the full build log for build failures.


### License

(The MIT License)

* Copyright (c) 2013 Yamashita, Yuu
* Copyright (c) 2012 Sam Stephenson

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
