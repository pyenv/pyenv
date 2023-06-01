.. _pyenv_rehash:

pyenv rehash
============

Rehash pyenv shims (run this after installing executables)


Synopsis
--------

.. code-block:: shell

    pyenv rehash


Options
-------

.. program:: pyenv rehash


Description
-----------

Installs shims for all Python binaries known to pyenv (for example,
:file:`~/.pyenv/versions/*/bin/*`). Run this command after you install a
new version of Python, or install a package that provides binaries.

.. code-block:: shell-session

   $ pyenv rehash