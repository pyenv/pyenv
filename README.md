# Simple Python Version Management: pyenv

pyenv lets you easily switch between multiple versions of Python. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose
tools that do one thing well.

This project was forked from [rbenv](https://github.com/sstephenson/rbenv) and.
[ruby-build](https://github.com/sstephenson/ruby-build) and modified for Python.

### pyenv _does…_

* Let you **change the global Python version** on a per-user basis.
* Provide support for **per-project Python versions**.
* Allow you to **override the Python version** with an environment
  variable.

## Table of Contents

   * [1 How It Works](#section_1)
   * [2 Installation](#section_2)
      * [2.1 Basic GitHub Checkout](#section_2.1)
         * [2.1.1 Upgrading](#section_2.1.1)
   * [3 Usage](#section_3)
   * [4 Development](#section_4)
      * [4.1 Version History](#section_4.1)
      * [4.2 License](#section_4.2)

## <a name="section_1"></a> 1 How It Works

pyenv operates on the per-user directory `~/.pyenv`. Version names in
pyenv correspond to subdirectories of `~/.pyenv/versions`. For
example, you might have `~/.pyenv/versions/2.7.3` and
`~/.pyenv/versions/2.7.3`.

Each version is a working tree with its own binaries, like
`~/.pyenv/versions/2.7.3/bin/python2.7` and
`~/.pyenv/versions/3.2.3/bin/python3.2`. pyenv makes _shim binaries_
for every such binary across all installed versions of Python.

These shims are simple wrapper scripts that live in `~/.pyenv/shims`
and detect which Python version you want to use. They insert the
directory for the selected version at the beginning of your `$PATH`
and then execute the corresponding binary.

Because of the simplicity of the shim approach, all you need to use
pyenv is `~/.pyenv/shims` in your `$PATH`.

## <a name="section_2"></a> 2 Installation

### <a name="section_2.1"></a> 2.1 Basic GitHub Checkout

This will get you going with the latest version of pyenv and make it
easy to fork and contribute any changes back upstream.

1. Check out pyenv into `~/.pyenv`.

        $ cd
        $ git clone git://github.com/yyuu/pyenv.git .pyenv

2. Add `~/.pyenv/bin` to your `$PATH` for access to the `pyenv`
   command-line utility.

        $ echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bash_profile

    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.

3. Add pyenv init to your shell to enable shims and autocompletion.

        $ echo 'eval "$(pyenv init -)"' >> ~/.bash_profile

    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.

4. Restart your shell so the path changes take effect. You can now
   begin using pyenv.

        $ exec $SHELL

5. Install Python versions into `~/.pyenv/versions`. For example, to
   install Python 2.7.3, download and unpack the source, then run:

        $ pyenv install 2.7.3

6. Rebuild the shim binaries. You should do this any time you install
   a new Python binary (for example, when installing a new Python version,
   or when installing a gem that provides a binary).

        $ pyenv rehash

#### <a name="section_2.1.1"></a> 2.1.1 Upgrading

If you've installed pyenv using the instructions above, you can
upgrade your installation at any time using git.

To upgrade to the latest development version of pyenv, use `git pull`:

    $ cd ~/.pyenv
    $ git pull

To upgrade to a specific release of pyenv, check out the corresponding
tag:

    $ cd ~/.pyenv
    $ git fetch
    $ git tag
    v0.1.0
    v0.1.1
    v0.1.2
    v0.2.0
    $ git checkout v0.2.0

## <a name="section_3"></a> 3 Usage

## <a name="section_4"></a> 4 Development

The pyenv source code is [hosted on
GitHub](https://github.com/yyuu/pyenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/yyuu/pyenv/issues).

### <a name="section_4.1"></a> 4.1 Version History

**0.1.0** (August 31, 2012)

* Initial public release.

### <a name="section_4.2"></a> 4.2 License

(The MIT license)

Copyright (c) 2011 Sam Stephenson
Copyright (c) 2012 Yamashita, Yuu

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
