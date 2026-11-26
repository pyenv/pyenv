#!/usr/bin/env python3
"""Script to add RustPython releases automagically.

Lists the version tags of the RustPython repository,
then writes a build script for any release which does not exist locally,
saving it to plugins/python-build/share/python-build.

RustPython doesn't publish release archives, so the scripts clone the tag
and pin it to its commit SHA, which python-build verifies.
"""
from pathlib import Path
import argparse
import logging
import os
import re
import sys

import requests

REPO_URL = "https://github.com/RustPython/RustPython"
TAGS_URL = "https://api.github.com/repos/RustPython/RustPython/tags"

here = Path(__file__).resolve()
OUT_DIR: Path = here.parent.parent / "share" / "python-build"

# Older releases don't build with a current Rust toolchain
# or can't install a current pip
MIN_VERSION = (0, 5, 0)

SCRIPT = """
require_cargo
install_git "rustpython-{version}" "{url}" "{version}:{sha}" rustpython ensurepip
""".lstrip()


args = None
logger = logging.getLogger(__name__)


def main() -> int:
    session = requests.Session()
    if token := os.environ.get("GITHUB_TOKEN"):
        session.headers["Authorization"] = f"Bearer {token}"

    added = False
    for version, sha in list_versions(session):
        path = OUT_DIR / f"rustpython-{version}"
        if path.exists():
            logger.debug("%s already exists", path.name)
            continue
        logger.info("Adding %s", path.name)
        code = SCRIPT.format(version=version, url=REPO_URL, sha=sha)
        if args.dry_run:
            print(f"---- DRY RUN SCRIPT FOR {path} ----")
            print(code, end="")
        else:
            path.write_text(code, encoding="utf-8")
        added = True
    return 0 if added else 1


def list_versions(session: requests.Session) -> list[tuple[str, str]]:
    """Gets the release versions and their commit SHAs from the repository tags, oldest first."""
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
                versions.append((name, tag["commit"]["sha"]))
        url = response.links.get("next", {}).get("url")
        params = None
    return sorted(versions, key=lambda v: tuple(int(n) for n in v[0].split(".")))


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
