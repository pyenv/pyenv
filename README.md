# Groom your app’s Ruby environment with rbenv.

Use rbenv to pick a Ruby version for your application and guarantee
that your development environment matches production. Put rbenv to work
with [Bundler](http://gembundler.com/) for painless Ruby upgrades and
bulletproof deployments.

**Powerful in development.** Specify your app's Ruby version once,
  in a single file. Keep all your teammates on the same page. No
  headaches running apps on different versions of Ruby. Just Works™
  from the command line and with app servers like [Pow](http://pow.cx).
  Override the Ruby version anytime: just set an environment variable.

**Rock-solid in production.** Your application's executables are its
  interface with ops. With rbenv and [Bundler
  binstubs](https://github.com/sstephenson/rbenv/wiki/Understanding-binstubs)
  you'll never again need to `cd` in a cron job or Chef recipe to
  ensure you've selected the right runtime. The Ruby version
  dependency lives in one place—your app—so upgrades and rollbacks are
  atomic, even when you switch versions.

**One thing well.** rbenv is concerned solely with switching Ruby
  versions. It's simple and predictable. A rich plugin ecosystem lets
  you tailor it to suit your needs. Compile your own Ruby versions, or
  use the [ruby-build][]
  plugin to automate the process. Specify per-application environment
  variables with [rbenv-vars](https://github.com/sstephenson/rbenv-vars).
  See more [plugins on the
  wiki](https://github.com/sstephenson/rbenv/wiki/Plugins).

[**Why choose rbenv over
RVM?**](https://github.com/sstephenson/rbenv/wiki/Why-rbenv%3F)

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the Ruby Version](#choosing-the-ruby-version)
  * [Locating the Ruby Installation](#locating-the-ruby-installation)
* [Installation](#installation)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
  * [Homebrew on Mac OS X](#homebrew-on-mac-os-x)
  * [Neckbeard Configuration](#neckbeard-configuration)
  * [Installing Ruby Versions](#installing-ruby-versions)
  * [Uninstalling Ruby Versions](#uninstalling-ruby-versions)
* [Command Reference](#command-reference)
  * [rbenv local](#rbenv-local)
  * [rbenv global](#rbenv-global)
  * [rbenv shell](#rbenv-shell)
  * [rbenv versions](#rbenv-versions)
  * [rbenv version](#rbenv-version)
  * [rbenv rehash](#rbenv-rehash)
  * [rbenv which](#rbenv-which)
  * [rbenv whence](#rbenv-whence)
* [Development](#development)
  * [Version History](#version-history)
  * [License](#license)

## How It Works

At a high level, rbenv intercepts Ruby commands using shim
executables injected into your `PATH`, determines which Ruby version
has been specified by your application, and passes your commands along
to the correct Ruby installation.

### Understanding PATH

When you run a command like `ruby` or `rake`, your operating system
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

rbenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.rbenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, rbenv maintains shims in that
directory to match every Ruby command across every installed version
of Ruby—`irb`, `gem`, `rake`, `rails`, `ruby`, and so on.

Shims are lightweight executables that simply pass your command along
to rbenv. So with rbenv installed, when you run, say, `rake`, your
operating system will do the following:

* Search your `PATH` for an executable file named `rake`
* Find the rbenv shim named `rake` at the beginning of your `PATH`
* Run the shim named `rake`, which in turn passes the command along to
  rbenv

### Choosing the Ruby Version

When you execute a shim, rbenv determines which Ruby version to use by
reading it from the following sources, in this order:

1. The `RBENV_VERSION` environment variable, if specified. You can use
   the [`rbenv shell`](#rbenv-shell) command to set this environment
   variable in your current shell session.

2. The first `.ruby-version` file found by searching the directory of the
   script you are executing and each of its parent directories until reaching
   the root of your filesystem.

3. The first `.ruby-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.ruby-version` file in the current working
   directory with the [`rbenv local`](#rbenv-local) command.

4. The global `~/.rbenv/version` file. You can modify this file using
   the [`rbenv global`](#rbenv-global) command. If the global version
   file is not present, rbenv assumes you want to use the "system"
   Ruby—i.e. whatever version would be run if rbenv weren't in your
   path.

### Locating the Ruby Installation

Once rbenv has determined which version of Ruby your application has
specified, it passes the command along to the corresponding Ruby
installation.

Each Ruby version is installed into its own directory under
`~/.rbenv/versions`. For example, you might have these versions
installed:

* `~/.rbenv/versions/1.8.7-p371/`
* `~/.rbenv/versions/1.9.3-p327/`
* `~/.rbenv/versions/jruby-1.7.1/`

Version names to rbenv are simply the names of the directories in
`~/.rbenv/versions`.

## Installation

**Compatibility note**: rbenv is _incompatible_ with RVM. Please make
  sure to fully uninstall RVM and remove any references to it from
  your shell initialization files before installing rbenv.

If you're on Mac OS X, consider
[installing with Homebrew](#homebrew-on-mac-os-x).

### Basic GitHub Checkout

This will get you going with the latest version of rbenv and make it
easy to fork and contribute any changes back upstream.

1. Check out rbenv into `~/.rbenv`.

    ~~~ sh
    $ git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
    ~~~

2. Add `~/.rbenv/bin` to your `$PATH` for access to the `rbenv`
   command-line utility.

    ~~~ sh
    $ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
    ~~~

    **Ubuntu Desktop note**: Modify your `~/.bashrc` instead of `~/.bash_profile`.

    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.

3. Add `rbenv init` to your shell to enable shims and autocompletion.

    ~~~ sh
    $ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
    ~~~

    _Same as in previous step, use `~/.bashrc` on Ubuntu, or `~/.zshrc` for Zsh._

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.) Now check if rbenv was set up:

    ~~~ sh
    $ type rbenv
    #=> "rbenv is a function"
    ~~~

5. _(Optional)_ Install [ruby-build][], which provides the
   `rbenv install` command that simplifies the process of
   [installing new Ruby versions](#installing-ruby-versions).

#### Upgrading

If you've installed rbenv manually using git, you can upgrade your
installation to the cutting-edge version at any time.

~~~ sh
$ cd ~/.rbenv
$ git pull
~~~

To use a specific release of rbenv, check out the corresponding tag:

~~~ sh
$ cd ~/.rbenv
$ git fetch
$ git checkout v0.3.0
~~~

If you've [installed via Homebrew](#homebrew-on-mac-os-x), then upgrade
via its `brew` command:

~~~ sh
$ brew update
$ brew upgrade rbenv ruby-build
~~~

### Homebrew on Mac OS X

As an alternative to installation via GitHub checkout, you can install
rbenv and [ruby-build][] using the [Homebrew](http://brew.sh) package
manager on Mac OS X:

~~~
$ brew update
$ brew install rbenv ruby-build
~~~

Afterwards you'll still need to add `eval "$(rbenv init -)"` to your
profile as stated in the caveats. You'll only ever have to do this
once.

### Neckbeard Configuration

Skip this section unless you must know what every line in your shell
profile is doing.

`rbenv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from RVM, some of you might be
opposed to this idea. Here's what `rbenv init` actually does:

1. Sets up your shims path. This is the only requirement for rbenv to
   function properly. You can do this by hand by prepending
   `~/.rbenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.rbenv/completions/rbenv.bash` will set that
   up. There is also a `~/.rbenv/completions/rbenv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this automatically makes sure everything is up to
   date. You can always run `rbenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   rbenv and plugins to change variables in your current shell, making
   commands like `rbenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `rbenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `rbenv init -` for yourself to see exactly what happens under the
hood.

### Installing Ruby Versions

The `rbenv install` command doesn't ship with rbenv out of the box, but
is provided by the [ruby-build][] project. If you installed it either
as part of GitHub checkout process outlined above or via Homebrew, you
should be able to:

~~~ sh
# list all available versions:
$ rbenv install -l

# install a Ruby version:
$ rbenv install 2.0.0-p247
~~~

Alternatively to the `install` command, you can download and compile
Ruby manually as a subdirectory of `~/.rbenv/versions/`. An entry in
that directory can also be a symlink to a Ruby version installed
elsewhere on the filesystem. rbenv doesn't care; it will simply treat
any entry in the `versions/` directory as a separate Ruby version.

### Uninstalling Ruby Versions

As time goes on, Ruby versions you install will accumulate in your
`~/.rbenv/versions` directory.

To remove old Ruby versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a particular
Ruby version with the `rbenv prefix` command, e.g. `rbenv prefix
1.8.7-p357`.

The [ruby-build][] plugin provides an `rbenv uninstall` command to
automate the removal process.

## Command Reference

Like `git`, the `rbenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### rbenv local

Sets a local application-specific Ruby version by writing the version
name to a `.ruby-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `RBENV_VERSION` environment variable or with the `rbenv shell`
command.

    $ rbenv local 1.9.3-p327

When run without a version number, `rbenv local` reports the currently
configured local version. You can also unset the local version:

    $ rbenv local --unset

Previous versions of rbenv stored local version specifications in a
file named `.rbenv-version`. For backwards compatibility, rbenv will
read a local version specified in an `.rbenv-version` file, but a
`.ruby-version` file in the same directory will take precedence.

### rbenv global

Sets the global version of Ruby to be used in all shells by writing
the version name to the `~/.rbenv/version` file. This version can be
overridden by an application-specific `.ruby-version` file, or by
setting the `RBENV_VERSION` environment variable.

    $ rbenv global 1.8.7-p352

The special version name `system` tells rbenv to use the system Ruby
(detected by searching your `$PATH`).

When run without a version number, `rbenv global` reports the
currently configured global version.

### rbenv shell

Sets a shell-specific Ruby version by setting the `RBENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ rbenv shell jruby-1.7.1

When run without a version number, `rbenv shell` reports the current
value of `RBENV_VERSION`. You can also unset the shell version:

    $ rbenv shell --unset

Note that you'll need rbenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`RBENV_VERSION` variable yourself:

    $ export RBENV_VERSION=jruby-1.7.1

### rbenv versions

Lists all Ruby versions known to rbenv, and shows an asterisk next to
the currently active version.

    $ rbenv versions
      1.8.7-p352
      1.9.2-p290
    * 1.9.3-p327 (set by /Users/sam/.rbenv/version)
      jruby-1.7.1
      rbx-1.2.4
      ree-1.8.7-2011.03

### rbenv version

Displays the currently active Ruby version, along with information on
how it was set.

    $ rbenv version
    1.8.7-p352 (set by /Volumes/37signals/basecamp/.ruby-version)

### rbenv rehash

Installs shims for all Ruby executables known to rbenv (i.e.,
`~/.rbenv/versions/*/bin/*`). Run this command after you install a new
version of Ruby, or install a gem that provides commands.

    $ rbenv rehash

### rbenv which

Displays the full path to the executable that rbenv will invoke when
you run the given command.

    $ rbenv which irb
    /Users/sam/.rbenv/versions/1.9.3-p327/bin/irb

### rbenv whence

Lists all Ruby versions with the given command installed.

    $ rbenv whence rackup
    1.9.3-p327
    jruby-1.7.1
    ree-1.8.7-2011.03

## Development

The rbenv source code is [hosted on
GitHub](https://github.com/sstephenson/rbenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/sstephenson/rbenv/issues).

### Version History

**0.4.0** (January 4, 2013)

* rbenv now prefers `.ruby-version` files to `.rbenv-version` files
  for specifying local application-specific versions. The
  `.ruby-version` file has the same format as `.rbenv-version` but is
  [compatible with other Ruby version
  managers](https://gist.github.com/1912050).
* Deprecated `ruby-local-exec` and moved its functionality into the
  standard `ruby` shim. See the [ruby-local-exec wiki
  page](https://github.com/sstephenson/rbenv/wiki/ruby-local-exec) for
  upgrade instructions.
* Modified shims to include the full path to rbenv so that they can be
  invoked without having rbenv's bin directory in the `$PATH`.
* Sped up `rbenv init` by avoiding rbenv reinitialization and by
  using a simpler indexing approach. (Users of
  [chef-rbenv](https://github.com/fnichol/chef-rbenv) should upgrade
  to the latest version to fix a [compatibility
  issue](https://github.com/fnichol/chef-rbenv/pull/26).)
* Reworked `rbenv help` so that usage and documentation is stored as a
  comment in each subcommand, enabling plugin commands to hook into
  the help system.
* Added support for full completion of the command line, not just the
  first argument.
* Updated installation instructions for Zsh and Ubuntu users.
* Fixed `rbenv which` and `rbenv prefix` with system Ruby versions.
* Changed `rbenv exec` to avoid prepending the system Ruby location to
  `$PATH` to fix issues running system Ruby commands that invoke other
  commands.
* Changed `rbenv rehash` to ensure it exits with a 0 status code under
  normal operation, and to ensure outdated shims are removed first
  when rehashing.
* Modified `rbenv rehash` to run `hash -r` afterwards, when shell
  integration is enabled, to ensure the shell's command cache is
  cleared.
* Removed use of the `+=` operator to support older versions of Bash.
* Adjusted non-bare `rbenv versions` output to include `system`, if
  present.
* Improved documentation for installing and uninstalling Ruby
  versions.
* Fixed `rbenv versions` not to display a warning if the currently
  specified version doesn't exist.
* Fixed an instance of local variable leakage in the `rbenv` shell
  function wrapper.
* Changed `rbenv shell` to ensure it exits with a non-zero status on
  failure.
* Added `rbenv --version` for printing the current version of rbenv.
* Added `/usr/lib/rbenv/hooks` to the plugin hook search path.
* Fixed `rbenv which` to account for path entries with spaces.
* Changed `rbenv init` to accept option arguments in any order.

**0.3.0** (December 25, 2011)

* Added an `rbenv root` command which prints the value of
  `$RBENV_ROOT`, or the default root directory if it's unset.
* Clarified Zsh installation instructions in the Readme.
* Removed some redundant code in `rbenv rehash`.
* Fixed an issue with calling `readlink` for paths with spaces.
* Changed Zsh initialization code to install completion hooks only for
  interactive shells.
* Added preliminary support for ksh.
* `rbenv rehash` creates or removes shims only when necessary instead
  of removing and re-creating all shims on each invocation.
* Fixed that `RBENV_DIR`, when specified, would be incorrectly
  expanded to its parent directory.
* Removed the deprecated `set-default` and `set-local` commands.
* Added a `--no-rehash` option to `rbenv init` for skipping the
  automatic rehash when opening a new shell.

**0.2.1** (October 1, 2011)

* Changed the `rbenv` command to ensure that `RBENV_DIR` is always an
  absolute path. This fixes an issue where Ruby scripts using the
  `ruby-local-exec` wrapper would go into an infinite loop when
  invoked with a relative path from the command line.

**0.2.0** (September 28, 2011)

* Renamed `rbenv set-default` to `rbenv global` and `rbenv set-local`
  to `rbenv local`. The `set-` commands are deprecated and will be
  removed in the next major release.
* rbenv now uses `greadlink` on Solaris.
* Added a `ruby-local-exec` command which can be used in shebangs in
  place of `#!/usr/bin/env ruby` to properly set the project-specific
  Ruby version regardless of current working directory.
* Fixed an issue with `rbenv rehash` when no binaries are present.
* Added support for `rbenv-sh-*` commands, which run inside the
  current shell instead of in a child process.
* Added an `rbenv shell` command for conveniently setting the
  `$RBENV_VERSION` environment variable.
* Added support for storing rbenv versions and shims in directories
  other than `~/.rbenv` with the `$RBENV_ROOT` environment variable.
* Added support for debugging rbenv via `set -x` when the
  `$RBENV_DEBUG` environment variable is set.
* Refactored the autocompletion system so that completions are now
  built-in to each command and shared between bash and Zsh.
* Added support for plugin bundles in `~/.rbenv/plugins` as documented
  in [issue #102](https://github.com/sstephenson/rbenv/pull/102).
* Added `/usr/local/etc/rbenv.d` to the list of directories searched
  for rbenv hooks.
* Added support for an `$RBENV_DIR` environment variable which
  defaults to the current working directory for specifying where rbenv
  searches for local version files.

**0.1.2** (August 16, 2011)

* Fixed rbenv to be more resilient against nonexistent entries in
  `$PATH`.
* Made the `rbenv rehash` command operate atomically.
* Modified the `rbenv init` script to automatically run `rbenv
  rehash` so that shims are recreated whenever a new shell is opened.
* Added initial support for Zsh autocompletion.
* Removed the dependency on egrep for reading version files.

**0.1.1** (August 14, 2011)

* Fixed a syntax error in the `rbenv help` command.
* Removed `-e` from the shebang in favor of `set -e` at the top of
  each file for compatibility with operating systems that do not
  support more than one argument in the shebang.

**0.1.0** (August 11, 2011)

* Initial public release.

### License

(The MIT license)

Copyright (c) 2013 Sam Stephenson

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


  [ruby-build]: https://github.com/sstephenson/ruby-build#readme
