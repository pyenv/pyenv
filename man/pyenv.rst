:orphan:

pyenv |version|
===============

:program:`pyenv` - Simple Python version management


Synopsis
--------

.. code:: bash

   pyenv <command> [<args>]


Description
-----------

:program:`pyenv` lets you easily switch between multiple versions of Python. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose
tools that do one thing well.

To start using pyenv

1. **Append** the following to :file:`$HOME/.bashrc`:

   .. code:: bash

      if command -v pyenv 1>/dev/null 2>&1; then
         eval "$(pyenv init -)" 
      fi

   Appending this line enables shims. Please make sure this line is
   placed toward the end of the shell configuration file since it
   manipulates :envvar:`PATH` during the initialization.

   .. note::

      Modify only your :file:`~/.bashrc` file instead of creating
      :file:`~/.bash_profile`.

      **Zsh note**: Modify your :file:`~/.zshrc` file instead of
      :file:`~/.bashrc`

      **Warning**: If you configured your system so that :envvar:`BASH_ENV`
      variable points to :file:`.bashrc`. You should almost certainly put
      the above mentioned line into :file:`.bash_profile`, and **not** into
      :file:`.bashrc`. Otherwise you may observe strange behaviour, such as
      :program:`pyenv` getting into an infinite loop. See 
      `#264 <https://github.com/pyenv/pyenv/issues/264>`_ for details.

2. **Restart your shell so the path changes take effect.**
   You can now begin using :program:`pyenv`:

   .. code:: bash

      exec "$SHELL"

3. **Install Python versions into $(pyenv root)/versions**.
   For example, to download and install Python 3.6.12, run:

   .. code:: bash

      pyenv install 3.6.12

.. note::

    If you need to pass configure option to build, please use
    :envvar:`CONFIGURE_OPTS` environment variable. If you are having
    trouble installing a python version, please visit the wiki page
    about `Common Build Problems <https://github.com/pyenv/pyenv/wiki/Common-build-problems>`_.

**Proxy note**: If you use a proxy, export :envvar:`HTTP_PROXY` and
:envvar:`HTTPS_PROXY` environment variables.


Stop using pyenv
----------------

The simplicity of pyenv makes it easy to temporarily disable it, or
uninstall from the system. To **disable** pyenv managing your Python
versions, simply remove the :command:`pyenv init`**` line from your shell startup
configuration. This will remove pyenv shims directory from PATH, and
future invocations like :command:`python` will execute the system Python
version, as before pyenv.

:program:`pyenv` will still be accessible on the command line, but your
Python apps won't be affected by version switching.


Command line options
--------------------

Like :command:`git`, the :command:`pyenv` command delegates to
subcommands based on its first argument.


Some useful pyenv commands
^^^^^^^^^^^^^^^^^^^^^^^^^^

:command:`commands`
   List all available pyenv commands

:command:`exec`
   Run an executable with the selected Python version

:command:`global`
   Set or show the global Python version(s)

:command:`help`
   Display help for a command

:command:`hooks`
   List hook scripts for a given pyenv command

:command:`init`
   Configure the shell environment for pyenv

:command:`install`
   Install a Python version using python-build

:command:`local`
   Set or show the local application-specific Python version(s)

:command:`prefix`
   Display prefix for a Python version

:command:`rehash`
   Rehash pyenv shims (run this after installing executables)

:command:`root`
   Display the root directory where versions and shims are kept

:command:`shell`
   Set or show the shell-specific Python version

:command:`shims`
   List existing pyenv shims

:command:`uninstall`
   Uninstall Python versions

:command:`version`
   Show the current Python version(s) and its origin

:command:`version-file`
   Detect the file that sets the current pyenv version

:command:`version-name`
   Show the current Python version

:command:`version-origin`
   Explain how the current Python version is set

:command:`versions`
   List all Python versions available to pyenv

:command:`whence`
   List all Python versions that contain the given executable

:command:`which`
   Display the full path to an executable

See :command:`pyenv help <command>` for information on a specific command. For
full documentation, see :ref:`command-ref` section.


Options
=======

.. option:: -h, --help

   Show summary of options.

.. option:: -v, --version

   Show version of program.


Comparison
==========

:program:`pyenv` does...:

-  Let you *change the global Python version* on a per-user basis.

-  Provide support for *per-project Python versions*.

-  Allow you to *override the Python version* with an environment
   variable.

-  Search commands from *multiple versions of Python at a time*. This
   may be helpful to test across Python versions with tox

In contrast with :program:`pythonbrew` and :program:`pythonz`,
:program:`pyenv` does not ...:

-  *Depend on Python itself.* pyenv was made from pure shell scripts.
   There is no bootstrap problem of Python.

-  *Need to be loaded into your shell.* Instead, pyenv's shim approach
   works by adding a directory to your :envvar:`PATH`.

-  *Manage virtualenv.* Of course, you can create virtualenv yourself,
   or pyenv-virtualenv to automate the process.


How It Works
============

At a high level, pyenv intercepts Python commands using shim executables
injected into your :envvar:`PATH`, determines which Python version has been
specified by your application, and passes your commands along to the
correct Python installation.


Understanding PATH
------------------

When you run a command like :command:`python` or :command:`pip`, your
operating system searches through a list of directories to find an
executable file with that name.
This list of directories lives in an environment variable called
:envvar:`PATH`, with each directory in the list separated by a colon::

   /usr/local/bin:/usr/bin:/bin

Directories in :envvar:`PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes precedence
over another one at the end. In this example, the :file:`/usr/local/bin`
directory will be searched first, then :file:`/usr/bin`, then :file:`/bin`.


Understanding Shims
-------------------

pyenv works by inserting a directory of *shims* at the front of your
:envvar:`PATH`::

    $(pyenv root)/shims:/usr/local/bin:/usr/bin:/bin

Through a process called *rehashing*, pyenv maintains shims in that
directory to match every Python command (:command:`python`, :command:`pip`,
etc...) across every installed version of Python

Shims are lightweight executables that simply pass your command along to
pyenv. So with pyenv installed, when you run, say, :command:`pip`, your
operating system will do the following:

-  Search your :envvar:`PATH` for an executable file named :file:`pip`.

-  Find the pyenv shim named :file:`pip` at the beginning of your
   :envvar:`PATH`.

-  Run the shim named :command:`pip`, which in turn passes the command along to
   pyenv.


Choosing the Python Version
---------------------------

When you execute a shim, pyenv determines which Python version to use by
reading it from the following sources, in this order:

1. The :envvar:`PYENV_VERSION` environment variable (if specified). You can
   use the :command:`pyenv shell` command to set this environment variable in
   your current shell session.

2. The application-specific :file:`.python-version` file in the current
   directory (if present). You can modify the current directory's
   :file:`.python-version` file with the :command:`pyenv local` command.

3. The first :file:`.python-version` file found (if any) by searching each
   parent directory, until reaching the root of your filesystem.

4. The global :file:`$(pyenv root)/version` file. You can modify this file
   using the :command:`pyenv global` command. If the global version file is not
   present, pyenv assumes you want to use the "system" Python. (In other
   words, whatever version would run if pyenv weren't in your :envvar:`PATH`.)

.. note::

   You can activate multiple versions at the same time, including
   multiple versions of Python2 or Python3 simultaneously. This allows for
   parallel usage of Python2 and Python3, and is required with tools like
   :command:`tox`.

For example, to set your path to first use your *system*
Python and Python3 (set to 2.7.9 and 3.4.2 in this example), but also
have Python 3.3.6, 3.2, and 2.5 available on your :envvar:`PATH`, one would
first :command:`pyenv install` the missing versions, then set
:command:`pyenv global system 3.3.6 3.2 2.5`.
At this point, one should be able to find the full executable path to each of these using :command:`pyenv which`, e.g. :command:`pyenv which python2.5` (should display :file:`$(pyenv root)/versions/2.5/bin/python2.5`), or :command:`pyenv which python3.4`
(should display path to system Python3). You can also specify multiple
versions in a :file:`.python-version` file, separated by newlines or any
whitespace.


Locating the Python Installation
--------------------------------

Once pyenv has determined which version of Python your application has
specified, it passes the command along to the corresponding Python
installation.

Each Python version is installed into its own directory under::

   $(pyenv root)/versions

For example, you might have these versions installed:

-  :file:`$(pyenv root)/versions/2.7.8/**`

-  :file:`$(pyenv root)/versions/3.4.2/**`

-  :file:`$(pyenv root)/versions/pypy-2.4.0/**`

As far as pyenv is concerned, version names are simply the directories
in :file:`$(pyenv root)/versions`.


Managing Virtual Environments
-----------------------------

There is a pyenv plugin named pyenv-virtualenv which comes with various
features to help pyenv users to manage virtual environments created by
virtualenv or Anaconda. Because the *activate* script of those virtual
environments are relying on mutating :envvar:`PATH` variable of user's
interactive shell, it will intercept pyenv's shim style command
execution hooks. We'd recommend to install pyenv-virtualenv as well if
you have some plan to play with those virtual environments.


Advanced Configuration
======================

Skip this section unless you must know what every line in your shell
profile is doing.

:command:`pyenv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from rvm, some of you might be
opposed to this idea. Here's what :command:`pyenv init` actually does:

1. **Sets up your shims path.** This is the only requirement for pyenv
   to function properly. You can do this by hand by prepending
   :command:`$(pyenv root)/shims` to your :envvar:`PATH`.

2. **Rehashes shims.** From time to time you'll need to rebuild your
   shim files. Doing this on init makes sure everything is up to date.
   You can always run :command:`pyenv rehash` manually.

3. **Installs the sh dispatcher.** This bit is also optional, but allows
   pyenv and plugins to change variables in your current shell, making
   commands like :command:`pyenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override :command:`cd` or hack your shell prompt, but if
   for some reason you need :program:`pyenv` to be a real script rather than a
   shell function, you can safely skip it.

To see exactly what happens under the hood for yourself, run::

   pyenv init -


Uninstalling Python Versions
============================

As time goes on, you will accumulate Python versions in your :file:`$(pyenv root)/versions` directory.

To remove old Python versions, :command:`pyenv uninstall` command to automate
the removal process.

Alternatively, simply :command:`rm -rf` the directory of the version you want
to remove. You can find the directory of a particular Python version
with the :command:`pyenv prefix` command, for example::

   pyenv prefix 2.6.8


.. _command-ref:

Command Reference
=================

The most common subcommands are:

pyenv commands
--------------

Lists all available pyenv commands.

pyenv local
-----------

Sets a local application-specific Python version by writing the version
name to a :file:`.python-version` file in the current directory. This
version overrides the global version, and can be overridden itself by
setting the :envvar:`PYENV_VERSION` environment variable or with the
:command:`pyenv shell` command.

::

   $ pyenv local 2.7.6

When run without a version number, :command:`pyenv local` reports the currently
configured local version. You can also unset the local version::

   $ pyenv local --unset

Previous versions of pyenv stored local version specifications in a file
named **.pyenv-version**. For backwards compatibility, pyenv will read a
local version specified in an **.pyenv-version** file, but a
:file:`.python-version` file in the same directory will take precedence.

You can specify multiple versions as local Python at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer
2.7.6 over 3.3.3,

::

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

::

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

pyenv global
------------

Sets the global version of Python to be used in all shells by writing
the version name to the :file:`~/.pyenv/version` file. This version can be
overridden by an application-specific :file:`.python-version` file, or by
setting the :envvar:`PYENV_VERSION` environment variable.

::

   $ pyenv global 2.7.6

The special version name *system* tells pyenv to use the system Python
(detected by searching your :envvar:`PATH`).

When run without a version number, :command:`pyenv global` reports the
currently configured global version.

You can specify multiple versions as global Python at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer
2.7.6 over 3.3.3,

::

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

::

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

pyenv shell
-----------

Sets a shell-specific Python version by setting the :envvar:`PYENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

::

   $ pyenv shell pypy-2.2.1

When run without a version number, :command:`pyenv shell` reports the current
value of :envvar:`PYENV_VERSION`. You can also unset the shell version::

   $ pyenv shell --unset

Note that you'll need pyenv's shell integration enabled (step 3 of the
installation instructions) in order to use this command. If you prefer
not to use shell integration, you may simply set the :envvar:`PYENV_VERSION`
variable yourself::

   $ export PYENV_VERSION=pypy-2.2.1

You can specify multiple versions via :envvar:`PYENV_VERSION` at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer
2.7.6 over 3.3.3,

::

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

::

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

pyenv install
-------------

Install a Python version

.. program:: pyenv install

.. option:: -f, --force

   Install even if the version appears to be installed already

.. option:: -l, --list

   List all available versions

.. option:: -s, --skip-existing

   Skip if the version appears to be installed already

Python build options:

.. option:: -k, --keep

   Keep source tree in :envvar:`PYENV_BUILD_ROOT` after installation
   (defaults to :file:`$PYENV_ROOT/sources`)

.. option:: -p, --patch

   Apply a patch from stdin before building

.. option:: -v, --verbose

   Verbose mode: print compilation status to stdout

.. option:: --version

   Show version of python-build

.. option:: -g, --debug

   Build a debug version

.. option:: <version>...

   The Python version to install

.. option:: <definition-file>

   A definition file TODO


::

   Usage: pyenv install [-f] [-kvp] <version>
          pyenv install [-f] [-kvp] <definition-file>
          pyenv install -l|--list

     -l, --list             List all available versions
     -f, --force            Install even if the version appears to be installed 
     					already
     -s, --skip-existing    Skip the installation if the version appears to be
     					installed already

     python-build options:

     -k, --keep        Keep source tree in $PYENV_BUILD_ROOT after installation
                       (defaults to $PYENV_ROOT/sources)
     -v, --verbose     Verbose mode: print compilation status to stdout
     -p, --patch       Apply a patch from stdin before building
     -g, --debug       Build a debug version

To list the all available versions of Python, including Anaconda,
Jython, pypy, and stackless, use::

   $ pyenv install --list

Then install the desired versions::

   $ pyenv install 2.7.6
   $ pyenv install 2.6.8
   $ pyenv versions
     system
     2.6.8
   * 2.7.6 (set by /home/yyuu/.pyenv/version)

pyenv uninstall
---------------

Uninstall Python versions.

::

   Usage: pyenv uninstall [-f|--force] <version> ...

      -f  Attempt to remove the specified version without prompting
          for confirmation. If the version does not exist, do not
          display an error message.

pyenv rehash
------------

Installs shims for all Python binaries known to pyenv (i.e.,
:file:`~/.pyenv/versions/*/bin/*`). Run this command after you install a
new version of Python, or install a package that provides binaries.

::

   $ pyenv rehash

pyenv version
-------------

Displays the currently active Python version, along with information on
how it was set.

::

   $ pyenv version
   2.7.6 (set by /home/yyuu/.pyenv/version)

pyenv versions
--------------

Lists all Python versions known to pyenv, and shows an asterisk next to
the currently active version.

::

   $ pyenv versions
     2.5.6
     2.6.8
   * 2.7.6 (set by /home/yyuu/.pyenv/version)
     3.3.3
     jython-2.5.3
     pypy-2.2.1

pyenv which
-----------

Displays the full path to the executable that pyenv will invoke when you
run the given command.

::

   $ pyenv which python3.3
   /home/yyuu/.pyenv/versions/3.3.3/bin/python3.3

pyenv whence
------------

Lists all Python versions with the given command installed.

::

   $ pyenv whence 2to3
   2.6.8
   2.7.6
   3.3.3


Environment variables
=====================

You can affect how pyenv operates with the following settings:

:envvar:`PYENV_VERSION`
   Specifies the Python version to be used. Also see :command:`pyenv shell`

:envvar:`PYENV_ROOT` (:file:`~/.pyenv`)
   Defines the directory under which Python versions and shims reside.
   Also see :command:`pyenv root`

:envvar:`PYENV_DEBUG`
   | Outputs debug information.
   | Also as: **pyenv --debug <subcommand>**

:envvar:`PYENV_HOOK_PATH`
   Colon-separated list of paths searched for pyenv hooks.

:envvar:`PYENV_DIR ($PWD)`
   Directory to start searching for :file:`.python-version` files.

:envvar:`HTTP_PROXY`, :envvar:`HTTPS_PROXY`
   Proxy Variables

:envvar:`CONFIGURE_OPTS`
   Pass configure options to build.

:envvar:`PYTHON_BUILD_ARIA2_OPTS`
   Used to pass additional parameters to `aria2
   <https://aria2.github.io/>`__ If the :command:`aria2c` binary is available
   on :envvar:`PATH`, pyenv uses :command:`aria2c` instead of :command:`curl`
   or :command:`wget` to
   download the Python source code. If you have an unstable internet
   connection, you can use this variable to instruct :program:`aria2` to
   accelerate the download. In most cases, you will only need to use
   **-x 10 -k 1M** as value to :envvar:`PYTHON_BUILD_ARIA2_OPTS` environment
   variable


License
=======

The MIT License
