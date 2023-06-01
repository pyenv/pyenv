.. _pyenv_global:

pyenv global
============

Set or show the global Python version(s)


Synopsis
--------

.. code-block:: shell

    pyenv global <VERSION> [<VERSION2>...]


Options
-------

.. program:: pyenv global

.. option:: <VERSION>

    The version to install. Can be specified multiple times
    and should be a version tag known to pyenv.

    The special version string ``system`` will use
    your default system Python. Run :ref:`pyenv_versions`
    for a list of available Python versions.


Description
-----------

Sets the global Python version(s). You can override the global version at
any time by setting a directory-specific version with
:ref:`pyenv_local` or by setting the :envvar:`PYENV_VERSION`
environment variable.

To enable the python2.7 and python3.7 shims to find their
respective executables you could set both versions with:

.. code-block:: shell

    pyenv global 3.7.0 2.7.15

