.. _pyenv_hooks:

pyenv hooks
===========

List hook scripts for a given pyenv command


Synopsis
--------

.. code-block:: shell

    pyenv hooks <COMMAND>


Options
-------

.. program:: pyenv hooks
.. option:: COMMAND

    The command to list hook scripts


Description
-----------

Some commands contains special scripts ("hooks") that are
executed when a subcommand is called, for example:

.. code-block:: shell-session

    $ pyenv hooks rehash
    /etc/pyenv.d/rehash/conda.bash
    /etc/pyenv.d/rehash/source.bash
