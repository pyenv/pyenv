.. _pyenv_shell:

pyenv shell
===========

Set or show the shell-specific Python version


Synopsis
--------

.. code-block:: shell

    pyenv shell [--unset|-] <VERSION>...


Options
-------

.. program:: pyenv shell

.. option:: --unset

    Unsets the current shell version from :envvar:`PYENV_VERSION`.

.. option:: VERSION

    A string matching a Python version known to pyenv.
    The special version string ``system`` will use your default
    system Python.
    Run :command:`pyenv versions` for a list of available Python versions.


Description
-----------

Sets a shell-specific Python version by setting the :envvar:`PYENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

.. code-block:: shell-session

   $ pyenv shell pypy-2.2.1

When run without a version number, :command:`pyenv shell` reports the current
value of :envvar:`PYENV_VERSION`. You can also unset the shell version:

.. code-block:: shell-session

   $ pyenv shell --unset

Note that you'll need pyenv's shell integration enabled (step 3 of the
installation instructions) in order to use this command. If you prefer
not to use shell integration, you may simply set the :envvar:`PYENV_VERSION`
variable yourself:

.. code-block:: shell-session

   $ export PYENV_VERSION=pypy-2.2.1

You can specify multiple versions via :envvar:`PYENV_VERSION` at once.

Let's say if you have two versions of 2.7.6 and 3.3.3. If you prefer
2.7.6 over 3.3.3,

.. code-block:: shell-session

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

.. code-block:: shell-session

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