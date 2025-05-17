# python-build

python-build is a [pyenv](https://github.com/pyenv/pyenv) plugin that
provides a `pyenv install` command to compile and install different versions
of Python on UNIX-like systems.

You can also use python-build without pyenv in environments where you need
precise control over Python version installation.

See the [list of releases](https://github.com/pyenv/pyenv/releases)
for changes in each version.


## Installation

### Installing as a pyenv plugin (recommended)

Since python-build is bundled with pyenv by
default, you do not need to do anything.

### Installing as a standalone program (advanced)

Installing python-build as a standalone program will give you access to the
`python-build` command for precise control over Python version installation. If you
have pyenv installed, you will also be able to use the `pyenv install` command.

    git clone https://github.com/pyenv/pyenv.git
    cd pyenv/plugins/python-build
    ./install.sh

This will install python-build into `/usr/local`. If you do not have write
permission to `/usr/local`, you will need to run `sudo ./install.sh` instead.
You can install to a different prefix by setting the `PREFIX` environment
variable.

To update python-build after it has been installed, run `git pull` in your cloned
copy of the repository, then re-run the install script.

### Installing with Homebrew (for OS X users)

Mac OS X users can install python-build with the [Homebrew](http://brew.sh)
package manager. This will give you access to the `python-build` command. If you
have pyenv installed, you will also be able to use the `pyenv install` command.

*This is the recommended method of installation if you installed pyenv with
Homebrew.*

    brew install pyenv

Or, if you would like to install the latest development release:

    brew install --HEAD pyenv


## Usage

Before you begin, you should ensure that your build environment has the proper
system dependencies for compiling the wanted Python Version (see our [recommendations](https://github.com/pyenv/pyenv/wiki#suggested-build-environment)).

### Using `pyenv install` with pyenv

To install a Python version for use with pyenv, run `pyenv install` with
exact name of the version you want to install. For example,

    pyenv install 2.7.4

Python versions will be installed into a directory of the same name under
`~/.pyenv/versions`.

To see a list of all available Python versions, run `pyenv install --list`. You
may also tab-complete available Python versions if your pyenv installation is
properly configured.

### Using `python-build` standalone

If you have installed python-build as a standalone program, you can use the
`python-build` command to compile and install Python versions into specific
locations.

Run the `python-build` command with the exact name of the version you want to
install and the full path where you want to install it. For example,

    python-build 2.7.4 ~/local/python-2.7.4

To see a list of all available Python versions, run `python-build --definitions`.

Pass the `-v` or `--verbose` flag to `python-build` as the first argument to see
what's happening under the hood.

### Custom definitions

Both `pyenv install` and `python-build` accept a path to a custom definition file
in place of a version name. Custom definitions let you develop and install
versions of Python that are not yet supported by python-build.

See the [python-build built-in definitions](https://github.com/pyenv/pyenv/tree/master/plugins/python-build/share/python-build) as a starting point for
custom definition files.

#### Adding definitions with a Pyenv plugin

You can add your own definitions with a [Pyenv plugin](https://github.com/pyenv/pyenv?tab=readme-ov-file#pyenv-plugins) by placing them under
`$PYENV_ROOT/plugins/your_plugin_name/share/python-build`.

### Default build configuration

Without the user customizing the build with environment variables (see below),
`python-build` builds Python with mostly default Configure options
to maintain the principle of the least surprise.

The exceptions -- non-default options that are set by default -- are listed below:

| Option/Behavior | Rationale |
|-----------------|-----------|
| `--enable-shared` is on by default. Pass `--disable-shared` to Configure options to override | The official CPython Docker image uses it. It's required to embed CPython. |
| argument to `--enable-universalsdk` is ignored and set to `/` | 
| `--with-universal-archs` defaults to `universal2` on ARM64 architecture | the only dual-architecture Macs in use today are Apple Silicon which can only build that one |
| argument to `--enable-framework` is ignored and set to a specific value | CPython's build logic requires a very specific argument to avoid installing the `Applications` part globally |
| argument to `--enable-unicode` in non-MacOS is overridden to `ucs4` for 2.x-3.3 |
| `MACOSX_DEPLOYMENT_TARGET` defaults to the running MacOS version |


#### Integration with 3rd-party package ecosystems

##### Homebrew

Homebrew is used to find dependency packages if `brew` is found on `PATH`:
* In MacOS, or
* If the running Pyenv itself is installed with Homebrew

Set `PYTHON_BUILD_USE_HOMEBREW` or `PYTHON_BUILD_SKIP_HOMEBREW` to override this default.

When Homebrew is used, its `include` and `lib` paths are added to compiler search path (the latter is also set as `rpath`),
and also Python dependencies that are typically keg-only are searched for in the Homebrew installation and added individually.

**NOTE:** Homebrew is not used in Linux by default because it's rolling-release which causes a problem.
Upgrading a Python dependency in Homebrew to a new major version (that `brew` does without warning)
would break all Pyenv-managed installations that depend on it.
You can use a [community plugin `fix-version`](https://github.com/pyenv/pyenv/wiki/Plugins#community-plugins)
to fix installations in such a case.

##### Portage

In FreeBSD, if `pkg` is on PATH, Ports are searched for some dependencies that Configure is known to not search for via `pkg-config`.
(Later versions of CPython search for more packages via `pkg-config` so this may eventually become redundant.)


### Special environment variables

You can set certain environment variables to control the build process.

* `TMPDIR` sets the location where python-build stores temporary files.
* `PYTHON_BUILD_BUILD_PATH` sets the location in which sources are downloaded and
  built. By default, this is a subdirectory of `TMPDIR`.
* `PYTHON_BUILD_CACHE_PATH`, if set, specifies a directory to use for caching
  downloaded package files.
* `PYTHON_BUILD_MIRROR_URL` overrides the default mirror URL root to one of your
  choosing.
* `PYTHON_BUILD_MIRROR_URL_SKIP_CHECKSUM`, if set, does not append the SHA2
  checksum of the file to the mirror URL.
* `PYTHON_BUILD_SKIP_MIRROR`, if set, forces python-build to download packages from
  their original source URLs instead of using a mirror.
* `PYTHON_BUILD_HTTP_CLIENT`, explicitly specify the HTTP client type to use. `aria2`, `curl` and `wget` are the supported values and by default, are searched in that order.
* `PYTHON_BUILD_CURL_OPTS`, `PYTHON_BUILD_WGET_OPTS`, `PYTHON_BUILD_ARIA2_OPTS` pass additional parameters to the corresponding HTTP client.
* `PYTHON_BUILD_SKIP_HOMEBREW`, if set, will not search for libraries installed by Homebrew when it would normally will.
* `PYTHON_BUILD_USE_HOMEBREW`, if set, will search for libraries installed by Homebrew when it would normally not.
* `PYTHON_BUILD_HOMEBREW_OPENSSL_FORMULA`, override the Homebrew OpenSSL formula to use.
* `PYTHON_BUILD_ROOT` overrides the default location from where build definitions
  in `share/python-build/` are looked up.
* `PYTHON_BUILD_DEFINITIONS` can be a list of colon-separated paths that get
  additionally searched when looking up build definitions.
* `CC` sets the path to the C compiler.
* `CONFIGURE_OPTS` lets you pass additional options to `./configure`.
* `MAKE` lets you override the command to use for `make`. Useful for specifying
  GNU make (`gmake`) on some systems.
* `MAKE_OPTS` (or `MAKEOPTS`) lets you pass additional options to `make`.
* `MAKE_INSTALL_OPTS` lets you pass additional options to `make install`.
* `<PACKAGE>_CFLAGS`, `<PACKAGE>_CPPFLAGS`, `<PACKAGE>_LDFLAGS` let you pass additional options to `CFLAGS`/`CPPFLAGS`/`LDFLAGS` specifically for building `<package>` (Python itself or a dependency library) from source as part of the build script. `<PACKAGE>` should be a capitalized name of the package without version (technically, capitalized first argument to `install_package` without version). E.g. for CPython, it's "`PYTHON`", for Readline, "`READLINE`", for PyPy (only applies when building it from source), "`PYPY`". Check the source of the build script you're using if unsure.
* `<PACKAGE>_CONFIGURE_OPTS`, `<PACKAGE>_MAKE_OPTS`, `<PACKAGE>_MAKE_INSTALL_OPTS`, `<PACKAGE>_MAKE_INSTALL_TARGET` allow
  you to specify configure and make options for building `<package>` (same as above). "Make install target" would replace "`install`" in the `make install` invocation.

### Applying patches to Python before compiling

Both `pyenv install` and `python-build` support the `--patch` (`-p`) flag that
signals that a patch from stdin should be applied to Python, Jython or PyPy
source code before the `./configure` and compilation steps.

Example usage:

```sh
# applying a single patch
$ pyenv install --patch 2.7.10 < /path/to/python.patch

# applying a patch from HTTP
$ pyenv install --patch 2.7.10 < <(curl -sSL http://git.io/python.patch)

# applying multiple patches
$ cat fix1.patch fix2.patch | pyenv install --patch 2.7.10
```


### Building for maximum performance

Building CPython with `--enable-optimizations` will result in a faster
interpreter at the cost of significantly longer build times. Most notably, this
enables PGO (profile guided optimization). While your mileage may vary, it is
common for performance improvement from this to be in the ballpark of 30%.

```sh
env PYTHON_CONFIGURE_OPTS='--enable-optimizations --with-lto' PYTHON_CFLAGS='-march=native -mtune=native' pyenv install --verbose 3.6.0
```

You can also customize the task used for profile guided optimization by setting
the `PROFILE_TASK` environment variable, for instance, `PROFILE_TASK='-m
test.regrtest --pgo -j0'` will run much faster than the default task.

### Checksum verification

If you have the `shasum`, `openssl`, or `sha256sum` tool installed, python-build will
automatically verify the SHA2 checksum of each downloaded package before
installing it.

Checksums are optional and specified as anchors on the package URL in each
definition. (All bundled definitions include checksums.)

### Package download mirrors

python-build will first attempt to download package files from a mirror hosted on
GitHub Pages. If this fails, it will fall back to the
official URL specified in the definition file.

You can point python-build to another mirror by specifying the
`PYTHON_BUILD_MIRROR_URL` environment variable.

Package mirror URLs are constructed by joining
`$PYTHON_BUILD_MIRROR_URL` with the SHA2 checksum of the package file as specified in the URL
in the installation script (the part after the hash sign). E.g.:

```
https://mycache.example.com/0419e9085bf51b7a672009b3f50dbf1859acdf18ba725d0ec19aa5c8503f0ea3
```

If you have replicated the directory structure of an official site, the easiest way to adapt
would be to make symlinks at the mirror's root:

```
0419e9085bf51b7a672009b3f50dbf1859acdf18ba725d0ec19aa5c8503f0ea3 -> 3.10.10/Python-3.10.10.tar.xz
```

The rationale is to abstract away difference between directory structures of sites
of various Python flavors and their occasional changes as well as to accomodate
people who only wish to cache some select downloads. This also allows to mirror multiple sites at once.

If the mirror being used does not have the same checksum (*e.g.* with a
pull-through cache like Artifactory), you can set the
`PYTHON_BUILD_MIRROR_URL_SKIP_CHECKSUM` environment variable.

If you don't have an SHA2 program installed, python-build will skip the download
mirror and use official URLs instead. You can force python-build to bypass the
mirror by setting the `PYTHON_BUILD_SKIP_MIRROR` environment variable.

The official python-build download mirror is provided by
[GitHub Pages](http://yyuu.github.io/pythons/).

### Package download cache

Python-build will keep a cache of downloaded package files
at the location specified by the `PYTHON_BUILD_CACHE_PATH` environment variable
if it exists. The default is `~/.pyenv/cache`, so you can
enable caching by just creating that directory.

The name of the would-be cached file is reported by Pyenv in the "Downloading &lt;filename&gt;..." message.
It's possible to warm up the cache by manually putting the file there under an appropriate name.

### Keeping the build directory after installation

Both `python-build` and `pyenv install` accept the `-k` or `--keep` flag, which
tells python-build to keep the downloaded source after installation. This can be
useful if you need to use `gdb` and `memprof` with Python.

Source code will be kept in a parallel directory tree `~/.pyenv/sources` when
using `--keep` with the `pyenv install` command. You should specify the
location of the source code with the `PYTHON_BUILD_BUILD_PATH` environment
variable when using `--keep` with `python-build`.


## Getting Help

Please see the [pyenv wiki](https://github.com/pyenv/pyenv/wiki) for solutions to common problems.

[wiki]: https://github.com/pyenv/pyenv/wiki

If you can't find an answer on the wiki, open an issue on the [issue
tracker](https://github.com/pyenv/pyenv/issues). Be sure to include
the full build log for build failures.

## Contributing

### Testing new python versions

If you are contributing a new python version for python-build,
you can test the build in a [docker](https://www.docker.com/) container based on Ubuntu 18.04.

With docker installed:

```sh
docker build -t my_container .
docker run my_container pyenv install <my_version>
```

To enter a shell which will allow you to build and then test a python version,
replace the second line with

```sh
docker run -it my_container
```

The container will need to be rebuilt whenever you change the repo,
but after the first build, this will be very fast,
as the layer including the build dependencies will be cached.

Changes made inside the container will not be persisted.

To test *all* new versions since a particular revision (e.g. `master`), `cd` to the root of your `pyenv` repo, and run this script:

```sh
set -e
set -x

docker build -t pyenv-test-container .

git diff --name-only master \
  | grep '^plugins/python-build/share/python-build/' \
  | awk -F '/' '{print $NF}' \
  | xargs -I _ docker run pyenv-test-container pyenv install _
```

- Build the docker image with the **t**ag pyenv-test-container
- Look for the names files changed since revision `master`
- Filter out any which don't live where python-build keeps its build scripts
- Look only at the file name (i.e. the python version name)
- Run a new docker container for each, building that version

