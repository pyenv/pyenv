.. _pyenv_local:

pyenv local
===========

Set or show the local application-specific Python version(s)


Synopsis
--------

.. code-block:: shell

    pyenv local [--unset] <VERSION> <VERSION2>...


Options
-------

.. program:: pyenv local

.. option:: --unset

    TODO


Description
-----------

Sets a local application-specific Python version by writing the version
name to a :file:`.python-version` file in the current directory. This
version overrides the global version, and can be overridden itself by
setting the :envvar:`PYENV_VERSION` environment variable or with the
:command:`pyenv shell` command.

.. code-block:: shell-session

   $ pyenv local 2.7.6

When run without a version number, :command:`pyenv local` reports the currently
configured local version. You can also unset the local version:

.. code-block:: shell-session

   $ pyenv local --unset

Previous versions of pyenv stored local version specifications in a file
named **.pyenv-version**. For backwards compatibility, pyenv will read a
local version specified in an **.pyenv-version** file, but a
:file:`.python-version` file in the same directory will take precedence.

You can specify multiple versions as local Python at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer
2.7.6 over 3.3.3,

.. code-block:: shell-session

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

.. code-block:: shell-session

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