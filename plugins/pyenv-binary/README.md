# pyenv-binary (experimental)

Package an installed Python version into a relocatable archive that can be
installed on another machine.

This is experimental and intentionally decoupled: it does not change
`pyenv install` or any other command. You drive it explicitly through
`pyenv binary`. Run `pyenv binary <command> --help` for details on a command.

## Portability

An archive is portable across machines that share its build platform (OS,
architecture and a compatible libc) and have the recorded system libraries. It
is not portable across, say, glibc and musl, or to an older glibc; the platform
and dependency metadata exist to catch that.

## Commands

### `pyenv binary save <version> [<output-dir>]`

Packs an installed version into `<version>-<platform>.tar.gz` (relative paths)
and writes `<version>-<platform>.meta` describing the build platform (OS, arch,
distro and libc version) and the system libraries the build links against.

```sh
pyenv binary save 3.12.7 ./dist
```

### `pyenv binary generate-installer <metadata-file> --archive-url <url> [-o <output>]`

Reads a `.meta` file and emits a python-build definition. Drop it into
python-build's definition directory and `pyenv install <name>` installs the
archive like any other version. The archive location is a parameter, so you can
host it anywhere (it does not have to be a pyenv location); the archive itself
must sit next to the `.meta` file so its checksum can be baked into the
definition.

The definition refuses to install on a different OS/architecture, or an older
glibc, than the archive was built for, and checks that the system libraries it
needs are present.

```sh
pyenv binary generate-installer ./dist/3.12.7-linux-x86_64.meta \
  --archive-url https://example.com/3.12.7-linux-x86_64.tar.gz \
  -o "$(pyenv root)/plugins/python-build/share/python-build/3.12.7-linux-x86_64"

pyenv install 3.12.7-linux-x86_64
```

### `pyenv binary relocate <prefix>`

Rewrites the rpaths of a Python tree unpacked into `<prefix>` so the interpreter
and its extension modules load the bundled libraries from there rather than from
the path the archive was built at. Uses `patchelf`. The generated definition
calls this; you rarely run it by hand.

Relocation is implemented for Linux; macOS is not wired up yet.
