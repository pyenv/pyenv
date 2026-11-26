#!/usr/bin/env python3
"""Script to add RustPython releases automagically.

Lists the version tags of the RustPython repository,
then writes a build script for any release which does not exist locally,
saving it to plugins/python-build/share/python-build.

RustPython doesn't publish release archives or checksums,
so the source archive of each new tag is downloaded to compute one.
"""
from pathlib import Path
import argparse
import hashlib
import logging
import os
import re
import sys

import requests

REPO = "RustPython/RustPython"
TAGS_URL = f"https://api.github.com/repos/{REPO}/tags"
ARCHIVE_URL = f"https://github.com/{REPO}/archive/refs/tags/{{tag}}.tar.gz"

here = Path(__file__).resolve()
OUT_DIR: Path = here.parent.parent / "share" / "python-build"

# Releases before this don't build with a current Rust toolchain
MIN_VERSION = (0, 3, 0)

SCRIPT = """
require_cargo
install_package "rustpython-{version}" "{url}#{checksum}" rustpython ensurepip
""".lstrip()


args = None
logger = logging.getLogger(__name__)


def main() -> int:
    session = requests.Session()
    if token := os.environ.get("GITHUB_TOKEN"):
        session.headers["Authorization"] = f"Bearer {token}"

    added = False
    for version in list_versions(session):
        path = OUT_DIR / f"rustpython-{version}"
        if path.exists():
            logger.debug("%s already exists", path.name)
            continue
        url = ARCHIVE_URL.format(tag=version)
        logger.info("Adding %s", path.name)
        code = SCRIPT.format(version=version, url=url, checksum=sha256_url(session, url))
        if args.dry_run:
            print(f"---- DRY RUN SCRIPT FOR {path} ----")
            print(code, end="")
        else:
            path.write_text(code, encoding="utf-8")
        added = True
    return 0 if added else 1


def list_versions(session: requests.Session) -> list[str]:
    """Gets the release versions from the repository tags, oldest first."""
    versions = []
    url = TAGS_URL
    params = {"per_page": 100}
    while url:
        response = session.get(url, params=params, timeout=30)
        response.raise_for_status()
        for tag in response.json():
            name = tag["name"]
            if not re.fullmatch(r"\d+\.\d+\.\d+", name):
                continue
            if tuple(int(n) for n in name.split(".")) >= MIN_VERSION:
                versions.append(name)
        url = response.links.get("next", {}).get("url")
        params = None
    return sorted(versions, key=lambda v: tuple(int(n) for n in v.split(".")))


def sha256_url(session: requests.Session, url: str) -> str:
    logger.debug("Downloading %s", url)
    h = hashlib.sha256()
    with session.get(url, stream=True, timeout=60) as response:
        response.raise_for_status()
        for chunk in response.iter_content(chunk_size=1 << 16):
            h.update(chunk)
    return h.hexdigest()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "-d", "--dry-run", action="store_true",
        help="Do not write scripts, just report them to stdout",
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true",
        help="Increase verbosity",
    )
    args = parser.parse_args()
    logging.basicConfig(level=logging.DEBUG if args.verbose else logging.INFO)
    try:
        sys.exit(main())
    except Exception:
        logging.exception("Unhandled exception occurred")
        sys.exit(2)
