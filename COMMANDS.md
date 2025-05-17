# Command Reference

Like `git`, the `pyenv` command delegates to subcommands based on its
first argument.

The most common subcommands are:

* [`pyenv help`](#pyenv-help)
* [`pyenv commands`](#pyenv-commands)
* [`pyenv local`](#pyenv-local)
* [`pyenv global`](#pyenv-global)
* [`pyenv shell`](#pyenv-shell)
* [`pyenv install`](#pyenv-install)
* [`pyenv uninstall`](#pyenv-uninstall)
* [`pyenv rehash`](#pyenv-rehash)
* [`pyenv version`](#pyenv-version)
* [`pyenv versions`](#pyenv-versions)
* [`pyenv which`](#pyenv-which)
* [`pyenv whence`](#pyenv-whence)
* [`pyenv exec`](#pyenv-exec)
* [`pyenv root`](#pyenv-root)
* [`pyenv prefix`](#pyenv-prefix)
* [`pyenv latest`](#pyenv-latest)
* [`pyenv hooks`](#pyenv-hooks)
* [`pyenv shims`](#pyenv-shims)
* [`pyenv init`](#pyenv-init)
* [`pyenv completions`](#pyenv-completions)

## `pyenv help`

List all available pyenv commands along with a brief description of what they do. Run `pyenv help <command>` for information on a specific command. For full documentation, see: https://github.com/pyenv/pyenv#readme


## `pyenv commands`

Lists all available pyenv commands.


## `pyenv local`

Sets a local application-specific Python version by writing the version
name to a `.python-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `PYENV_VERSION` environment variable or with the `pyenv shell`
command.

    $ pyenv local 2.7.6

When run without a version number, `pyenv local` reports the currently
configured local version. You can also unset the local version:

    $ pyenv local --unset

Previous versions of pyenv stored local version specifications in a
file named `.pyenv-version`. For backwards compatibility, pyenv will
read a local version specified in an `.pyenv-version` file, but a
`.python-version` file in the same directory will take precedence.


### `pyenv local` (advanced)

You can specify multiple versions as local Python at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer 2.7.6 over 3.3.3,

    $ pyenv local 2.7.6 3.3.3
    $ pyenv versions
      system
    * 2.7.6 (set by /Users/yyuu/path/to/project/.python-version)
    * 3.3.3 (set by /Users/yyuu/path/to/project/.python-version)
    $ python --version
    Python 2.7.6
    $ python2.7 --version
    Python 2.7.6
    $ python3.3 --version
    Python 3.3.3

or, if you prefer 3.3.3 over 2.7.6,

    $ pyenv local 3.3.3 2.7.6
    $ pyenv versions
      system
    * 2.7.6 (set by /Users/yyuu/path/to/project/.python-version)
    * 3.3.3 (set by /Users/yyuu/path/to/project/.python-version)
      venv27
    $ python --version
    Python 3.3.3
    $ python2.7 --version
    Python 2.7.6
    $ python3.3 --version
    Python 3.3.3


You can use the `-f/--force` flag to force setting versions even if some aren't installed.
This is mainly useful in special cases like provisioning scripts.


## `pyenv global`

Sets the global version of Python to be used in all shells by writing
the version name to the `~/.pyenv/version` file. This version can be
overridden by an application-specific `.python-version` file, or by
setting the `PYENV_VERSION` environment variable.

    $ pyenv global 2.7.6

The special version name `system` tells pyenv to use the system Python
(detected by searching your `$PATH`).

When run without a version number, `pyenv global` reports the
currently configured global version.


### `pyenv global` (advanced)

You can specify multiple versions as global Python at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer 2.7.6 over 3.3.3,

    $ pyenv global 2.7.6 3.3.3
    $ pyenv versions
      system
    * 2.7.6 (set by /Users/yyuu/.pyenv/version)
    * 3.3.3 (set by /Users/yyuu/.pyenv/version)
    $ python --version
    Python 2.7.6
    $ python2.7 --version
    Python 2.7.6
    $ python3.3 --version
    Python 3.3.3

or, if you prefer 3.3.3 over 2.7.6,

    $ pyenv global 3.3.3 2.7.6
    $ pyenv versions
      system
    * 2.7.6 (set by /Users/yyuu/.pyenv/version)
    * 3.3.3 (set by /Users/yyuu/.pyenv/version)
      venv27
    $ python --version
    Python 3.3.3
    $ python2.7 --version
    Python 2.7.6
    $ python3.3 --version
    Python 3.3.3


## `pyenv shell`

Sets a shell-specific Python version by setting the `PYENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ pyenv shell pypy-2.2.1

When run without a version number, `pyenv shell` reports the current
value of `PYENV_VERSION`. You can also unset the shell version:

    $ pyenv shell --unset

Note that you'll need pyenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`PYENV_VERSION` variable yourself:

    $ export PYENV_VERSION=pypy-2.2.1


### `pyenv shell` (advanced)

You can specify multiple versions via `PYENV_VERSION` at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer 2.7.6 over 3.3.3,

    $ pyenv shell 2.7.6 3.3.3
    $ pyenv versions
      system
    * 2.7.6 (set by PYENV_VERSION environment variable)
    * 3.3.3 (set by PYENV_VERSION environment variable)
    $ python --version
    Python 2.7.6
    $ python2.7 --version
    Python 2.7.6
    $ python3.3 --version
    Python 3.3.3

or, if you prefer 3.3.3 over 2.7.6,

    $ pyenv shell 3.3.3 2.7.6
    $ pyenv versions
      system
    * 2.7.6 (set by PYENV_VERSION environment variable)
    * 3.3.3 (set by PYENV_VERSION environment variable)
      venv27
    $ python --version
    Python 3.3.3
    $ python2.7 --version
    Python 2.7.6
    $ python3.3 --version
    Python 3.3.3


## `pyenv install`

Install a Python version (using [`python-build`](https://github.com/pyenv/pyenv/tree/master/plugins/python-build)).

    Usage: pyenv install [-f] [-kvp] <version>
           pyenv install [-f] [-kvp] <definition-file>
           pyenv install -l|--list

      -l/--list             List all available versions
      -f/--force            Install even if the version appears to be installed already
      -s/--skip-existing    Skip the installation if the version appears to be installed already

      python-build options:

      -k/--keep        Keep source tree in $PYENV_BUILD_ROOT after installation
                       (defaults to $PYENV_ROOT/sources)
      -v/--verbose     Verbose mode: print compilation status to stdout
      -p/--patch       Apply a patch from stdin before building
      -g/--debug       Build a debug version

To list the all available versions of Python, including Anaconda, Jython, pypy, and stackless, use:

    $ pyenv install --list

Then install the desired versions:

    $ pyenv install 2.7.6
    $ pyenv install 2.6.8
    $ pyenv versions
      system
      2.6.8
    * 2.7.6 (set by /home/yyuu/.pyenv/version)

You can also install the latest version of Python in a specific version line by supplying a prefix instead of a complete name:

    $ pyenv install 3.10

See the [`pyenv latest` documentation](#pyenv-latest) for details on prefix resolution.

An older option is to use the `:latest` syntax. For example, to install the latest patch version for Python 3.8 you could do:

    pyenv install 3.8:latest

To install the latest major release for Python 3 try:

    pyenv install 3:latest

## `pyenv uninstall`

Uninstall Python versions.

    Usage: pyenv uninstall [-f|--force] <version> ...

       -f  Attempt to remove the specified version without prompting
           for confirmation. If the version does not exist, do not
           display an error message.


## `pyenv rehash`

Installs shims for all Python binaries known to pyenv (i.e.,
`~/.pyenv/versions/*/bin/*`). Run this command after you install a new
version of Python, or install a package that provides binaries.

    $ pyenv rehash


## `pyenv version`

Displays the currently active Python version, along with information on
how it was set.

    $ pyenv version
    2.7.6 (set by /home/yyuu/.pyenv/version)


## `pyenv versions`

Lists all Python versions known to pyenv, and shows an asterisk next to
the currently active version.

    $ pyenv versions
      2.5.6
      2.6.8
    * 2.7.6 (set by /home/yyuu/.pyenv/version)
      3.3.3
      jython-2.5.3
      pypy-2.2.1


## `pyenv which`

Displays the full path to the executable that pyenv will invoke when
you run the given command.

    $ pyenv which python3.3
    /home/yyuu/.pyenv/versions/3.3.3/bin/python3.3

Use --nosystem argument in case when you don't need to search command in the 
system environment.

## `pyenv whence`

Lists all Python versions with the given command installed.

    $ pyenv whence 2to3
    2.6.8
    2.7.6
    3.3.3

## `pyenv exec`

    Usage: pyenv exec <command> [arg1 arg2...]

Runs an executable by first preparing PATH so that the selected Python
version's `bin` directory is at the front.

For example, if the currently selected Python version is 3.9.7:

    pyenv exec pip install -r requirements.txt
    
is equivalent to:

    PATH="$PYENV_ROOT/versions/3.9.7/bin:$PATH" pip install -r requirements.txt

## `pyenv root`

Displays the root directory where versions and shims are kept.

    $ pyenv root
    /home/user/.pyenv

## `pyenv prefix`

Displays the directories where the given Python versions are installed,
separated by colons. If no version is given, `pyenv prefix` displays the
locations of the currently selected versions.

    $ pyenv prefix 3.9.7
    /home/user/.pyenv/versions/3.9.7

## `pyenv latest`

Displays the latest installed or known version with the given prefix

    Usage: pyenv latest [-k|--known] [-q|--quiet] <prefix>

     -k/--known      Select from all known versions instead of installed
     -q/--quiet      Do not print an error message on resolution failure

Only full prefixes are searched: in the actual name, the given prefix must be followed by a dot or a dash.

Prereleases and versions with specific suffixes (e.g. `-src`) are ignored.

## `pyenv hooks`

Lists installed hook scripts for a given pyenv command.

    Usage: pyenv hooks <command>

## `pyenv shims`

List existing pyenv shims.

    Usage: pyenv shims [--short]

    $ pyenv shims
    /home/user/.pyenv/shims/2to3
    /home/user/.pyenv/shims/2to3-3.9
    /home/user/.pyenv/shims/idle
    /home/user/.pyenv/shims/idle3
    /home/user/.pyenv/shims/idle3.9
    /home/user/.pyenv/shims/pip
    /home/user/.pyenv/shims/pip3
    /home/user/.pyenv/shims/pip3.9
    /home/user/.pyenv/shims/pydoc
    /home/user/.pyenv/shims/pydoc3
    /home/user/.pyenv/shims/pydoc3.9
    /home/user/.pyenv/shims/python
    /home/user/.pyenv/shims/python3
    /home/user/.pyenv/shims/python3.9
    /home/user/.pyenv/shims/python3.9-config
    /home/user/.pyenv/shims/python3.9-gdb.py
    /home/user/.pyenv/shims/python3-config
    /home/user/.pyenv/shims/python-config

## `pyenv init`

Configure the shell environment for pyenv

    Usage: eval "$(pyenv init [-|--path] [--no-push-path] [--no-rehash] [<shell>])"

      -                    Initialize shims directory, print PYENV_SHELL variable, completions path
                           and shell function
      --path               Print shims path
      --no-push-path       Do not push shim to the start of PATH if they're already there
      --no-rehash          Add no rehash command to output     

## `pyenv completions`

Lists available completions for a given pyenv command.

    Usage: pyenv completions <command> [arg1 arg2...]
