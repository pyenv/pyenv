.. _pyenv_init:

pyenv init
==========

Configure the shell environment for pyenv


Synopsis
--------

.. code-block:: shell

    pyenv init [-|--path] [--no-push-path] [--detect-shell] [--no-rehash] [<SHELL>]


Options
-------

.. program:: pyenv init
.. option:: --path

    TODO

.. option:: --no-push-path

    TODO

.. option:: --detect-shell

    TODO

.. option:: --no-rehash

    TODO

.. option:: SHELL

    TODO


Description
-----------

Usually, this command is done only once in your :file:`~/.bashrc`
file. By adding the following line you enable shims and autocompletion:

.. code:: shell-session

    $ eval "$(pyenv init -)"

In most cases this is enough. If you need to just enable shims
without shell integration use this line:

.. code:: shell-session

    $ eval "$(pyenv init --path)"