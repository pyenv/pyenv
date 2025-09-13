#!/usr/bin/env python3
"""Script to add CPython releases.

Checks the CPython download archives for new versions,
then writes a build script for any which do not exist locally,
saving it to plugins/python-build/share/python-build.

"""
import argparse
import collections
import functools
import logging
import pathlib
import re
import string
import sys
import textwrap
import typing
from enum import Enum
from typing import NamedTuple, List, Optional, DefaultDict, Dict

import packaging.version
import requests_html

logger = logging.getLogger(__name__)

REPO = "https://www.python.org/ftp/python/"

here = pathlib.Path(__file__).resolve()
out_dir: pathlib.Path = here.parent.parent / "share" / "python-build"


class StrEnum(str, Enum):
    """Enum subclass whose members are also instances of str
    and directly comparable to strings. str type is forced at declaration.

    Adapted from https://github.com/kissgyorgy/enum34-custom/blob/dbc89596761c970398701d26c6a5bbcfcf70f548/enum_custom.py#L100
    (MIT license)
    """

    def __new__(cls, *args):
        for arg in args:
            if not isinstance(arg, str):
                raise TypeError("Not text %s:" % arg)

        return super(StrEnum, cls).__new__(cls, *args)

    def __str__(self):
        return str(self.value)


class SupportedOS(StrEnum):
    LINUX = "Linux"
    MACOSX = "MacOSX"


PyVersion = None
class PyVersionMeta(type):
    def __getattr__(self, name):
        """Generate PyVersion.PYXXX on demand to future-proof it"""
        if PyVersion is not None:
            return PyVersion(name.lower())
        return super(PyVersionMeta,self).__getattr__(self, name)


@collections.dataclass(frozen=True)
class PyVersion(metaclass=PyVersionMeta):
    major: str
    minor: str

    def __init__(self, value):
        (major, minor) = re.match(r"py(\d)(\d+)", value).groups()
        object.__setattr__(self, "major", major)
        object.__setattr__(self, "minor", minor)

    @property
    def value(self):
        return f"py{self.major}{self.minor}"

    def version(self):
        return f"{self.major}.{self.minor}"

    def version_info(self):
        return (self.major, self.minor)

    def __str__(self):
        return self.value


@functools.total_ordering
class VersionStr(str):
    def info(self):
        return tuple(int(n) for n in self.replace("-", ".").split("."))

    def __eq__(self, other):
        return str(self) == str(other)

    def __lt__(self, other):
        if isinstance(other, VersionStr):
            return self.info() < other.info()
        raise ValueError("VersionStr can only be compared to other VersionStr")

    @classmethod
    def from_info(cls, version_info):
        return VersionStr(".".join(str(n) for n in version_info))

    def __hash__(self):
        return hash(str(self))


class CondaVersion(NamedTuple):
    version_str: VersionStr
    py_version: Optional[PyVersion]

    @classmethod
    def from_str(cls, s):
        """
        Convert a string of the form "miniconda_n-ver" or "miniconda_n-py_ver-ver" to a :class:`CondaVersion` object.
        """
        miniconda_n, _, remainder = s.partition("-")
        suffix = miniconda_n[-1]
        if suffix in string.digits:
            flavor = miniconda_n[:-1]
        else:
            flavor = miniconda_n
            suffix = ""

        components = remainder.split("-")
        if flavor == Flavor.MINICONDA and len(components) >= 2:
            py_ver, *ver_parts = components
            py_ver = PyVersion(f"py{py_ver.replace('.', '')}")
            ver = "-".join(ver_parts)
        else:
            ver = "-".join(components)
            py_ver = None

        return CondaVersion(Flavor(flavor), Suffix(suffix), VersionStr(ver), py_ver)

    def to_filename(self):
        if self.py_version:
            return f"{self.flavor}{self.suffix}-{self.py_version.version()}-{self.version_str}"
        else:
            return f"{self.flavor}{self.suffix}-{self.version_str}"

    def default_py_version(self):
        """
        :class:`PyVersion` of Python used with this Miniconda version
        """
        if self.py_version:
            return self.py_version

        v = self.version_str.info()
        if self.flavor == "miniconda":
            # https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-python.html
            if v < (4, 7):
                return PyVersion.PY36
            if v < (4, 8):
                return PyVersion.PY37
            else:
                # since 4.8, Miniconda specifies versions explicitly in the file name
                raise ValueError("Miniconda 4.8+ is supposed to specify a Python version explicitly")
        if self.flavor == "anaconda":
            # https://docs.anaconda.com/free/anaconda/reference/release-notes/
            if v >= (2024,6):
                return PyVersion.PY312
            if v >= (2023,7):
                return PyVersion.PY311
            if v >= (2023,3):
                return PyVersion.PY310
            if v >= (2021,11):
                return PyVersion.PY39
            if v >= (2020,7):
                return PyVersion.PY38
            if v >= (2020,2):
                return PyVersion.PY37
            if v >= (5,3,0):
                return PyVersion.PY37
            return PyVersion.PY36

        raise ValueError(self.flavor)


class PyenvCPythonVersion(packaging.version.Version):
    _free_threaded: bool = False

    def __init__(self, version_str):
        m = re.match(r"^(.*[^a-zA-Z])t$", version_str)
        if m:
            self._free_threaded = True
            version_str = m.group(1)
        super().__init__(self, version_str)


def make_script(specs: List[CondaSpec]):
    install_lines = [s.to_install_lines() for s in specs]
    return install_script_fmt.format(
        install_lines="\n".join(install_lines),
        tflavor=specs[0].tflavor,
    )


def get_existing_scripts(name, pattern) -> typing.Generator[typing.Tuple[str, PyenvCPythonVersion]]:
    """
    Enumerate existing installation scripts in share/python-build/ by pattern
    """
    logger.debug("Getting existing versions")
    for p in out_dir.iterdir():
        entry_name = p.name
        if not p.is_file() or not re.match(pattern,entry_name):
            continue
        try:
            v = PyenvCPythonVersion(entry_name)
            logger.debug("Existing %(name)s version %(v)s", locals())
            yield entry_name, v
        except ValueError as e:
            logger.error("Unable to parse existing version %s: %s", entry_name, e)


def get_available_versions(name, repo) -> typing.Generator[typing.Tuple[str, str]]:
    """
    Fetch remote versions
    """
    logger.info("Fetching remote %(name)s versions",locals())
    session = requests_html.HTMLSession()
    response = session.get(repo)
    page: requests_html.HTML = response.html
    table = page.find("pre", first=True)
    # the first entry is ".."
    links = table.find("a")[1:]
    for link in links:
        logger.debug('Available %(name)s version: %(link)s', locals())
        yield link.text, link.attrs['href']

def main():
    args = parse_args()
    logging.basicConfig(level=logging.DEBUG if args.verbose else logging.INFO)

    existing_versions = dict(get_existing_scripts("CPython", "^\d++\.\d++(?!-)"))
    available_versions = dict(get_available_versions("CPython", REPO))
    # version triple to triple-ified spec to raw spec
    versions_to_add = set(available_versions.keys()) - set(existing_versions.keys())
    logger.info("Checking for new versions")
    for s in sorted(available_specs, key=key_fn):
        key = s.version
        vv = key.version_str.info()

        reason = None
        if key in existing_versions:
            reason = "already exists"
        elif key.version_str.info() <= (4, 3, 30):
            reason = "too old"
        elif len(key.version_str.info()) >= 4 and "-" not in key.version_str:
            reason = "ignoring hotfix releases"

        if reason:
            logger.debug("Ignoring version %(s)s (%(reason)s)", locals())
            continue

        to_add[key][s] = s
    logger.info("Writing %s scripts", len(to_add))
    for ver, d in to_add.items():
        specs = list(d.values())
        fpath = out_dir / ver.to_filename()
        script_str = make_script(specs)
        logger.info("Writing script for %s", ver)
        if args.dry_run:
            print(f"Would write spec to {fpath}:\n" + textwrap.indent(script_str, "  "))
        else:
            with open(fpath, "w") as f:
                f.write(script_str)


def parse_args():
    parser = ArgumentParser(description=__doc__)
    parser.add_argument(
        "-d", "--dry-run", action="store_true",
        help="Do not write scripts, just report them to stdout",
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", default=0,
        help="Increase verbosity of logging",
    )
    parsed = parser.parse_args()
    return parsed


if __name__ == "__main__":
    main()
