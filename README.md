# Simple Python Version Management: pyenv

pyenv lets you easily switch between multiple versions of Python. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose
tools that do one thing well.

This project was forked from [rbenv](https://github.com/sstephenson/rbenv) and
[ruby-build](https://github.com/sstephenson/ruby-build), and modified for Python.

<img src="http://gyazo.com/9c829fafdf5e58880c820349c4e9197e.png?1346414267" width="849" height="454">

### pyenv _does..._

* Let you **change the global Python version** on a per-user basis.
* Provide support for **per-project Python versions**.
* Allow you to **override the Python version** with an environment
  variable.
* Search commands from **multiple versions of Python at a time**.
  This may be helpful to test across Python versions with [tox](http://pypi.python.org/pypi/tox).

### In contrast with pythonbrew and pythonz, pyenv _does not..._

* **Depending on Python itself.** pyenv was made from pure shell scripts.
    There is no bootstrap problem of Python.
* **Need to be loaded into your shell.** Instead, pyenv's shim
    approach works by adding a directory to your `$PATH`.
* **Manage virtualenv.** Of course, you can create [virtualenv](http://pypi.python.org/pypi/virtualenv)
    yourself, or [pyenv-virtualenv](https://github.com/yyuu/pyenv-virtualenv)
    to automate the process.

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Python Version](#choosing-the-python-version)
  * [Locating the Python Installation](#locating-the-python-installation)
* [Installation](#installation)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
    * [Homebrew on Mac OS X](#homebrew-on-mac-os-x)
    * [Neckbeard Configuration](#neckbeard-configuration)
    * [Uninstalling Python Versions](#uninstalling-python-versions)
* [Command Reference](#command-reference)
  * [pyenv local](#pyenv-local)
  * [pyenv global](#pyenv-global)
  * [pyenv shell](#pyenv-shell)
  * [pyenv versions](#pyenv-versions)
  * [pyenv version](#pyenv-version)
  * [pyenv rehash](#pyenv-rehash)
  * [pyenv which](#pyenv-which)
  * [pyenv whence](#pyenv-whence)
* [Development](#development)
  * [Version History](#version-history)
  * [License](#license)

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

1. The `PYENV_VERSION` environment variable, if specified. You can use
   the [`pyenv shell`](#pyenv-shell) command to set this environment
   variable in your current shell session.

2. The application-specific `.python-version` file in the current
   directory, if present. You can modify the current directory's
   `.python-version` file with the [`pyenv local`](#pyenv-local)
   command.

3. The first `.python-version` file found by searching each parent
   directory until reaching the root of your filesystem, if any.

4. The global `~/.pyenv/version` file. You can modify this file using
   the [`pyenv global`](#pyenv-global) command. If the global version
   file is not present, pyenv assumes you want to use the "system"
   Python—i.e. whatever version would be run if pyenv weren't in your
   path.

### Locating the Python Installation

Once pyenv has determined which version of Python your application has
specified, it passes the command along to the corresponding Python
installation.

Each Python version is installed into its own directory under
`~/.pyenv/versions`. For example, you might have these versions
installed:

* `~/.pyenv/versions/2.7.5/`
* `~/.pyenv/versions/3.3.2/`
* `~/.pyenv/versions/pypy-1.9/`

Version names to pyenv are simply the names of the directories in
`~/.pyenv/versions`.

## Installation

If you're on Mac OS X, consider
[installing with Homebrew](#homebrew-on-mac-os-x).

### Basic GitHub Checkout

This will get you going with the latest version of pyenv and make it
easy to fork and contribute any changes back upstream.

1. Check out pyenv into `~/.pyenv`.

        $ cd
        $ git clone git://github.com/yyuu/pyenv.git .pyenv

2. Add `~/.pyenv/bin` to your `$PATH` for access to the `pyenv`
   command-line utility.

        $ echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bash_profile

    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.

3. Add pyenv init to your shell to enable shims and autocompletion.

        $ echo 'eval "$(pyenv init -)"' >> ~/.bash_profile

    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.

4. Restart your shell so the path changes take effect. You can now
   begin using pyenv.

        $ exec $SHELL

5. Install Python versions into `~/.pyenv/versions`. For example, to
   install Python 2.7.5, download and unpack the source, then run:

        $ pyenv install 2.7.5

   **NOTE** If you need to pass configure option to build, please use
   ```CONFIGURE_OPTS``` environment variable.

6. Rebuild the shim binaries. You should do this any time you install
   a new Python binary (for example, when installing a new Python version,
   or when installing a package that provides a binary).

        $ pyenv rehash

#### Upgrading

If you've installed pyenv using the instructions above, you can
upgrade your installation at any time using git.

To upgrade to the latest development version of pyenv, use `git pull`:

    $ cd ~/.pyenv
    $ git pull

To upgrade to a specific release of pyenv, check out the corresponding
tag:

    $ cd ~/.pyenv
    $ git fetch
    $ git tag
    v0.1.0
    $ git checkout v0.1.0

### Homebrew on Mac OS X

You can also install pyenv using the
[Homebrew](http://mxcl.github.com/homebrew/) package manager on Mac OS
X.

~~
$ brew update
$ brew install pyenv
~~

To later update these installs, use `upgrade` instead of `install`.

Afterwards you'll still need to add `eval "$(pyenv init -)"` to your
profile as stated in the caveats. You'll only ever have to do this
once.

### Neckbeard Configuration

Skip this section unless you must know what every line in your shell
profile is doing.

`pyenv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from rvm, some of you might be
opposed to this idea. Here's what `pyenv init` actually does:

1. Sets up your shims path. This is the only requirement for pyenv to
   function properly. You can do this by hand by prepending
   `~/.pyenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.pyenv/completions/pyenv.bash` will set that
   up. There is also a `~/.pyenv/completions/pyenv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this on init makes sure everything is up to
   date. You can always run `pyenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   pyenv and plugins to change variables in your current shell, making
   commands like `pyenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `pyenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `pyenv init -` for yourself to see exactly what happens under the
hood.

### Uninstalling Python Versions

As time goes on, Python versions you install will accumulate in your
`~/.pyenv/versions` directory.

To remove old Python versions, `pyenv uninstall` command to automate
the removal process.

Or, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Python version with the `pyenv prefix` command, e.g. `pyenv prefix
2.6.8`.

## Command Reference

Like `git`, the `pyenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### pyenv local

Sets a local application-specific Python version by writing the version
name to a `.python-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `PYENV_VERSION` environment variable or with the `pyenv shell`
command.

    $ pyenv local 2.7.5

When run without a version number, `pyenv local` reports the currently
configured local version. You can also unset the local version:

    $ pyenv local --unset

Previous versions of pyenv stored local version specifications in a
file named `.pyenv-version`. For backwards compatibility, pyenv will
read a local version specified in an `.pyenv-version` file, but a
`.python-version` file in the same directory will take precedence.

**pyenv feature**

You can specify multiple versions as local Python. Commands
within these Python versions are searched by specified order.

    $ pyenv local 2.7.5 3.2.5
    $ pyenv local
    2.7.5
    3.2.5
    $ pyenv which python2.7
    /home/yyuu/.pyenv/versions/2.7.5/bin/python2.7
    $ pyenv which python3.2
    /home/yyuu/.pyenv/versions/3.2.5/bin/python3.2
    $ pyenv which python
    /home/yyuu/.pyenv/versions/2.7.5/bin/python

### pyenv global

Sets the global version of Python to be used in all shells by writing
the version name to the `~/.pyenv/version` file. This version can be
overridden by an application-specific `.python-version` file, or by
setting the `PYENV_VERSION` environment variable.

    $ pyenv global 2.7.5

The special version name `system` tells pyenv to use the system Python
(detected by searching your `$PATH`).

When run without a version number, `pyenv global` reports the
currently configured global version.

**pyenv feature**

You can specify multiple versions as global Python. Commands
within these Python versions are searched by specified order.

    $ pyenv global 2.7.5 3.2.5
    $ pyenv global
    2.7.5
    3.2.5
    $ pyenv which python2.7
    /home/yyuu/.pyenv/versions/2.7.5/bin/python2.7
    $ pyenv which python3.2
    /home/yyuu/.pyenv/versions/3.2.5/bin/python3.2
    $ pyenv which python
    /home/yyuu/.pyenv/versions/2.7.5/bin/python

### pyenv shell

Sets a shell-specific Python version by setting the `PYENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ pyenv shell pypy-1.9

When run without a version number, `pyenv shell` reports the current
value of `PYENV_VERSION`. You can also unset the shell version:

    $ pyenv shell --unset

Note that you'll need pyenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`PYENV_VERSION` variable yourself:

    $ export PYENV_VERSION=pypy-1.9

**pyenv feature**

You can specify multiple versions via `PYENV_VERSION`
environment variable in your shell.

    $ pyenv shell pypy-1.9 2.7.5
    $ echo $PYENV_VERSION
    pypy-1.9:2.7.5
    $ pyenv version
    pypy-1.9 (set by PYENV_VERSION environment variable)
    2.7.5 (set by PYENV_VERSION environment variable)

### pyenv versions

Lists all Python versions known to pyenv, and shows an asterisk next to
the currently active version.

    $ pyenv versions
      2.5.6
      2.6.8
    * 2.7.5 (set by /home/yyuu/.pyenv/version)
      3.2.5
      jython-2.5.3
      pypy-1.9

### pyenv version

Displays the currently active Python version, along with information on
how it was set.

    $ pyenv version
    2.7.5 (set by /home/yyuu/.pyenv/version)

### pyenv rehash

Installs shims for all Python binaries known to pyenv (i.e.,
`~/.pyenv/versions/*/bin/*`). Run this command after you install a new
version of Python, or install a package that provides binaries.

    $ pyenv rehash

### pyenv which

Displays the full path to the executable that pyenv will invoke when
you run the given command.

    $ pyenv which python3.2
    /home/yyuu/.pyenv/versions/3.2.5/bin/python3.2

### pyenv whence

Lists all Python versions with the given command installed.

    $ pyenv whence 2to3
    2.6.8
    2.7.5
    3.2.5

## Development

The pyenv source code is [hosted on
GitHub](https://github.com/yyuu/pyenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/yyuu/pyenv/issues).

### Version History

See CHANGELOG.md.


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
