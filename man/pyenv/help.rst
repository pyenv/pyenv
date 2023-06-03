.. _pyenv_help:

pyenv help
==========

Display help for a command


Synopsis
--------

.. code-block:: shell

    pyenv help [--usage] [COMMAND]


Options
-------

.. program:: pyenv help
.. option:: --usage

    Shows only the usage (synopsis) of the command.

.. option:: COMMAND

    The command to show help
    A command is considered documented if it starts with
    a comment block that has a ``Summary:`` or ``Usage:``
    section. Usage instructions can span multiple lines as
    long as subsequent lines are indented.
    The remainder of the comment block is displayed as
    extended documentation.


Description
-----------

To show the complete help output of a subcommand, use the following command:

.. code-block:: shell-session

    $ pyenv help exec
    Usage: pyenv exec <command> [arg1 arg2...]

    Runs an executable by first preparing PATH so that the selected Python
    version's `bin' directory is at the front.

    For example, if the currently selected Python version is 2.7.6:
      pyenv exec pip install -r requirements.txt

    is equivalent to:
      PATH="$PYENV_ROOT/versions/2.7.6/bin:$PATH" pip install -r requirements.txt

If you are only interested in the usage, use the :option:`--usage` option:

.. code-block:: shell-session

    $ pyenv help --usage exec
    Usage: pyenv exec <command> [arg1 arg2...]
