#!/usr/bin/env python3
"""Rudimentary script to add PyPY releases automagically.
Requires requests-html.

Checks the PyPy download archives for new versions,
then writes a build script for any which do not exist locally,
saving it to plugins/python-build/share/python-build.

Written and tested in *CPython* 3.9.6. PyPy3 compatibility is not
guaranteed, but it should work.
"""
from pathlib import Path
import argparse
import logging
import re
import sys

from requests_html import HTMLSession

# https://downloads.python.org/pypy/versions.json doesn't contain
# checksums, so I decided to use checksums.html instead. Of course,
# it *would* make sense to generate them from the downloaded contents,
# but since PyPy's website has the checksums in a convenient location,
# and the possiblity for bad actors to hijack the downloads, why not
# just use the checksums.html and verify with it? Just my two cents,
# if add_cpython's way is more preferred then so be it. :)
PYPY_REPO = "https://downloads.python.org/pypy/"
PYPY_CHECKSUMS = "https://pypy.org/checksums.html"

here = Path(__file__).resolve()
OUT_DIR: Path = here.parent.parent / "share" / "python-build"

EXCLUDED_RELEASES = []  # none for now

# Note: Remember to escape/unescape curly braces when editing the bash script
# TODO: THERE WILL BE A SIMPLIER, REFACTORED CODE THAT MAKES IT SMALLER AND
#       INSIDE python-build. REPLACE THIS WITH THAT ONE WHEN IT'S AVAILABLE.
SCRIPT_BIN = """
VERSION='{version_pypy}'
PYVER='{version_python}'

# https://www.pypy.org/checksums.html
aarch64_hash={checksum_aarch64}
linux32_hash={checksum_linux32}
linux64_hash={checksum_linux64}
osarm64_hash={checksum_osarm64}
osx64_hash={checksum_osx64}

### end of manual settings - following lines same for every download

function err_no_binary {{
    local archmsg="${{1}}"
    local ver="pypy${{PYVER}}-v${{VERSION}}-src"
    local url="https://downloads.python.org/pypy/${{ver}}.tar.{file_ext}"
    {{ echo
      colorize 1 "ERROR"
      echo ": The binary distribution of PyPy is not available for ${{archmsg}}."
      echo "try '${{url}}' to build from source."
      echo
    }} >&2
    exit 1
}}

function pypy_pkg_data {{
    # pypy architecture tag
    local ARCH="${{1}}"

    # defaults
    local cmd='install_package'  # use {file_ext}
    local pkg="${{ARCH}}" # assume matches
    local ext='tar.{file_ext}'
    local hash='' # undefined

    # select the hash, fix pkg if not match ARCH
    case "${{ARCH}}" in
    'linux-aarch64' )
      hash="${{aarch64_hash}}"
      pkg='aarch64'
      ;;
    'linux' )
      hash="${{linux32_hash}}"
      pkg='linux32'
      ;;
    'linux64' )
      hash="${{linux64_hash}}"
      ;;
    'osarm64' )
      hash="${{osarm64_hash}}"
      pkg='macos_arm64'
      ;;
    'osx64' )
      if require_osx_version "10.15"; then
        hash="${{osx64_hash}}"
        pkg='macos_x86_64'
      else
        err_no_binary "${{ARCH}}, OS X < 10.15"
      fi
      ;;
    * )
      err_no_binary "${{ARCH}}"
      ;;
    esac

    local basever="pypy${{PYVER}}-v${{VERSION}}"
    local baseurl="https://downloads.python.org/pypy/${{basever}}"

    # result - command, package dir, url+hash
    echo "${{cmd}}" "${{basever}}-${{pkg}}" "${{baseurl}}-${{pkg}}.${{ext}}#${{hash}}"
}}

# determine command, package directory, url+hash
declare -a pd="$(pypy_pkg_data "$(pypy_architecture 2>/dev/null || true)")"

# install
${{pd[0]}} "${{pd[1]}}" "${{pd[2]}}" 'pypy' "verify_py${{PYVER//./}}" '{ensurepip}'
""".lstrip()

SCRIPT_SRC = """
VERSION='{version_pypy}'
PYVER='{version_python}'

# https://www.pypy.org/checksums.html
hash={checksum_src}

### end of manual settings - following lines same for every download

ver="pypy${{PYVER}}-v${{VERSION}}-src"
url="https://downloads.python.org/pypy/${{ver}}.tar.{file_ext}"

prefer_openssl11
install_package "openssl-1.1.1f" "https://www.openssl.org/source/openssl-1.1.1f.tar.gz#186c6bfe6ecfba7a5b48c47f8a1673d0f3b0e5ba2e25602dd23b629975da3f35" mac_openssl --if has_broken_mac_openssl
install_package "${{ver}}" "${{url}}#${{hash}}" 'pypy_builder' "verify_py${{PYVER//./}}" '{ensurepip}'
""".lstrip()


args = None
logger = logging.getLogger(__name__)


def main() -> bool:
    html_session = HTMLSession()
    response = html_session.get(PYPY_CHECKSUMS)
    page = response.html
    checksum_blocks = page.find("pre.literal-block")
    for csum_block in checksum_blocks:
        python_version, pypy_version = parse_pypy_ver(csum_block.text)
        py_it = f"pypy{python_version}-{pypy_version}"
        if py_it not in EXCLUDED_RELEASES:
            vbin_path = OUT_DIR.joinpath(py_it)
            vsrc_path = OUT_DIR.joinpath(py_it+"-src")

            kwargs = None
            for ps in ((vbin_path, SCRIPT_BIN), (vsrc_path, SCRIPT_SRC)):
                if not ps[0].is_file():
                    kwargs = kwargs or parse_checksums_ext(csum_block.text)
                    code = ps[1].format(
                            version_pypy=pypy_version,
                            version_python=python_version,
                            ensurepip="ensurepip" if not python_version == "2.7" else "ensurepip_lt21",
                            **kwargs  # which are:
                                      # checksum_aarch64
                                      # checksum_linux32
                                      # checksum_linux64
                                      # checksum_osarm64
                                      # checksum_osx64
                                      # checksum_src
                                      # file_ext
                        )
                    if not args.dry_run:
                        with open(file=ps[0], mode="w", encoding="utf-8") as f:
                            f.write(code)
                            f.close()
                    else:
                        print(f"---- DRY RUN SCRIPT FOR {ps[0]} ----")
                        print(code)


def parse_pypy_ver(csum_block:str) -> tuple[str,str]:
    """Gets the PyPy name from the checksum block."""
    match = re.findall(r"pypy([0-9]\.[0-9]+)\-v([0-9]\.[0-9]\.[0-9]+)", csum_block)
    match = set(match)
    if len(match) == 1:
        return match.pop()
    return ""


def parse_checksums_ext(csum_block:str) -> dict:
    """Gets the checksums and ext for each platform (excluding win64) from the checksum block."""
    chksm_ex = {
        r"aarch64": "",
        r"linux32": "",
        r"linux64": "",
        r"macos_arm64": "",
        r"macos_x86_64": "",
        r"src": "",
    }
    ext = set()
    for ex in chksm_ex:
        match = re.findall(r"([a-z0-9]+) pypy[0-9]\.[0-9]+\-v[0-9]\.[0-9]\.[0-9]+-"+ex+r".tar.(gz|bz2)", csum_block)
        chksm_ex[ex] = match[0][0]
        ext.add(match[0][1])
    # if both gz and bz2, prefer bz2
    ext = ext.pop() if len(ext) == 1 else "bz2"
    return {
        "checksum_aarch64": chksm_ex["aarch64"],
        "checksum_linux32": chksm_ex["linux32"],
        "checksum_linux64": chksm_ex["linux64"],
        "checksum_osarm64": chksm_ex["macos_arm64"],
        "checksum_osx64": chksm_ex["macos_x86_64"],
        "checksum_src": chksm_ex["src"],
        "file_ext": ext
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "-d", "--dry-run", action="store_true",
        help="Do not write scripts, just report them to stdout",
    )
    args = parser.parse_args()
    #sys.excepthook seems to have no effect in Github Actions
    try:
        sys.exit(main())
    except Exception:
        logging.exception("Unhandled exception occurred")
        sys.exit(2)
