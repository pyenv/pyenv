.. _pyenv_whence:

pyenv whence
============

List all Python versions that contain the given executable


Synopsis
--------

.. code-block:: shell
    
    pyenv whence [--path] <COMMAND>


Options
-------

.. program:: pyenv whence

.. option:: --path

    TODO

.. option:: COMMAND

    The command to execute.


Description
-----------

Lists all Python versions with the given command installed.

.. code-block:: shell-session

   $ pyenv whence 2to3
   2.6.8
   2.7.6
   3.3.3

To get the absolute path of this commands, use :option:`--path`:

.. code-block:: shell-session

   $ pyenv whence --path 2to3
   /home/yyuu/.pyenv/versions/2.6.8/bin/2to3
   /home/yyuu/.pyenv/versions/2.7.6/bin/2to3
   /home/yyuu/.pyenv/versions/3.3.3/bin/2to3