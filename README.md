# Simple Python Version Management: pyenv

pyenv lets you easily switch between multiple versions of Python. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose
tools that do one thing well.

This project was forked from [rbenv](https://github.com/sstephenson/rbenv) and.
[ruby-build](https://github.com/sstephenson/ruby-build) and modified for Python.

<img src="http://gyazo.com/9c829fafdf5e58880c820349c4e9197e.png?1346414267" width="849" height="454">

### pyenv _does…_

* Let you **change the global Python version** on a per-user basis.
* Provide support for **per-project Python versions**.
* Allow you to **override the Python version** with an environment
  variable.
* Search commands from multiple versions of Python at a time.
  This may be helpful to test across Python versions with [tox](http://pypi.python.org/pypi/tox).

## Table of Contents

   * [1 How It Works](#section_1)
   * [2 Installation](#section_2)
      * [2.1 Basic GitHub Checkout](#section_2.1)
         * [2.1.1 Upgrading](#section_2.1.1)
      * [2.2 Neckbeard Configuration](#section_2.3)
   * [3 Usage](#section_3)
      * [3.1 pyenv global](#section_3.1)
      * [3.2 pyenv local](#section_3.2)
      * [3.3 pyenv shell](#section_3.3)
      * [3.4 pyenv versions](#section_3.4)
      * [3.5 pyenv version](#section_3.5)
      * [3.6 pyenv rehash](#section_3.6)
      * [3.7 pyenv which](#section_3.7)
      * [3.8 pyenv whence](#section_3.8)
   * [4 Development](#section_4)
      * [4.1 Version History](#section_4.1)
      * [4.2 License](#section_4.2)

## <a name="section_1"></a> 1 How It Works

pyenv operates on the per-user directory `~/.pyenv`. Version names in
pyenv correspond to subdirectories of `~/.pyenv/versions`. For
example, you might have `~/.pyenv/versions/2.7.3` and
`~/.pyenv/versions/2.7.3`.

Each version is a working tree with its own binaries, like
`~/.pyenv/versions/2.7.3/bin/python2.7` and
`~/.pyenv/versions/3.2.3/bin/python3.2`. pyenv makes _shim binaries_
for every such binary across all installed versions of Python.

These shims are simple wrapper scripts that live in `~/.pyenv/shims`
and detect which Python version you want to use. They insert the
directory for the selected version at the beginning of your `$PATH`
and then execute the corresponding binary.

Because of the simplicity of the shim approach, all you need to use
pyenv is `~/.pyenv/shims` in your `$PATH`.

## <a name="section_2"></a> 2 Installation

### <a name="section_2.1"></a> 2.1 Basic GitHub Checkout

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
   install Python 2.7.3, download and unpack the source, then run:

        $ pyenv install 2.7.3

6. Rebuild the shim binaries. You should do this any time you install
   a new Python binary (for example, when installing a new Python version,
   or when installing a gem that provides a binary).

        $ pyenv rehash

#### <a name="section_2.1.1"></a> 2.1.1 Upgrading

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

### <a name="section_2.2"></a> 2.2 Neckbeard Configuration

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

## <a name="section_3"></a> 3 Usage

Like `git`, the `pyenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### <a name="section_3.1"></a> 3.1 pyenv global

Sets the global version of Python to be used in all shells by writing
the version name to the `~/.pyenv/version` file. This version can be
overridden by a per-project `.pyenv-version` file, or by setting the
`PYENV_VERSION` environment variable.

    $ pyenv global 2.7.3

The special version name `system` tells pyenv to use the system Python
(detected by searching your `$PATH`).

When run without a version number, `pyenv global` reports the
currently configured global version.

_pyenv extension_

You can specify multiple versions for global Python. Commands within
these versions are searched by specified order.

    $ pyenv global 2.7.3 3.2.3
    $ pyenv global
    2.7.3
    3.2.3

### <a name="section_3.2"></a> 3.2 pyenv local

Sets a local per-project Python version by writing the version name to
an `.pyenv-version` file in the current directory. This version
overrides the global, and can be overridden itself by setting the
`PYENV_VERSION` environment variable or with the `pyenv shell`
command.

    $ pyenv local rbx-1.2.4

When run without a version number, `pyenv local` reports the currently
configured local version. You can also unset the local version:

    $ pyenv local --unset

_pyenv extension_

You can specify multiple versions for local Python.

### <a name="section_3.3"></a> 3.3 pyenv shell

Sets a shell-specific Python version by setting the `PYENV_VERSION`
environment variable in your shell. This version overrides both
project-specific versions and the global version.

    $ pyenv shell pypy-1.9

When run without a version number, `pyenv shell` reports the current
value of `PYENV_VERSION`. You can also unset the shell version:

    $ pyenv shell --unset

Note that you'll need pyenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`PYENV_VERSION` variable yourself:

    $ export PYENV_VERSION=pypy-1.9

### <a name="section_3.4"></a> 3.4 pyenv versions

Lists all Python versions known to pyenv, and shows an asterisk next to
the currently active version.

    $ pyenv versions
      2.5.6
      2.6.8
    * 2.7.3 (set by /home/yyuu/.pyenv/version)
      3.2.3
      jython-2.5.3
      pypy-1.9

### <a name="section_3.5"></a> 3.5 pyenv version

Displays the currently active Python version, along with information on
how it was set.

    $ pyenv version
    2.7.3 (set by /home/yyuu/.pyenv/version)

### <a name="section_3.6"></a> 3.6 pyenv rehash

Installs shims for all Python binaries known to pyenv (i.e.,
`~/.pyenv/versions/*/bin/*`). Run this command after you install a new
version of Python, or install a gem that provides binaries.

    $ pyenv rehash

### <a name="section_3.7"></a> 3.7 pyenv which

Displays the full path to the binary that pyenv will execute when you
run the given command.

    $ pyenv which python3.2
    /Users/sam/.pyenv/versions/3.2.3/bin/python3.2

### <a name="section_3.8"></a> 3.8 pyenv whence

Lists all Python versions with the given command installed.

    $ pyenv whence 2to3
    2.6.8
    2.7.3
    3.2.3

## <a name="section_4"></a> 4 Development

The pyenv source code is [hosted on
GitHub](https://github.com/yyuu/pyenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/yyuu/pyenv/issues).

### <a name="section_4.1"></a> 4.1 Version History

**0.1.0** (August 31, 2012)

* Initial public release.

### <a name="section_4.2"></a> 4.2 License

(The MIT license)

* Copyright (c) 2011 Sam Stephenson
* Copyright (c) 2012 Yamashita, Yuu

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
