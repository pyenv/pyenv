.. _pyenv_which:

pyenv which
===========

Display the full path to an executable


Synopsis
--------

.. code-block:: shell
    
    pyenv which <COMMAND> [--nosystem]


Options
-------

.. program:: pyenv whence

.. option:: --nosystem

    Used when you don't need to search command in the system environment.

.. option:: COMMAND

    The command to execute.


Description
-----------

Displays the full path to the executable that pyenv will invoke when you
run the given command.

.. code-block:: shell-session

   $ pyenv which python3.3
   /home/yyuu/.pyenv/versions/3.3.3/bin/python3.3