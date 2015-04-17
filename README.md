# Simple Python Version Management: pyenv

[![Build Status](https://travis-ci.org/yyuu/pyenv.svg)](https://travis-ci.org/yyuu/pyenv)

pyenv lets you easily switch between multiple versions of Python. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose
tools that do one thing well.

This project was forked from [rbenv](https://github.com/sstephenson/rbenv) and
[ruby-build](https://github.com/sstephenson/ruby-build), and modified for Python.

<img src="http://gyazo.com/9c829fafdf5e58880c820349c4e9197e.png?1346414267" width="849" height="454" />


### pyenv _does..._

* Let you **change the global Python version** on a per-user basis.
* Provide support for **per-project Python versions**.
* Allow you to **override the Python version** with an environment
  variable.
* Search commands from **multiple versions of Python at a time**.
  This may be helpful to test across Python versions with [tox](http://pypi.python.org/pypi/tox).


### In contrast with pythonbrew and pythonz, pyenv _does not..._

* **Depend on Python itself.** pyenv was made from pure shell scripts.
    There is no bootstrap problem of Python.
* **Need to be loaded into your shell.** Instead, pyenv's shim
    approach works by adding a directory to your `$PATH`.
* **Manage virtualenv.** Of course, you can create [virtualenv](http://pypi.python.org/pypi/virtualenv)
    yourself, or [pyenv-virtualenv](https://github.com/yyuu/pyenv-virtualenv)
    to automate the process.


----


## Table of Contents

* **[How It Works](#how-it-works)**
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Python Version](#choosing-the-python-version)
  * [Locating the Python Installation](#locating-the-python-installation)
* **[Installation](#installation)**
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
    * [Homebrew on Mac OS X](#homebrew-on-mac-os-x)
    * [Neckbeard Configuration](#neckbeard-configuration)
    * [Uninstalling Python Versions](#uninstalling-python-versions)
* **[Command Reference](#command-reference)**
* **[Development](#development)**
  * [Version History](#version-history)
  * [License](#license)


----


## How It Works

At a high level, pyenv intercepts Python commands using shim
executables injected into your `PATH`, determines which Python version
has been specified by your application, and passes your commands along
to the correct Python installation.


### Understanding PATH

When you run a command like `python` or `pip`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.


### Understanding Shims

pyenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.pyenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, pyenv maintains shims in that
directory to match every Python command across every installed version
of Python—`python`, `pip`, and so on.

Shims are lightweight executables that simply pass your command along
to pyenv. So with pyenv installed, when you run, say, `pip`, your
operating system will do the following:

* Search your `PATH` for an executable file named `pip`
* Find the pyenv shim named `pip` at the beginning of your `PATH`
* Run the shim named `pip`, which in turn passes the command along to
  pyenv


### Choosing the Python Version

When you execute a shim, pyenv determines which Python version to use by
reading it from the following sources, in this order:

1. The `PYENV_VERSION` environment variable (if specified). You can use
   the [`pyenv shell`](#pyenv-shell) command to set this environment
   variable in your current shell session.

2. The application-specific `.python-version` file in the current
   directory (if present). You can modify the current directory's
   `.python-version` file with the [`pyenv local`](#pyenv-local)
   command.

3. The first `.python-version` file found (if any) by searching each parent
   directory, until reaching the root of your filesystem.

4. The global `~/.pyenv/version` file. You can modify this file using
   the [`pyenv global`](#pyenv-global) command. If the global version
   file is not present, pyenv assumes you want to use the "system"
   Python. (In other words, whatever version would run if pyenv weren't in your
   `PATH`.)

**NOTE:** You can activate multiple versions at the same time, including mulitple
versions of Python2 or Python3 simultaneously. This allows for parallel usage of
Python2 and Python3, and is required with tools like `tox`. For example, to set
your path to first use your `system` Python and Python3 (set to 2.7.9 and 3.4.2
in this example), but also have Python 3.3.6, 3.2, and 2.5 available on your
`PATH`, one would first `pyenv install` the missing versions, then set `pyenv
global system 3.3.6 3.2 2.5`. At this point, one should be able to find the full
executable path to each of these using `pyenv which`, e.g. `pyenv which python2.5`
(should display `$PYENV_ROOT/versions/2.5/bin/python2.5`), or `pyenv which
python3.4` (should display path to system Python3).

### Locating the Python Installation

Once pyenv has determined which version of Python your application has
specified, it passes the command along to the corresponding Python
installation.

Each Python version is installed into its own directory under
`~/.pyenv/versions`.

For example, you might have these versions installed:

* `~/.pyenv/versions/2.7.8/`
* `~/.pyenv/versions/3.4.2/`
* `~/.pyenv/versions/pypy-2.4.0/`

As far as pyenv is concerned, version names are simply the directories in
`~/.pyenv/versions`.


----


## Installation

If you're on Mac OS X, consider [installing with Homebrew](#homebrew-on-mac-os-x).


### The automatic installer

Visit my other project:
https://github.com/yyuu/pyenv-installer


### Basic GitHub Checkout

This will get you going with the latest version of pyenv and make it
easy to fork and contribute any changes back upstream.

1. **Check out pyenv where you want it installed.**
   A good place to choose is `$HOME/.pyenv` (but you can install it somewhere else).

        $ git clone https://github.com/yyuu/pyenv.git ~/.pyenv


2. **Define environment variable `PYENV_ROOT`** to point to the path where
   pyenv repo is cloned and add `$PYENV_ROOT/bin` to your `$PATH` for access
   to the `pyenv` command-line utility.

        $ echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
        $ echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile

    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.
    **Ubuntu note**: Modify your `~/.bashrc` file instead of `~/.bash_profile`.

3. **Add `pyenv init` to your shell** to enable shims and autocompletion.
   Please make sure `eval "$(pyenv init -)"` is placed toward the end of shell
   configuration file since it manipulates `PATH` during the initialization.

        $ echo 'eval "$(pyenv init -)"' >> ~/.bash_profile

    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.
    **Ubuntu note**: Modify your `~/.bashrc` file instead of `~/.bash_profile`.
    
    **General warning**: There are some systems, where the `BASH_ENV` variable is configured
    to point to `.bashrc`. On such systems you should almost certainly put the abovementioned line
    `eval "$(pyenv init -)` into `.bash_profile`, and **not** into `.bashrc`. Otherwise you
    may observe strange behaviour, such as `pyenv` getting into an infinite loop.
    See [#264](https://github.com/yyuu/pyenv/issues/264) for details.

4. **Restart your shell so the path changes take effect.**
   You can now begin using pyenv.

        $ exec $SHELL

5. **Install Python versions into `$PYENV_ROOT/versions`.**
   For example, to install Python 2.7.8, download and unpack the source, then run:

        $ pyenv install 2.7.8

   **NOTE:** If you need to pass configure option to build, please use
   ```CONFIGURE_OPTS``` environment variable.

   **NOTE:** If you are having trouble installing a python version,
   please visit the wiki page about
   [Common Build Problems](https://github.com/yyuu/pyenv/wiki/Common-build-problems)

6. **Rebuild the shim binaries.**
   You should do this any time you install a new Python binary.
   (Examples: installing a new Python version, or installing a package that provides a binary.)

        $ pyenv rehash

   This can be automated for pip using
   [pyenv-pip-rehash](https://github.com/yyuu/pyenv-pip-rehash), which invokes
   `pyenv rehash` after (un)installing packages using pip.


#### Upgrading

If you've installed pyenv using the instructions above, you can
upgrade your installation at any time using git.

To upgrade to the latest development version of pyenv, use `git pull`:

    $ cd ~/.pyenv
    $ git pull

To upgrade to a specific release of pyenv, check out the corresponding tag:

    $ cd ~/.pyenv
    $ git fetch
    $ git tag
    v0.1.0
    $ git checkout v0.1.0


### Homebrew on Mac OS X

You can also install pyenv using the [Homebrew](http://brew.sh)
package manager for Mac OS X.

    $ brew update
    $ brew install pyenv


To upgrade pyenv in the future, just use `upgrade` instead of `install`.

After installation, you'll still need to add `eval "$(pyenv init -)"` to your
profile (as stated in the caveats). You'll only ever have to do this
once.


### Neckbeard Configuration

Skip this section unless you must know what every line in your shell
profile is doing.

`pyenv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from rvm, some of you might be
opposed to this idea. Here's what `pyenv init` actually does:

1. **Sets up your shims path.** This is the only requirement for pyenv to
   function properly. You can do this by hand by prepending
   `~/.pyenv/shims` to your `$PATH`.

2. **Installs autocompletion.** This is entirely optional but pretty
   useful. Sourcing `~/.pyenv/completions/pyenv.bash` will set that
   up. There is also a `~/.pyenv/completions/pyenv.zsh` for Zsh
   users.

3. **Rehashes shims.** From time to time you'll need to rebuild your
   shim files. Doing this on init makes sure everything is up to
   date. You can always run `pyenv rehash` manually.

4. **Installs the sh dispatcher.** This bit is also optional, but allows
   pyenv and plugins to change variables in your current shell, making
   commands like `pyenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `pyenv` to be a real script rather than a
   shell function, you can safely skip it.

To see exactly what happens under the hood for yourself, run `pyenv init -`.


### Uninstalling Python Versions

As time goes on, you will accumulate Python versions in your
`~/.pyenv/versions` directory.

To remove old Python versions, `pyenv uninstall` command to automate
the removal process.

Alternatively, simply `rm -rf` the directory of the version you want
to remove. You can find the directory of a particular Python version
with the `pyenv prefix` command, e.g. `pyenv prefix 2.6.8`.


----


## Command Reference

See [COMMANDS.md](COMMANDS.md).


----


## Development

The pyenv source code is [hosted on GitHub](https://github.com/yyuu/pyenv).
It's clean, modular, and easy to understand--even if you're not a shell hacker.

Please feel free to submit Pull Requests and report bugs on the
[issue tracker](https://github.com/yyuu/pyenv/issues).


### Version History

See [CHANGELOG.md](CHANGELOG.md).


### License

(The MIT license)

* Copyright (c) 2013 Yamashita, Yuu
* Copyright (c) 2013 Sam Stephenson

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
