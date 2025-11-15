#!/usr/bin/env python3
"""Script to add CPython releases.

Checks the CPython download archives for new versions,
then writes a build script for any which do not exist locally,
saving it to plugins/python-build/share/python-build.

"""
import argparse
import dataclasses
import hashlib
import io
import itertools
import logging
import operator
import pathlib
import pprint
import re
import typing
import urllib.parse

import more_itertools
import packaging.version
import requests
import requests_html
import sortedcontainers
import tqdm

logger = logging.getLogger(__name__)

REPO = "https://www.python.org/ftp/python/"

CUTOFF_VERSION=packaging.version.Version('3.9')
EXCLUDED_VERSIONS= {
    packaging.version.Version("3.9.3")  #recalled
}

here = pathlib.Path(__file__).resolve()
out_dir: pathlib.Path = here.parent.parent / "share" / "python-build"

T_THUNK=\
'''export PYTHON_BUILD_FREE_THREADING=1
source "${BASH_SOURCE[0]%t}"'''


def get_existing_scripts(name="CPython", pattern=r'^\d+\.\d+(?:(t?)(-\w+)|(.\d+((?:a|b|rc)\d)?(t?)))$'):
    """
    Enumerate existing installation scripts in share/python-build/ by pattern
    """
    logger.debug("Getting existing versions")
    for p in out_dir.iterdir():
        entry_name = p.name
        if not p.is_file() or not (m := re.match(pattern,entry_name)) or m.group(1)=='t' or m.group(5)=='t':
            continue
        try:
            v = packaging.version.Version(entry_name)
            # branch tip scrpts are different from release scripts and thus unusable as a pattern
            if v.dev is not None:
                continue
            logger.debug("Existing %(name)s version %(v)s", locals())
            yield v,entry_name
        except ValueError as e:
            logger.error("Unable to parse existing version %s: %s", entry_name, e)


def _get_download_entries(url, pattern, session=None):
    if session is None:
        session = requests_html.HTMLSession()
    response = session.get(url)
    page = response.html
    table = page.find("pre", first=True)
    # the first entry is ".."
    links = table.find("a")[1:]
    for link in links:
        name = link.text.rstrip('/')
        if not re.match(pattern, name):
            continue
        yield name, urllib.parse.urljoin(response.url,link.attrs['href'])


def get_available_versions(name="CPython", url=REPO, pattern=r'^\d+', session=None):
    """
    Fetch remote versions
    """
    logger.info("Fetching remote %(name)s versions",locals())
    for name, url in _get_download_entries(url, pattern, session):

        logger.debug(f'Available version: {name}, {url}')
        yield packaging.version.Version(name), url


def get_available_source_downloads(url, session) -> typing.Dict[
        packaging.version.Version,
        typing.Dict[str,typing.Tuple[str,str]]]:
    result: typing.Dict[packaging.version.Version, dict] = {}
    for name, url in _get_download_entries(url, r'Python-.*\.(tar\.xz|tgz)$', session):
        m=re.match(r'(?P<package>Python-(?P<version>.*))\.(?P<extension>tar\.xz|tgz)$',name)
        version = packaging.version.Version(m.group("version"))
        extension = m.group("extension")
        result.setdefault(version,{})[extension]=(m.group("package"),url)
    return result


def pick_previous_version(version: packaging.version.Version,
                          available_versions: typing.Iterable[packaging.version.Version]):
    return max(v for v in available_versions if v < version)


def adapt_script(version: packaging.version.Version,
                 extensions_urls: typing.Dict[str,typing.Tuple[str,str]],
                 previous_version: packaging.version.Version,
                 is_prerelease_upgrade: bool,
                 session: requests_html.BaseSession = None) -> None:
    previous_version_path = out_dir.joinpath(str(previous_version))
    with previous_version_path.open("r", encoding='utf-8') as f:
        script = f.readlines()
    result = io.StringIO()
    for line in script:
        if m:=re.match(r'\s*install_package\s+"(?P<package>Python-\S+)"\s+'
                       r'"(?P<url>\S+)"\s+.*\s+verify_py(?P<verify_py_suffix>\d+)\s+.*$',
                       line):
            existing_url_path = urllib.parse.urlparse(m.group('url')).path
            try:
                matched_extension = more_itertools.one(ext for ext in extensions_urls if existing_url_path.endswith(ext))
            except ValueError:
                logger.error(f'Cannot match existing URL path\'s {existing_url_path} extension '
                             f'to available packages {extensions_urls}')
                return
            new_package_name, new_package_url = extensions_urls[matched_extension]
            new_package_hash = Url.sha256_url(new_package_url, session)

            verify_py_suffix = str(version.major)+str(version.minor)

            line = Re.subgroups(m,
                                package=new_package_name,
                                url=new_package_url+'#'+new_package_hash,
                                verify_py_suffix=verify_py_suffix)

        result.write(line)
    result_path = out_dir.joinpath(str(version))
    logger.debug(f"Writing {result_path}")
    result_path.write_text(result.getvalue(), encoding='utf-8')
    result.close()

def add_version(version: packaging.version.Version,
                url: str,
                existing_versions: typing.MutableMapping[packaging.version.Version,typing.Any],
                session: requests_html.BaseSession = None):
    previous_version = pick_previous_version(version, existing_versions)
    is_prerelease_upgrade = previous_version.major==version.major\
            and previous_version.minor==version.minor\
            and previous_version.micro==version.micro
    if is_prerelease_upgrade:
        logger.info(f"Checking for a (pre)release for {version} newer than {previous_version}")
    else:
        logger.info(f"Adding {version} based on {previous_version}")

    available_downloads = get_available_source_downloads(url, session)
    latest_available_download_version = max(available_downloads.keys())
    if is_prerelease_upgrade:
        if latest_available_download_version == previous_version:
            logger.info("No newer download found")
            return False
        else:
            logger.info(f"Adding {version} replacing {previous_version}")

    adapt_script(latest_available_download_version,
                 available_downloads[latest_available_download_version],
                 previous_version,
                 is_prerelease_upgrade,
                 session)

    cleanup_prerelease_upgrade(is_prerelease_upgrade, previous_version, existing_versions)

    handle_t_thunks(version, previous_version, is_prerelease_upgrade)

    return True


def cleanup_prerelease_upgrade(
        is_prerelease_upgrade: bool,
        previous_version: packaging.version.Version,
        existing_versions: typing.MutableMapping[packaging.version.Version,typing.Any])\
        -> None:
    if is_prerelease_upgrade:
        previous_version_path = out_dir.joinpath(str(previous_version))
        logger.debug(f'Deleting {previous_version_path}')
        previous_version_path.unlink()
        del existing_versions[previous_version]


def handle_t_thunks(version, previous_version, is_prerelease_upgrade):
    if (version.major, version.minor) >= (3, 13):
        # an old thunk may have older version-specific code
        # so it's safer to write a known version-independent template
        thunk_path = out_dir.joinpath(str(version) + "t")
        logger.debug(f"Writing {thunk_path}")
        thunk_path.write_text(T_THUNK, encoding='utf-8')
        if is_prerelease_upgrade:
            previous_thunk_path = out_dir.joinpath(str(previous_version) + "t")
            logger.debug(f"Deleting {previous_thunk_path}")
            previous_thunk_path.unlink()


def main():
    args = parse_args()
    logging.basicConfig(level=logging.DEBUG if args.verbose else logging.INFO)
    cached_session=requests_html.HTMLSession()

    existing_versions = dict(get_existing_scripts())
    available_versions = dict(get_available_versions(session=cached_session))
    # version triple to triple-ified spec to raw spec
    versions_to_add = set(available_versions.keys()) - set(existing_versions.keys())
    versions_to_add = sorted({v for v in versions_to_add if v>=CUTOFF_VERSION and v not in EXCLUDED_VERSIONS})
    logger.info("Checking for new versions")
    logger.debug("Existing_versions:\n"+pprint.pformat(existing_versions))
    logger.debug("Available_versions:\n"+pprint.pformat(available_versions))
    logger.info("Versions to add:\n"+pprint.pformat(versions_to_add))
    for version_to_add in versions_to_add:
        add_version(version_to_add, available_versions[version_to_add], existing_versions, session=cached_session)


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
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


class Re:
    @dataclasses.dataclass
    class _interval:
        group: typing.Union[int, str, None]
        start: int
        end: int
    @staticmethod
    def subgroups(match: re.Match,
                  /, *args: [typing.AnyStr],
                  **kwargs: [typing.AnyStr])\
            -> typing.AnyStr:
        repls={i:repl for i,repl in enumerate(args) if repl is not None}
        repls.update({n:repl for n,repl in kwargs.items() if repl is not None})

        intervals: sortedcontainers.SortedList[Re._interval]=\
            sortedcontainers.SortedKeyList(key=operator.attrgetter("start","end"))

        for group_id in itertools.chain(range(1,len(match.groups())), match.groupdict().keys()):
            if group_id not in repls:
                continue
            if match.start(group_id) == -1:
                continue
            intervals.add(Re._interval(group_id,match.start(group_id),match.end(group_id)))
        del group_id

        last_interval=Re._interval(None,0,0)
        result=""
        for interval in intervals:
            if interval.start < last_interval.end:
                raise ValueError(f"Cannot replace intersecting matches "
                                 f"for groups {last_interval.group} and {interval.group} "
                                 f"(position {interval.start})")
            if interval.end == interval.start and \
                    last_interval.start == last_interval.end == interval.start:
                raise ValueError(f"Cannot replace consecutive zero-length matches "
                                 f"for groups {last_interval.group} and {interval.group} "
                                 f"(position {interval.start})")

            result+=match.string[last_interval.end:interval.start]+repls[interval.group]
            last_interval = interval
        result+=match.string[last_interval.end:]

        return result

class Url:
    logger = logging.getLogger("Url")
    @staticmethod
    def sha256_url(url, session=None):
        if session is None:
            session = requests_html.HTMLSession()
        logger.info(f"Downloading and computing hash of {url}")
        h=hashlib.sha256()
        r=session.get(url,stream=True)
        total_bytes=int(r.headers.get('content-length',0)) or float('inf')
        with tqdm.tqdm(total=total_bytes, unit='B', unit_scale=True, unit_divisor=1024) as t:
            for c in r.iter_content(1024):
                t.update(len(c))
                h.update(c)
        return h.hexdigest()


if __name__ == "__main__":
    main()
