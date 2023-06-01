.. _envvar-ref:

Environment variables
=====================

You can affect how pyenv operates with the following settings:

:envvar:`PYENV_VERSION`
   Specifies the Python version to be used. Also see :command:`pyenv shell`

:envvar:`PYENV_ROOT` (:file:`~/.pyenv`)
   Defines the directory under which Python versions and shims reside.
   See also :command:`pyenv root`

:envvar:`PYENV_DEBUG`
   | Outputs debug information.
   | Also as: :command:`pyenv --debug <subcommand>`

:envvar:`PYENV_HOOK_PATH`
   Colon-separated list of paths searched for pyenv hooks.

:envvar:`PYENV_DIR ($PWD)`
   Directory to start searching for :file:`.python-version` files.

:envvar:`HTTP_PROXY`, :envvar:`HTTPS_PROXY`
   Proxy Variables

:envvar:`CONFIGURE_OPTS`
   Pass configure options to build.

:envvar:`PYTHON_BUILD_ARIA2_OPTS`
   Used to pass additional parameters to `aria2
   <https://aria2.github.io/>`__ If the :command:`aria2c` binary is available
   on :envvar:`PATH`, pyenv uses :command:`aria2c` instead of :command:`curl`
   or :command:`wget` to
   download the Python source code. If you have an unstable internet
   connection, you can use this variable to instruct :program:`aria2` to
   accelerate the download. In most cases, you will only need to use
   **-x 10 -k 1M** as value to :envvar:`PYTHON_BUILD_ARIA2_OPTS` environment
   variable
