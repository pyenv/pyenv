:orphan:

###############
pyenv |version|
###############

:program:`pyenv` - Simple Python version management


Synopsis
--------

.. code:: bash

   pyenv <COMMAND> [<args>]


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

   .. code:: shell-session

      $ pyenv install 3.6.12

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

:ref:`pyenv_commands`
   List all available pyenv commands

:ref:`pyenv_exec`
   Run an executable with the selected Python version

:ref:`pyenv_global`
   Set or show the global Python version(s)

:ref:`pyenv_help`
   Display help for a command

:ref:`pyenv_hooks`
   List hook scripts for a given pyenv command

:ref:`pyenv_init`
   Configure the shell environment for pyenv

:ref:`pyenv_install`
   Install a Python version using python-build

:ref:`pyenv_local`
   Set or show the local application-specific Python version(s)

:ref:`pyenv_prefix`
   Display prefix for a Python version

:ref:`pyenv_rehash`
   Rehash pyenv shims (run this after installing executables)

:ref:`pyenv_root`
   Display the root directory where versions and shims are kept

:ref:`pyenv_shell`
   Set or show the shell-specific Python version

:ref:`pyenv_shims`
   List existing pyenv shims

:ref:`pyenv_uninstall`
   Uninstall Python versions

:ref:`pyenv_version`
   Show the current Python version(s) and its origin

:ref:`pyenv_version-file`
   Detect the file that sets the current pyenv version

:ref:`pyenv_version-name`
   Show the current Python version

:ref:`pyenv_version-origin`
   Explain how the current Python version is set

:ref:`pyenv_versions`
   List all Python versions available to pyenv

:ref:`pyenv_whence`
   List all Python versions that contain the given executable

:ref:`pyenv_which`
   Display the full path to an executable

Use :command:`pyenv help <COMMAND>` for information on a specific command. For
full documentation, see :ref:`command-ref` section.


Options
-------

.. program:: pyenv
.. option:: -h, --help

   Show summary of options.

.. option:: -v, --version

   Show version of program.


Comparison
----------

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
------------

At a high level, pyenv intercepts Python commands using shim executables
injected into your :envvar:`PATH`, determines which Python version has been
specified by your application, and passes your commands along to the
correct Python installation.


Understanding PATH
^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

There is a pyenv plugin named ``pyenv-virtualenv`` which comes with various
features to help pyenv users to manage virtual environments created by
virtualenv or Anaconda. Because the *activate* script of those virtual
environments are relying on mutating :envvar:`PATH` variable of user's
interactive shell, it will intercept pyenv's shim style command
execution hooks. We'd recommend to install pyenv-virtualenv as well if
you have some plan to play with those virtual environments.


Advanced Configuration
----------------------

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

To see exactly what happens under the hood for yourself, run:

.. code:: shell-session

   $ pyenv init -


Uninstalling Python Versions
----------------------------

As time goes on, you will accumulate Python versions in your :file:`$(pyenv root)/versions` directory.

To remove old Python versions, :command:`pyenv uninstall` command to automate
the removal process.

Alternatively, simply :command:`rm -rf` the directory of the version you want
to remove. You can find the directory of a particular Python version
with the :command:`pyenv prefix` command, for example:

.. code:: shell-session

   $ pyenv prefix 2.6.8
   /home/yyuu/.pyenv/versions/2.6.8

.. toctree::
    :maxdepth: 1
    :caption: References

    command-reference
    environment-reference


License
-------

The MIT License
