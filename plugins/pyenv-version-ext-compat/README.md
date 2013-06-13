# pyenv-version-ext

pyenv-version-ext is a [pyenv](https://github.com/yyuu/pyenv) plugin
that provides a `pyenv push` and `pyenv pop` commands to manage Python
versions.

## Installation

### Installing as an pyenv plugin (recommended)

You need nothing to do since python-build is bundled with pyenv by
default.


## Usage

You can manage your version stack by `pyenv push` and `pyenv pop`.

    $ pyenv global
    2.7.5
    3.2.5
    $ pyenv push 3.3.2
    $ pyenv global
    2.7.5
    3.2.5
    3.3.2
    $ pyenv pop
    2.7.5
    3.2.5

The push/pop operation is also efective for local and shell versions.

### License

(The MIT License)

* Copyright (c) 2013 Yamashita, Yuu

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
