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

Installing a binary package requires `tar` with xz support (typically provided
by the `xz` package).

## Commands

### `pyenv binary find <version>`

Prints the published package entry for the current platform and the checksum
of its definition, separated by a tab. `<version>` is an exact definition name;
prefixes are not resolved.

Published packages are recorded in `share/pyenv-binary/versions/<version>`, one
file per definition name. Each line holds the platform part of an entry name,
as `package-name` generates it, and the definition's SHA256, separated by a
tab. Add a line when publishing a package. For example, `versions/3.14.7`
contains:

```text
ubuntu-24.04-x86_64	e63dbcb981ec9ba83a2bc9b4d8b369620cec4aa45394559d719c5606ee9ff718
```

A package is used only on the distribution release (macOS major version) and
architecture it was built for.

### `pyenv binary install <version>`

Resolves `<version>` like `pyenv install` does, then installs the package that
`find` reports for it from pyenv.github.io under that name. It doesn't fall back
to an older version. The definition checks its system-library requirements
when an `ldconfig` cache is available; otherwise, it warns and proceeds.

```sh
pyenv binary install 3.14.7
```

A definition with the selected package entry's name in a plugin's
`share/pyenv-binary/definitions` directory overrides the published definition.
Plugins are searched in name order, and the first match is installed without
downloading the stock definition. Binary definitions don't belong in
Python-Build's definition directories, where `pyenv install` would offer them
as source versions.

### `pyenv binary package [-v|--verbose] <version>[:<entry>] --archive-base-url <url>`

Installs `<version>` from source under a separate name, packages that install
with `save`, then emits a python-build definition for it with
`generate-installer`. With no explicit entry, the name is generated from the
current platform, platform version and architecture. An explicit entry keeps
the existing custom-build workflow.

Pass `-v` to show build progress from `pyenv install`.

```sh
pyenv binary package 3.12.7 \
  --archive-base-url https://example.com/binaries
# On Debian 12 x86_64, writes 3.12.7-debian-12-x86_64.tar.xz,
# its .meta file and a `3.12.7-debian-12-x86_64' definition.

pyenv binary package 3.12.7:company-python \
  --archive-base-url https://example.com/binaries
```

The archive, metadata and definition land in the current directory, named after
the entry. Host the archive under `<url>` and pass the definition's path to
`pyenv install`.

### `pyenv binary package-name <version>`

Prints the automatically generated entry name without building anything. It
uses the distribution and release detected by Python-Build, which falls back to
the system name and release reported by `uname`; macOS uses the major version.
All names include the architecture.

```sh
pyenv binary package-name 3.12.7
# 3.12.7-debian-12-x86_64
```

### `pyenv binary save <version> [<output-dir>] [--name <name>] [--source-version <version>]`

Packs an installed version into `<version>-<platform>.tar.xz` (relative paths)
and writes `<version>-<platform>.meta` describing the build platform (OS, arch,
distro and libc version) and the system libraries the build links against. Use
`--name` to set a different base name for both files. `--source-version` records
the source version when the installed version has a different name.

```sh
pyenv binary save 3.12.7 ./dist
```

### `pyenv binary generate-installer <metadata-file> --archive-url <url> [-o <output>]`

Reads a `.meta` file and emits a python-build definition. Pass its path to
`pyenv install` to install the archive. The archive location is a parameter, so
you can host it anywhere (it does not have to be a pyenv location); the archive
itself must sit next to the `.meta` file so its checksum can be baked into the
definition.

The definition refuses to install on a different OS/architecture, or an older
glibc, than the archive was built for, and checks that the system libraries it
needs are present.

```sh
pyenv binary generate-installer ./dist/3.12.7-linux-x86_64.meta \
  --archive-url https://example.com/3.12.7-linux-x86_64.tar.xz \
  -o ./dist/3.12.7-linux-x86_64

pyenv install ./dist/3.12.7-linux-x86_64
```

### `pyenv binary relocate <prefix> [<build-prefix>]`

Rewrites the rpaths of a Python tree unpacked into `<prefix>` so the interpreter
and its extension modules load the bundled libraries from there rather than from
the path the archive was built at. Linux and FreeBSD use `patchelf`; macOS
requires the original `<build-prefix>`. The generated definition calls this;
you rarely run it by hand.

Relocation is implemented for Linux, FreeBSD and macOS.
