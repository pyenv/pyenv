## Version History

#### 0.4.0-20131023

* pyenv: Improved [fish shell](http://fishshell.com/) support
* python-build: Add new PyPy releases; pypy-2.1, pypy-2.1-src, pypy3-2.1-beta1, pypy3-2.1-beta1-src
* python-build: Add ancient versions; 2.4, 2.4.1, 2.4.3, 2.4.4 and 2.4.5
* python-build: Add alpha releases; 3.4.0a2, 3.4.0a3, 3.4.0a4
* python-build: Update default pip version (1.4 -> 1.4.1)
* python-build: Update default setuptools version (0.9.7 -> 1.1.6)

#### 0.4.0-20130726

* pyenv: Fix minor issue of variable scope in `pyenv versions` 
* python-build: Update base version to ruby-build v20130628
* python-build: Use brew managed OpenSSL and GNU Readline if they are available
* python-build: Fix build of CPython 3.3+ on OS X (#29)
* python-build: Fix build of native modules of CPython 2.5 on OS X (#33)
* python-build: Fix build of CPython 2.6+ on openSUSE (#36)
* python-build: Add ancient versions; 2.4.2 and 2.4.6. The build might be broken. (#37)
* python-build: Update default pip version (1.3.1 -> 1.4)
* python-build: Update default setuptools version (0.7.2 -> 0.9.7)

#### 0.4.0-20130613

* pyenv: Changed versioning schema. There are two parts; the former is the base rbenv version, and the latter is the date of release.
* python-build: Add `--debug` option to build CPython with debug symbols. (#11)
* python-build: Add new CPython versions: 2.7.4, 2.7.5, 3.2.4, 3.2.5, 3.3.1, 3.3.2 (#12, #17)
* python-build: Add `svnversion` patch for old CPython versions (#14)
* python-build: Enable mirror by default for faster download (#20)
* python-build: Add `OPENSSL_NO_SSL2` patch for old CPython versions (#22)
* python-build: Install GNU Readline on Darwin if the system one is broken (#23)
* python-build: Bundle patches in `${PYTHON_BUILD_ROOT}/share/python-build/patches` and improve patching mechanism (`apply_patches`).
* python-build: Verify native extensions after building. (`build_package_verify_py*`)
* python-build: Add `install_hg` to install package from Mercurial repository
* python-build: Support building Jython and PyPy.
* python-build: Add new CPython development versions: 2.6-dev, 2.7-dev, 3.1-dev, 3.2-dev, 3.3-dev, 3.4-dev
* python-build: Add new Jython development versions: jython-2.5.4-rc1, jython-2.5-dev, jython-2.7-beta1, jython-dev
* python-build: Add new PyPy versions: pypy-1.5{,-src}, pypy-1.6, pypy-1.7, pypy-2.0{,-src}, pypy-2.0.1{,-src}, pypy-2.0.2{,-src}
* python-build: Add new PyPy development versions: pypy-1.7-dev, pypy-1.8-dev, pypy-1.9-dev, pypy-2.0-dev, pypy-dev, pypy-py3k-dev
* python-build: Add new Stackless development versions: stackless-2.7-dev, stackless-3.2-dev, stackless-3.3-dev, stackless-dev
* python-build: Update default pip version (1.2.1 -> 1.3.1)
* python-build: Update default setuptools version (0.6.34 (distribute) -> 0.7.2 ([new setuptools](https://bitbucket.org/pypa/setuptools)))

#### 0.2.0 (February 18, 2013)

* Import changes from rbenv 0.4.0.

#### 0.1.2 (October 23, 2012)

* Add push/pop for version stack management.
* Support multiple versions via environment variable.
* Now GCC is not a requirement to build CPython and Stackless.

#### 0.1.1 (September 3, 2012)

* Support multiple versions of Python at a time.

#### 0.1.0 (August 31, 2012)

* Initial public release.
