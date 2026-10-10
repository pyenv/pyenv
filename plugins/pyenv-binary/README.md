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

### `pyenv binary find <definition>`

Takes an exact definition name and prints it, the matching package entry and
definition checksum, separated by tabs. Does not resolve version prefixes,
download or install anything. Exits unsuccessfully if no package matches or
more than one entry matches the host.

### `pyenv binary install <version>`

Resolves `<version>` using the existing installable-version lookup, then installs
a matching published package from pyenv.github.io under that resolved name. It
does not fall back to an older version if the resolved version has no binary.
Linux requires the same distribution, release and architecture; macOS requires
the same major version and architecture. These are package-selection rules,
not a guarantee of runtime compatibility.

Available builds are recorded in `share/pyenv-binary/versions/<definition>`, one
file per full definition name. Each row contains a build suffix and the SHA256
of its published Python-Build definition, separated by a tab, with no header.
For example, `versions/3.14.7` contains:

```text
ubuntu-24.04-x86_64	e63dbcb981ec9ba83a2bc9b4d8b369620cec4aa45394559d719c5606ee9ff718
```

The entry name is `<definition>-<suffix>`. Merge record updates only after the
matching published artifacts are available. This checksum pins the
definition, not the archive; the verified definition contains the archive's
checksum.

The definition checks its system-library requirements when an `ldconfig` cache
is available; otherwise, it warns and proceeds.

```sh
pyenv binary install 3.14.7
```

A definition with the selected package entry's name in a plugin's
`share/python-build` directory overrides the published definition. The normal
Python-Build search order applies, including `PYTHON_BUILD_DEFINITIONS`.
Local definitions are installed without downloading the stock definition.

### `pyenv binary package [-v|--verbose] <version>[:<entry>] --archive-base-url <url>`

Installs `<version>` from source under a separate name, packages that install
with `save`, then emits a python-build definition for it with
`generate-installer`. With no explicit entry, the name is generated from the
current platform, architecture and release (major version on macOS). An explicit
entry keeps the existing custom-build workflow.

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
the entry. Host the archive under `<url>` and drop the definition into
python-build's definition directory.

### `pyenv binary package-name <version>`

Prints the automatically generated entry name without building anything. Linux
uses the distribution name and version, macOS uses the major version, and other
systems use the name and release reported by `uname`. All names include the
architecture.

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
  --archive-url https://example.com/3.12.7-linux-x86_64.tar.xz \
  -o "$(pyenv root)/plugins/python-build/share/python-build/3.12.7-linux-x86_64"

pyenv install 3.12.7-linux-x86_64
```

### `pyenv binary relocate <prefix> [<build-prefix>]`

Rewrites the rpaths of a Python tree unpacked into `<prefix>` so the interpreter
and its extension modules load the bundled libraries from there rather than from
the path the archive was built at. Linux and FreeBSD use `patchelf`; macOS
requires the original `<build-prefix>`. The generated definition calls this;
you rarely run it by hand.

Relocation is implemented for Linux, FreeBSD and macOS.
