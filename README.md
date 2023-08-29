# Simple Python Version Management: pyenv

[![Join the chat at https://gitter.im/yyuu/pyenv](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/yyuu/pyenv?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

pyenv lets you easily switch between multiple versions of Python. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose
tools that do one thing well.

This project was forked from [rbenv](https://github.com/rbenv/rbenv) and
[ruby-build](https://github.com/rbenv/ruby-build), and modified for Python.

![Terminal output example](/terminal_output.png)


### What pyenv _does..._

* Lets you **change the global Python version** on a per-user basis.
* Provides support for **per-project Python versions**.
* Allows you to **override the Python version** with an environment
  variable.
* Searches for commands from **multiple versions of Python at a time**.
  This may be helpful to test across Python versions with [tox](https://pypi.python.org/pypi/tox).


### In contrast with pythonbrew and pythonz, pyenv _does not..._

* **Depend on Python itself.** pyenv was made from pure shell scripts.
    There is no bootstrap problem of Python.
* **Need to be loaded into your shell.** Instead, pyenv's shim
    approach works by adding a directory to your `PATH`.
* **Manage virtualenv.** Of course, you can create [virtualenv](https://pypi.python.org/pypi/virtualenv)
    yourself, or [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv)
    to automate the process.

----


## Table of Contents

* **[How It Works](#how-it-works)**
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Understanding Python version selection](#understanding-python-version-selection)
  * [Locating Pyenv-provided Python Installations](#locating-pyenv-provided-python-installations)
* **[Installation](#installation)**
  * [Getting Pyenv](#getting-pyenv)
    * [UNIX/MacOS](#unixmacos)
      * [Homebrew in macOS](#homebrew-in-macos)
      * [Automatic installer](#automatic-installer)
      * [Basic GitHub Checkout](#basic-github-checkout)
    * [Windows](#windows)
  * [Set up your shell environment for Pyenv](#set-up-your-shell-environment-for-pyenv)
  * [Restart your shell](#restart-your-shell)
  * [Install Python build dependencies](#install-python-build-dependencies)
* **[Usage](#usage)**
  * [Install additional Python versions](#install-additional-python-versions)
    * [Prefix auto-resolution to the latest version](#prefix-auto-resolution-to-the-latest-version)
    * [Python versions with extended support](#python-versions-with-extended-support)
  * [Switch between Python versions](#switch-between-python-versions)
  * [Uninstall Python versions](#uninstall-python-versions)
  * [Other operations](#other-operations)
* [Upgrading](#upgrading)
  * [Upgrading with Homebrew](#upgrading-with-homebrew)
  * [Upgrading with Installer or Git checkout](#upgrading-with-installer-or-git-checkout)
* [Uninstalling pyenv](#uninstalling-pyenv)
* [Pyenv plugins](#pyenv-plugins)
* [Advanced Configuration](#advanced-configuration)
  * [Using Pyenv without shims](#using-pyenv-without-shims)
  * [Environment variables](#environment-variables)
* **[Development](#development)**
  * [Contributing](#contributing)
  * [Version History](#version-history)
  * [License](#license)


----


## How It Works

At a high level, pyenv intercepts Python commands using shim
executables injected into your `PATH`, determines which Python version
has been specified by your application, and passes your commands along
to the correct Python installation.


### Understanding PATH

When you run a command like `python` or `pip`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.


### Understanding Shims

pyenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    $(pyenv root)/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, pyenv maintains shims in that
directory to match every Python command across every installed version
of Python—`python`, `pip`, and so on.

Shims are lightweight executables that simply pass your command along
to pyenv. So with pyenv installed, when you run, say, `pip`, your
operating system will do the following:

* Search your `PATH` for an executable file named `pip`
* Find the pyenv shim named `pip` at the beginning of your `PATH`
* Run the shim named `pip`, which in turn passes the command along to
  pyenv


### Understanding Python version selection

When you execute a shim, pyenv determines which Python version to use by
reading it from the following sources, in this order:

1. The `PYENV_VERSION` environment variable (if specified). You can use
   the [`pyenv shell`](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md#pyenv-shell) command to set this environment
   variable in your current shell session.

2. The application-specific `.python-version` file in the current
   directory (if present). You can modify the current directory's
   `.python-version` file with the [`pyenv local`](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md#pyenv-local)
   command.

3. The first `.python-version` file found (if any) by searching each parent
   directory, until reaching the root of your filesystem.

4. The global `$(pyenv root)/version` file. You can modify this file using
   the [`pyenv global`](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md#pyenv-global) command.
   If the global version file is not present, pyenv assumes you want to use the "system"
   Python (see below).

A special version name "`system`" means to use whatever Python is found on `PATH`
after the shims `PATH` entry (in other words, whatever would be run if Pyenv
shims weren't on `PATH`). Note that Pyenv considers those installations outside
its control and does not attempt to inspect or distinguish them in any way.
So e.g. if you are on MacOS and have OS-bundled Python 3.8.9 and Homebrew-installed
Python 3.9.12 and 3.10.2 -- for Pyenv, this is still a single "`system`" version,
and whichever of those is first on `PATH` under the executable name you
specified will be run.

**NOTE:** You can activate multiple versions at the same time, including multiple
versions of Python2 or Python3 simultaneously. This allows for parallel usage of
Python2 and Python3, and is required with tools like `tox`. For example, to instruct
Pyenv to first use your system Python and Python3 (which are e.g. 2.7.9 and 3.4.2)
but also have Python 3.3.6, 3.2.1, and 2.5.2 available, you first `pyenv install`
the missing versions, then set `pyenv global system 3.3.6 3.2.1 2.5.2`.
Then you'll be able to invoke any of those versions with an appropriate `pythonX` or
`pythonX.Y` name.
You can also specify multiple versions in a `.python-version` file by hand,
separated by newlines. Lines starting with a `#` are ignored.

[`pyenv which <command>`](COMMANDS.md#pyenv-which) displays which real executable would be
run when you invoke `<command>` via a shim.
E.g. if you have 3.3.6, 3.2.1 and 2.5.2 installed of which 3.3.6 and 2.5.2 are selected
and your system Python is 3.2.5,
`pyenv which python2.5` should display `$(pyenv root)/versions/2.5.2/bin/python2.5`,
`pyenv which python3` -- `$(pyenv root)/versions/3.3.6/bin/python3` and
`pyenv which python3.2` -- path to your system Python due to the fall-through (see below).

Shims also fall through to anything further on `PATH` if the corresponding executable is
not present in any of the selected Python installations.
This allows you to use any programs installed elsewhere on the system as long as
they are not shadowed by a selected Python installation.


### Locating Pyenv-provided Python installations

Once pyenv has determined which version of Python your application has
specified, it passes the command along to the corresponding Python
installation.

Each Python version is installed into its own directory under
`$(pyenv root)/versions`.

For example, you might have these versions installed:

* `$(pyenv root)/versions/2.7.8/`
* `$(pyenv root)/versions/3.4.2/`
* `$(pyenv root)/versions/pypy-2.4.0/`

As far as Pyenv is concerned, version names are simply directories under
`$(pyenv root)/versions`.

----


## Installation

### Getting Pyenv
#### UNIX/MacOS
##### Homebrew in macOS

   1. Consider installing with [Homebrew](https://brew.sh):
      ```sh
      brew update
      brew install pyenv
      ```
   2. Then follow the rest of the post-installation steps, starting with
      [Set up your shell environment for Pyenv](#set-up-your-shell-environment-for-pyenv).

   3. OPTIONAL. To fix `brew doctor`'s warning _""config" scripts exist outside your system or Homebrew directories"_

      If you're going to build Homebrew formulae from source that link against Python
      like Tkinter or NumPy
      _(This is only generally the case if you are a developer of such a formula,
      or if you have an EOL version of MacOS for which prebuilt bottles are no longer provided
      and you are using such a formula)._

      To avoid them accidentally linking against a Pyenv-provided Python,
      add the following line into your interactive shell's configuration:

      * Bash/Zsh:

        ~~~bash
        alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'
        ~~~

      * Fish:

        ~~~fish
        alias brew="env PATH=(string replace (pyenv root)/shims '' \"\$PATH\") brew"
        ~~~


##### Automatic installer

`curl https://pyenv.run | bash`

For more details visit our other project:
https://github.com/pyenv/pyenv-installer


##### Basic GitHub Checkout

This will get you going with the latest version of Pyenv and make it
easy to fork and contribute any changes back upstream.

* **Check out Pyenv where you want it installed.**
   A good place to choose is `$HOME/.pyenv` (but you can install it somewhere else):
    ```
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    ```
*  Optionally, try to compile a dynamic Bash extension to speed up Pyenv. Don't
   worry if it fails; Pyenv will still work normally:
    ```
    cd ~/.pyenv && src/configure && make -C src
    ```

#### Windows

Pyenv does not officially support Windows and does not work in Windows outside
the Windows Subsystem for Linux.
Moreover, even there, the Pythons it installs are not native Windows versions
but rather Linux versions running in a virtual machine --
so you won't get Windows-specific functionality.

If you're in Windows, we recommend using @kirankotari's [`pyenv-win`](https://github.com/pyenv-win/pyenv-win) fork --
which does install native Windows Python versions.


### Set up your shell environment for Pyenv

**Upgrade note:** The startup logic and instructions have been updated for simplicity in 2.3.0.
The previous, more complicated configuration scheme for 2.0.0-2.2.5 still works.

* Define environment variable `PYENV_ROOT` to point to the path where
  Pyenv will store its data. `$HOME/.pyenv` is the default.
  If you installed Pyenv via Git checkout, we recommend
  to set it to the same location as where you cloned it.
* Add the `pyenv` executable to your `PATH` if it's not already there
* run `eval "$(pyenv init -)"` to install `pyenv` into your shell as a shell function, enable shims and autocompletion
  * You may run `eval "$(pyenv init --path)"` instead to just enable shims, without shell integration

The below setup should work for the vast majority of users for common use cases.
See [Advanced configuration](#advanced-configuration) for details and more configuration options.

  - For **bash**:

    Stock Bash startup files vary widely between distributions in which of them source
    which, under what circumstances, in what order and what additional configuration they perform.
    As such, the most reliable way to get Pyenv in all environments is to append Pyenv
    configuration commands to both `.bashrc` (for interactive shells)
    and the profile file that Bash would use (for login shells).

    First, add the commands to `~/.bashrc` by running the following in your terminal:

    ~~~ bash
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    ~~~

    Then, if you have `~/.profile`, `~/.bash_profile` or `~/.bash_login`, add the commands there as well.
    If you have none of these, add them to `~/.profile`.

    * to add to `~/.profile`:
      ~~~ bash
      echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
      echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
      echo 'eval "$(pyenv init -)"' >> ~/.profile
      ~~~

    * to add to `~/.bash_profile`:
      ~~~ bash
      echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
      echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
      echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
      ~~~

  - For **Zsh**:
    ~~~ zsh
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
    ~~~

    If you wish to get Pyenv in noninteractive login shells as well, also add the commands to `~/.zprofile` or `~/.zlogin`.

  - For **Fish shell**:

    If you have Fish 3.2.0 or newer, execute this interactively:

    ~~~ fish
    set -Ux PYENV_ROOT $HOME/.pyenv
    fish_add_path $PYENV_ROOT/bin
    ~~~

    Otherwise, execute the snippet below:

    ~~~ fish
    set -Ux PYENV_ROOT $HOME/.pyenv
    set -U fish_user_paths $PYENV_ROOT/bin $fish_user_paths
    ~~~

    Now, add this to `~/.config/fish/config.fish`:

    ~~~ fish
    pyenv init - | source
    ~~~

   **Bash warning**: There are some systems where the `BASH_ENV` variable is configured
   to point to `.bashrc`. On such systems, you should almost certainly put the
   `eval "$(pyenv init -)"` line into `.bash_profile`, and **not** into `.bashrc`. Otherwise, you
   may observe strange behaviour, such as `pyenv` getting into an infinite loop.
   See [#264](https://github.com/pyenv/pyenv/issues/264) for details.

   **Proxy note**: If you use a proxy, export `http_proxy` and `https_proxy`, too.

   In MacOS, you might also want to install [Fig](https://fig.io/) which
provides alternative shell completions for many command line tools with an
IDE-like popup interface in the terminal window.
(Note that their completions are independent from Pyenv's codebase
so they might be slightly out of sync for bleeding-edge interface changes.)

### Restart your shell

  for the `PATH` changes to take effect.

  ```sh
  exec "$SHELL"
  ```

### Install Python build dependencies

  [**Install Python build dependencies**](https://github.com/pyenv/pyenv/wiki#suggested-build-environment)
  before attempting to install a new Python version.

  You can now begin using Pyenv.

----


## Usage

### Install additional Python versions

To install additional Python versions, use [`pyenv install`](COMMANDS.md#pyenv-install).

For example, to download and install Python 3.10.4, run:

```sh
pyenv install 3.10.4
```

Running `pyenv install -l` gives the list of all available versions.

**NOTE:** Most Pyenv-provided Python releases are source releases and are built
from source as part of installation (that's why you need Python build dependencies preinstalled).
You can pass options to Python's `configure` and compiler flags to customize the build,
see [_Special environment variables_ in Python-Build's README](plugins/python-build/README.md#special-environment-variables)
for details.

**NOTE:** If you are having trouble installing a Python version,
please visit the wiki page about
[Common Build Problems](https://github.com/pyenv/pyenv/wiki/Common-build-problems).

**NOTE:** If you want to use proxy for download, please set the `http_proxy` and `https_proxy`
environment variables.

**NOTE:** If you'd like a faster interpreter at the cost of longer build times,
see [_Building for maximum performance_ in Python-Build's README](plugins/python-build/README.md#building-for-maximum-performance).


#### Prefix auto-resolution to the latest version

All Pyenv subcommands except `uninstall` automatically resolve full prefixes to the latest version in the corresponding version line.

`pyenv install` picks the latest known version, while other subcommands pick the latest installed version.

E.g. to install and then switch to the latest 3.10 release:

```sh
pyenv install 3.10
pyenv global 3.10
```

You can run [`pyenv latest -k <prefix>`](COMMANDS.md#pyenv-latest) to see how `pyenv install` would resolve a specific prefix, or [`pyenv latest <prefix>`](COMMANDS.md#pyenv-latest) to see how other subcommands would resolve it.

See the [`pyenv latest` documentation](COMMANDS.md#pyenv-latest) for details.


#### Python versions with extended support

For the following Python releases, Pyenv applies user-provided patches that add support for some newer environments.
Though we don't actively maintain those patches, since existing releases never change,
it's safe to assume that they will continue working until there are further incompatible changes
in a later version of those environments.

* *3.7.8-3.7.15, 3.8.4-3.8.12, 3.9.0-3.9.7* : XCode 13.3
* *3.5.10, 3.6.15* : MacOS 11+ and XCode 13.3
* *2.7.18* : MacOS 10.15+ and Apple Silicon


### Switch between Python versions

To select a Pyenv-installed Python as the version to use, run one
of the following commands:

* [`pyenv shell <version>`](COMMANDS.md#pyenv-shell) -- select just for current shell session
* [`pyenv local <version>`](COMMANDS.md#pyenv-local) -- automatically select whenever you are in the current directory (or its subdirectories)
* [`pyenv global <version>`](COMMANDS.md#pyenv-shell) -- select globally for your user account

E.g. to select the above-mentioned newly-installed Python 3.10.4 as your preferred version to use:

~~~bash
pyenv global 3.10.4
~~~

Now whenever you invoke `python`, `pip` etc., an executable from the Pyenv-provided
3.10.4 installation will be run instead of the system Python.

Using "`system`" as a version name would reset the selection to your system-provided Python.

See [Understanding shims](#understanding-shims) and
[Understanding Python version selection](#understanding-python-version-selection)
for more details on how the selection works and more information on its usage.


### Uninstall Python versions

As time goes on, you will accumulate Python versions in your
`$(pyenv root)/versions` directory.

To remove old Python versions, use [`pyenv uninstall <versions>`](COMMANDS.md#pyenv-uninstall).

Alternatively, you can simply `rm -rf` the directory of the version you want
to remove. You can find the directory of a particular Python version
with the `pyenv prefix` command, e.g. `pyenv prefix 2.6.8`.
Note however that plugins may run additional operations on uninstall
which you would need to do by hand as well. E.g. Pyenv-Virtualenv also
removes any virtual environments linked to the version being uninstalled.


### Other operations

Run `pyenv commands` to get a list of all available subcommands.
Run a subcommand with `--help` to get help on it, or see the [Commands Reference](COMMANDS.md).

Note that Pyenv plugins that you install may add their own subcommands.


## Upgrading

### Upgrading with Homebrew

If you've installed Pyenv using Homebrew, upgrade using:
```sh
brew upgrade pyenv
```

To switch from a release to the latest development version of Pyenv, use:

```sh
brew uninstall pyenv
brew install pyenv --head
```

then you can upgrade it with `brew upgrade pyenv` as usual.


### Upgrading with Installer or Git checkout

If you've installed Pyenv with Pyenv-installer, you likely have the
[Pyenv-Update](https://github.com/pyenv/pyenv-update) plugin that would
upgrade Pyenv and all installed plugins:

```sh
pyenv update
```

If you've installed Pyenv using Pyenv-installer or Git checkout, you can also
upgrade your installation at any time using Git.

To upgrade to the latest development version of pyenv, use `git pull`:

```sh
cd $(pyenv root)
git pull
```

To upgrade to a specific release of Pyenv, check out the corresponding tag:

```sh
cd $(pyenv root)
git fetch
git tag
git checkout v0.1.0
```

## Uninstalling pyenv

The simplicity of pyenv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** Pyenv managing your Python versions, simply remove the
  `pyenv init` invocations from your shell startup configuration. This will
  remove Pyenv shims directory from `PATH`, and future invocations like
  `python` will execute the system Python version, as it was before Pyenv.

    `pyenv` will still be accessible on the command line, but your Python
    apps won't be affected by version switching.

2. To completely **uninstall** Pyenv, remove _all_ Pyenv configuration lines
  from your shell startup configuration, and then remove
  its root directory. This will **delete all Python versions** that were
  installed under the `` $(pyenv root)/versions/ `` directory:

    ```sh
    rm -rf $(pyenv root)
    ```

    If you've installed Pyenv using a package manager, as a final step,
    perform the Pyenv package removal. For instance, for Homebrew:

    ```
    brew uninstall pyenv
    ```


## Pyenv plugins

Pyenv provides a simple, flexible and maintainable way to extend and customize its functionality with plugins --
as simple as creating a plugin directory and dropping a shell script on a certain subpath of it
with whatever extra logic you need to be run at certain moments.

See [_Plugins_ on the wiki](https://github.com/pyenv/pyenv/wiki/Plugins) on how to install and use plugins
as well as a catalog of some useful existing plugins for common needs.

See [_Authoring plugins_ on the wiki](https://github.com/pyenv/pyenv/wiki/Authoring-plugins) on writing your own plugins.


## Advanced Configuration

Skip this section unless you must know what every line in your shell
profile is doing.

Also see the [Environment variables](#environment-variables) section
for the environment variables that control Pyenv's behavior.

`pyenv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from RVM, some of you might be
opposed to this idea. Here's what `eval "$(pyenv init -)"` actually does:


1. **Sets up the shims path.** This is what allows Pyenv to intercept
   and redirect invocations of `python`, `pip` etc. transparently.
   It prepends `$(pyenv root)/shims` to your `$PATH`.
   It also deletes any other instances of `$(pyenv root)/shims` on `PATH`
   which allows to invoke `eval "$(pyenv init -)"` multiple times without
   getting duplicate `PATH` entries.

2. **Installs autocompletion.** This is entirely optional but pretty
   useful. Sourcing `$(pyenv root)/completions/pyenv.bash` will set that
   up. There are also completions for Zsh and Fish.

3. **Rehashes shims.** From time to time you'll need to rebuild your
   shim files. Doing this on init makes sure everything is up to
   date. You can always run `pyenv rehash` manually.

4. **Installs `pyenv` into the current shell as a shell function.**
   This bit is also optional, but allows
   pyenv and plugins to change variables in your current shell.
   This is required for some commands like `pyenv shell` to work.
   The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `pyenv` to be a real script rather than a
   shell function, you can safely skip it.

`eval "$(pyenv init --path)"` only does items 1 and 3.

To see exactly what happens under the hood for yourself, run `pyenv init -`
or `pyenv init --path`.

`eval "$(pyenv init -)"` is supposed to run at any interactive shell's
startup (including nested shells -- e.g. those invoked from editors)
so that you get completion and convenience shell functions.

`eval "$(pyenv init --path)"` can be used instead of `eval "$(pyenv init -)"`
to just enable shims, without shell integration. It can also be used to bump shims
to the front of `PATH` after some other logic has prepended stuff to `PATH`
that may shadow Pyenv's shims.

* In particular, in Debian-based distributions, the stock `~/.profile`
  prepends per-user `bin` directories to `PATH` after having sourced `~/.bashrc`.
  This necessitates appending a `pyenv init` call to `~/.profile` as well as `~/.bashrc`
  in these distributions because the system's Pip places executables for
  modules installed by a non-root user into those per-user `bin` directories.


### Using Pyenv without shims

If you don't want to use `pyenv init` and shims, you can still benefit
from pyenv's ability to install Python versions for you. Just run
`pyenv install` and you will find versions installed in
`$(pyenv root)/versions`.

You can manually execute or symlink them as required,
or you can use [`pyenv exec <command>`](COMMANDS.md#pyenv-exec)
whenever you want `<command>` to be affected by Pyenv's version selection
as currently configured.

`pyenv exec` works by prepending `$(pyenv root)/versions/<selected version>/bin`
to `PATH` in the `<command>`'s environment, the same as what e.g. RVM does.


### Environment variables

You can affect how Pyenv operates with the following environment variables:

name | default | description
-----|---------|------------
`PYENV_VERSION` | | Specifies the Python version to be used.<br>Also see [`pyenv shell`](COMMANDS.md#pyenv-shell)
`PYENV_ROOT` | `~/.pyenv` | Defines the directory under which Python versions and shims reside.<br>Also see [`pyenv root`](COMMANDS.md#pyenv-root)
`PYENV_DEBUG` | | Outputs debug information.<br>Also as: `pyenv --debug <subcommand>`
`PYENV_HOOK_PATH` | [_see wiki_][hooks] | Colon-separated list of paths searched for pyenv hooks.
`PYENV_DIR` | `$PWD` | Directory to start searching for `.python-version` files.
`PYTHON_BUILD_ARIA2_OPTS` | | Used to pass additional parameters to [`aria2`](https://aria2.github.io/).<br>If the `aria2c` binary is available on `PATH`, pyenv uses `aria2c` instead of `curl` or `wget` to download the Python Source code. If you have an unstable internet connection, you can use this variable to instruct `aria2` to accelerate the download.<br>In most cases, you will only need to use `-x 10 -k 1M` as value to `PYTHON_BUILD_ARIA2_OPTS` environment variable

See also [_Special environment variables_ in Python-Build's README](plugins/python-build/README.md#special-environment-variables)
for environment variables that can be used to customize the build.

----

## Development

The pyenv source code is [hosted on
GitHub](https://github.com/pyenv/pyenv).  It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/bats-core/bats-core):

    bats test
    bats/test/<file>.bats


### Contributing

Feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/pyenv/pyenv/issues).

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details on submitting changes.


### Version History

See [CHANGELOG.md](CHANGELOG.md).


### License

[The MIT License](LICENSE)


[pyenv-virtualenv]: https://github.com/pyenv/pyenv-virtualenv#readme
[hooks]: https://github.com/pyenv/pyenv/wiki/Authoring-plugins#pyenv-hooks
