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
