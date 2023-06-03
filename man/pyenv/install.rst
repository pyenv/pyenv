.. _pyenv_install:

pyenv install
=============

Install a Python version using python-build


Synopsis
--------

.. code-block:: shell
    
    pyenv install [-f] [-kvp]  <VERSION>...
    pyenv install -l|--list
    pyenv install --version


Options
-------

.. program:: pyenv install
.. option:: -l, --list

    List all available versions.

.. option:: -f, --force

    Install even if the version appears to be installed already.

.. option:: -s, --skip-existing

    Skip the installation if the version appears to be installed already.

:command:`python-build` options:

.. option:: -g, --debug

    Build a debug version.

.. option:: -k, --keep

    Keep source tree in :envvar:`PYENV_BUILD_ROOT` after installation
    (defaults to :file:`$PYENV_ROOT/sources`)

.. option:: -p, --patch

    Apply a patch from stdin before building

.. option:: -v, --verbose

    Verbose mode; print compilation status to stdout

.. option:: --version

    Show version of python-build


Description
-----------

To list the all available versions of Python, including Anaconda,
Jython, pypy, and Stackless, use:

.. code-block:: shell-session

   $ pyenv install --list

To install the desired versions, use:

.. code-block:: shell-session

   $ pyenv install 2.7.6
   $ pyenv install 2.6.8
   $ pyenv versions
     system
     2.6.8
   * 2.7.6 (set by /home/yyuu/.pyenv/version)
