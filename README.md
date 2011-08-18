# Simple Ruby Version Management: rbenv

<img src="http://i.sstephenson.us/rbenv.png" width="894" height="464">

rbenv lets you easily switch between multiple versions of Ruby. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose
tools that do one thing well.

### rbenv _does…_

* Let you **change the default Ruby version** on a per-user basis.
* Provide support for **per-project Ruby versions**.
* Allow you to **override the Ruby version** with an environment
  variable.

### In contrast with rvm, rbenv _does not…_

* **Need to be loaded into your shell.** Instead, rbenv's shim
    approach works by adding a directory to your `$PATH`.
* **Override shell commands like `cd`.** That's dangerous and
    error-prone.
* **Have a configuration file.** There's nothing to configure except
    which version of Ruby you want to use.
* **Install Ruby.** You can build and install Ruby yourself, or use
    [ruby-build](https://github.com/sstephenson/ruby-build) to
    automate the process.
* **Manage gemsets.** [Bundler](http://gembundler.com/) is a better
    way to manage application dependencies. If you have projects that
    are not yet using Bundler you can install the
    [rbenv-gemset](https://github.com/jamis/rbenv-gemset) plugin.
* **Require changes to Ruby libraries for compatibility.** The
    simplicity of rbenv means as long as it's in your `$PATH`,
    [nothing](https://rvm.beginrescueend.com/integration/bundler/)
    [else](https://rvm.beginrescueend.com/integration/capistrano/)
    needs to know about it.
* **Prompt you with warnings when you switch to a project.** Instead
    of executing arbitrary code, rbenv reads just the version name
    from each project. There's nothing to "trust."

## Table of Contents

   * [1 How It Works](#section_1)
   * [2 Installation](#section_2)
   * [3 Usage](#section_3)
      * [3.1 default](#section_3.1)
      * [3.2 local](#section_3.2)
      * [3.3 versions](#section_3.3)
      * [3.4 version](#section_3.4)
      * [3.5 rehash](#section_3.5)
   * [4 Contributing](#section_4)
      * [4.1 License](#section_4.1)

## <a name="section_1"></a> 1 How It Works

rbenv operates on the per-user directory `~/.rbenv`. Version names in
rbenv correspond to subdirectories of `~/.rbenv/versions`. For
example, you might have `~/.rbenv/versions/1.8.7-p354` and
`~/.rbenv/versions/1.9.3-preview1`.

Each version is a working tree with its own binaries, like
`~/.rbenv/versions/1.8.7-p354/bin/ruby` and
`~/.rbenv/versions/1.9.3-preview1/irb`. rbenv makes _shim binaries_
for every such binary across all installed versions of Ruby.

These shims are simple wrapper scripts that live in `~/.rbenv/shims`
and detect which Ruby version you want to use. They insert the
directory for the selected version at the beginning of your `$PATH`
and then execute the corresponding binary.

Because of the simplicity of the shim approach, all you need to use
rbenv is `~/.rbenv/shims` in your `$PATH`.

## <a name="section_2"></a> 2 Installation

rbenv is a young project, so for now you must install it from source.

**Compatibility note**: rbenv is _incompatible_ with rvm. Things will
  appear to work until you try to install a gem. The problem is that
  rvm actually overrides the `gem` command with a shell function!
  Please remove any references to rvm before using rbenv.

1. Check out rbenv into `~/.rbenv`.

        $ cd
        $ git clone git://github.com/sstephenson/rbenv.git .rbenv

2. Add `~/.rbenv/bin` to your `$PATH` for access to the `rbenv`
command-line utility.

        $ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> .bash_profile

3. Add rbenv's shims directory to your `$PATH` and set up Bash
autocompletion. (If you prefer not to load rbenv in your shell, you
can manually add `$HOME/.rbenv/shims` to your path in step 2.)

        $ echo 'eval "$(rbenv init -)"' >> .bash_profile

4. Restart your shell. You can now begin using rbenv.

        $ exec

5. Install Ruby versions into `~/.rbenv/versions`. For example, to
install Ruby 1.9.2-p290, download and unpack the source, then run:

        $ ./configure --prefix=$HOME/.rbenv/versions/1.9.2-p290
        $ make
        $ make install

    The [ruby-build](https://github.com/sstephenson/ruby-build)
    project simplifies this process to a single command:

        $ ruby-build 1.9.2-p290 $HOME/.rbenv/versions/1.9.2-p290

6. Rebuild the shim binaries. You should do this any time you install
a new Ruby binary (for example, when installing a new Ruby version, or
when installing a gem that provides a binary).

        $ rbenv rehash

## <a name="section_3"></a> 3 Usage

Like `git`, the `rbenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### <a name="section_3.1"></a> 3.1 default

Sets the default version of Ruby to be used in all shells by writing
the version name to the `~/.rbenv/default` file. This version can be
overridden by a per-project `.rbenv-version` file, or by setting the
`RBENV_VERSION` environment variable.

    $ rbenv default 1.9.2-p290

The special version name `system` tells rbenv to use the system Ruby
(detected by searching your `$PATH`).

When run without a version number the currently configured default
version is reported.

### <a name="section_3.2"></a> 3.2 local

Sets a local per-project Ruby version by writing the version name to
an `.rbenv-version` file in the current directory. This version
overrides the default, and can be overridden itself by setting the
`RBENV_VERSION` environment variable.

    $ rbenv local rbx-1.2.4

When run without a version number the currently configured local
version is reported.

### <a name="section_3.3"></a> 3.3 versions

Lists all Ruby versions known to rbenv, and shows an asterisk next to
the currently active version.

    $ rbenv versions
      1.8.7-p352
      1.9.2-p290
    * 1.9.3-preview1 (set by /Users/sam/.rbenv/default)
      jruby-1.6.3
      rbx-1.2.4
      ree-1.8.7-2011.03

### <a name="section_3.4"></a> 3.4 version

Displays the currently active Ruby version, along with information on
how it was set.

    $ rbenv version
    1.8.7-p352 (set by /Volumes/37signals/basecamp/.rbenv-version)

### <a name="section_3.5"></a> 3.5 rehash

Installs shims for all Ruby binaries known to rbenv (i.e.,
`~/.rbenv/versions/*/bin/*`). Run this command after you install a new
version of Ruby, or install a gem that provides binaries.

    $ rbenv rehash

## <a name="section_4"></a> 4 Contributing

The rbenv source code is [hosted on
GitHub](https://github.com/sstephenson/rbenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/sstephenson/rbenv/issues).

### <a name="section_4.1"></a> 4.1 License

(The MIT license)

Copyright (c) 2011 Sam Stephenson

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
