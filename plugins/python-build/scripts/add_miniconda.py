#!/usr/bin/env python3.7
"""Script to add non-"latest" miniconda releases.

- Ignores releases below 4.3.30.
- Ignores sub-patch releases if that major.minor.patch already exists
  - But otherwise, takes the latest sub-patch release for given OS/arch
- Assumes all miniconda3 releases default to python 3.6 (correct at time of writing)

Use -d for dry run.
"""
import textwrap
from argparse import ArgumentParser
from collections import defaultdict
from enum import Enum
from functools import total_ordering
from pathlib import Path
from typing import NamedTuple, List, Optional, DefaultDict, Dict

import requests_html

CONDA_REPO = "https://repo.anaconda.com"
MINICONDA_REPO = CONDA_REPO + "/miniconda"
# ANACONDA_REPO = CONDA_REPO + "/archive"

install_script_fmt = """
case "$(anaconda_architecture 2>/dev/null || true)" in
{install_lines}
* )
  {{ echo
    colorize 1 "ERROR"
    echo ": The binary distribution of Miniconda is not available for $(anaconda_architecture 2>/dev/null || true)."
    echo
  }} >&2
  exit 1
  ;;
esac
""".lstrip()

install_line_fmt = """
"{os}-{arch}" )
  install_script "Miniconda{suffix}-{version_str}-{os}-{arch}" "{repo}/Miniconda{suffix}-{version_str}-{os}-{arch}.sh#{md5}" "miniconda" verify_{py_version}
  ;;
""".strip()

here = Path(__file__).resolve()
out_dir: Path = here.parent.parent / "share" / "python-build"


class StrEnum(str, Enum):
    """Enum subclass which members are also instances of str
    and directly comparable to strings. str type is forced at declaration.

    Adapted from https://github.com/kissgyorgy/enum34-custom/blob/dbc89596761c970398701d26c6a5bbcfcf70f548/enum_custom.py#L100
    (MIT license)
    """
    def __new__(cls, *args):
        for arg in args:
            if not isinstance(arg, str):
                raise TypeError('Not text %s:' % arg)

        return super(StrEnum, cls).__new__(cls, *args)

    def __str__(self):
        return str(self.value)


class SupportedOS(StrEnum):
    LINUX = "Linux"
    MACOSX = "MacOSX"


class SupportedArch(StrEnum):
    PPC64LE = "ppc64le"
    X86_64 = "x86_64"
    X86 = "x86"


class Suffix(StrEnum):
    TWO = "2"
    THREE = "3"


class PyVersion(StrEnum):
    PY27 = "py27"
    PY36 = "py36"
    PY37 = "py37"
    PY38 = "py38"
    PY39 = "py39"

    def version(self):
        first, *others = self.value[2:]
        return f"{first}.{''.join(others)}"

    def version_info(self):
        return tuple(int(n) for n in self.version().split('.'))


@total_ordering
class VersionStr(str):
    def info(self):
        return tuple(int(n) for n in self.split('.'))

    def __eq__(self, other):
        return str(self) == str(other)

    def __lt__(self, other):
        if isinstance(other, VersionStr):
            return self.info() < other.info()
        raise ValueError("VersionStr can only be compared to other VersionStr")

    @classmethod
    def from_info(cls, version_info):
        return VersionStr('.'.join(str(n) for n in version_info))

    def __hash__(self):
        return hash(str(self))


class MinicondaVersion(NamedTuple):
    suffix: Suffix
    version_str: VersionStr

    @classmethod
    def from_str(cls, s):
        miniconda_n, ver = s.split('-')
        return MinicondaVersion(Suffix(miniconda_n[-1]), VersionStr(ver))

    def to_filename(self):
        return f"miniconda{self.suffix}-{self.version_str}"

    def default_py_version(self):
        if self.suffix == Suffix.TWO:
            return PyVersion.PY27
        else:
            # https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-python.html
            return PyVersion.PY36

    def with_version_triple(self):
        return MinicondaVersion(self.suffix, VersionStr.from_info(self.version_str.info()[:3]))


class MinicondaSpec(NamedTuple):
    version: MinicondaVersion
    os: SupportedOS
    arch: SupportedArch
    md5: str
    py_version: Optional[PyVersion] = None

    @classmethod
    def from_filestem(cls, stem, md5, py_version=None):
        miniconda_n, ver, os, arch = stem.split('-')
        spec = MinicondaSpec(
            MinicondaVersion(
                Suffix(miniconda_n[-1]),
                VersionStr(ver),
            ),
            SupportedOS(os),
            SupportedArch(arch),
            md5,
        )
        if py_version is None:
            spec = spec.with_py_version(spec.version.default_py_version())
        return spec

    def to_install_lines(self):
        return install_line_fmt.format(
            repo=MINICONDA_REPO,
            suffix=self.version.suffix,
            version_str=self.version.version_str,
            os=self.os,
            arch=self.arch,
            md5=self.md5,
            py_version=self.py_version,
        )

    def with_py_version(self, py_version: PyVersion):
        return MinicondaSpec(*self[:-1], py_version=py_version)

    def with_version_triple(self):
        version, *others = self
        return MinicondaSpec(version.with_version_triple(), *others)


def make_script(specs: List[MinicondaSpec]):
    install_lines = [s.to_install_lines() for s in specs]
    return install_script_fmt.format(install_lines='\n'.join(install_lines))


def get_existing_minicondas():
    for p in out_dir.iterdir():
        name = p.name
        if not p.is_file() or not name.startswith("miniconda"):
            continue
        try:
            v = MinicondaVersion.from_str(name)
            if v.version_str != "latest":
                yield v
        except ValueError:
            pass


def get_available_minicondas():
    session = requests_html.HTMLSession()
    response = session.get(MINICONDA_REPO)
    page: requests_html.HTML = response.html
    table = page.find('table', first=True)
    rows = table.find("tr")[1:]
    for row in rows:
        f, size, date, md5 = row.find('td')
        fname = f.text
        md5 = md5.text

        if not fname.endswith(".sh"):
            continue
        stem = fname[:-3]

        try:
            s = MinicondaSpec.from_filestem(stem, md5)
            if s.version.version_str != "latest":
                yield s
        except ValueError:
            pass


def key_fn(spec: MinicondaSpec):
    return (
        spec.version.version_str.info(),
        spec.version.suffix.value,
        spec.os.value,
        spec.arch.value,
    )


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("-d", "--dry_run", action="store_true")
    parsed = parser.parse_args()

    existing_versions = set(get_existing_minicondas())
    available_specs = set(get_available_minicondas())

    # version triple to triple-ified spec to raw spec
    to_add: DefaultDict[MinicondaVersion, Dict[MinicondaSpec, MinicondaSpec]] = defaultdict(dict)

    for s in sorted(available_specs, key=key_fn):
        key = s.version.with_version_triple()
        if key in existing_versions or key.version_str.info() <= (4, 3, 30):
            continue

        to_add[key][s.with_version_triple()] = s

    for ver, d in to_add.items():
        specs = list(d.values())
        fpath = out_dir / ver.to_filename()
        script_str = make_script(specs)

        if parsed.dry_run:
            print(f"Would write spec to {fpath}:\n" + textwrap.indent(script_str, '  '))
        else:
            with open(fpath, 'w') as f:
                f.write(script_str)

