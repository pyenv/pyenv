.. _pyenv_versions:

pyenv versions
==============

List all Python versions available to pyenv


Synopsis
--------

.. code-block:: shell
    
    pyenv versions [--bare] [--skip-aliases] [--skip-envs]


Options
-------

.. program:: pyenv versions

.. option:: --bare

    TODO

.. option:: --skip-aliases

    TODO

.. option:: --skip-envs

    TODO


Description
-----------

Lists all Python versions known to pyenv, and shows an asterisk next to
the currently active version.

.. code-block:: shell-session

   $ pyenv versions
     2.5.6
     2.6.8
   * 2.7.6 (set by /home/yyuu/.pyenv/version)
     3.3.3
     jython-2.5.3
     pypy-2.2.1