.. _pyenv_exec:

pyenv exec
==========

Run an executable with the selected Python version


Synopsis
--------

.. code-block:: shell

    pyenv exec <COMMAND> [arg1 arg2...]


Options
-------

.. program:: pyenv exec

.. option:: COMMAND

    The command to execute.

.. option:: arg1, arg2

    The arguments to pass to command.


Description
-----------

Runs an executable by first preparing PATH so that the selected Python
version's :file:`bin` directory is at the front.

For example, if the currently selected Python version is 2.7.6:

.. code-block:: shell-session

   $ pyenv exec pip install -r requirements.txt

is equivalent to:

.. code-block:: shell-session

    PATH="$PYENV_ROOT/versions/2.7.6/bin:$PATH" pip install -r requirements.txt