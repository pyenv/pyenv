# pyenv-link
A [pyenv](https://github.com/pyenv/pyenv) plugin for linking Python installations and virtual environments into your pyenv root.

This plugin recommends the [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv/) plugin.

## Usage

Make an arbitrary virtualenv available through pyenv. This automatically guesses a fitting name from the prompt, the directory name or the location of the venv.

```console
$ pyenv link version .venv
Linked new version named myproject
```

You can also specify a name to use for the venv.

```console
$ pyenv link version .venv myname
Linked new version named myname
```

The same command can give a platform-specific binary installation a shorter name:

```console
$ pyenv link version "$(pyenv root)/versions/3.13.14-linux-x86_64" 3.13.14
Linked new version named 3.13.14
```

Now you can make pyenv activate/use the venv automatically:

```console
$ pyenv local myproject
```
