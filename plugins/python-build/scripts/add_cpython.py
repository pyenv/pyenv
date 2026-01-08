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
import sys
import typing
import urllib.parse

import jc
import more_itertools
import packaging.version
import requests
import requests_html
import sortedcontainers
import tqdm

logger = logging.getLogger(__name__)

CUTOFF_VERSION=packaging.version.Version('3.9')
EXCLUDED_VERSIONS= {
    packaging.version.Version("3.9.3")  #recalled upstream
}

here = pathlib.Path(__file__).resolve()
OUT_DIR: pathlib.Path = here.parent.parent / "share" / "python-build"

T_THUNK=\
'''export PYTHON_BUILD_FREE_THREADING=1
source "${BASH_SOURCE[0]%t}"'''


def adapt_script(version: packaging.version.Version,
                 previous_version: packaging.version.Version) -> typing.Union[pathlib.Path, None]:

    previous_version_path = OUT_DIR.joinpath(str(previous_version))

    with previous_version_path.open("r", encoding='utf-8') as f:
        script = f.readlines()
    result = io.StringIO()
    for line in script:
        if m:=re.match(r'\s*install_package\s+"(?P<package>Python-\S+)"\s+'
                       r'"(?P<url>\S+)"\s+.*\s+verify_py(?P<verify_py_suffix>\d+)\s+.*$',
                       line):
            existing_url_path = urllib.parse.urlparse(m.group('url')).path
            try:
                matched_download = more_itertools.one(
                    item for item in VersionDirectory.available[version].downloads
                    if existing_url_path.endswith(item.extension))
            except ValueError:
                logger.error(f'Cannot match existing URL path\'s {existing_url_path} extension '
                             f'to available downloads {VersionDirectory.available[version].downloads}')
                return
            new_package_name, new_package_url = matched_download.package_name, matched_download.url
            new_package_hash = Url.sha256_url(new_package_url, VersionDirectory.session)

            verify_py_suffix = str(version.major)+str(version.minor)

            line = Re.sub_groups(m,
                                 package=new_package_name,
                                 url=new_package_url+'#'+new_package_hash,
                                 verify_py_suffix=verify_py_suffix)

        elif m:=re.match(r'\s*install_package\s+"(?P<package>openssl-\S+)"\s+'
                       r'"(?P<url>\S+)"\s.*$',
                         line):
            item = VersionDirectory.openssl.get_store_latest_release()

            line = Re.sub_groups(m,
                               package=item.package_name,
                               url=item.url + '#' + item.hash)

        elif m:=re.match(r'\s*install_package\s+"(?P<package>readline-\S+)"\s+'
                       r'"(?P<url>\S+)"\s.*$',
                         line):
            item = VersionDirectory.readline.get_store_latest_release()

            line = Re.sub_groups(m,
                                 package=item.package_name,
                                 url=item.url + '#' + item.hash)

        result.write(line)

    result_path = OUT_DIR.joinpath(str(version))
    logger.info(f"Writing {result_path}")
    result_path.write_text(result.getvalue(), encoding='utf-8')
    result.close()

    return result_path

def add_version(version: packaging.version.Version):

    previous_version = VersionDirectory.existing.pick_previous_version(version).version

    is_prerelease_upgrade = previous_version.major==version.major\
            and previous_version.minor==version.minor\
            and previous_version.micro==version.micro

    logger.info(f"Adding {version} based on {previous_version}"
                + (" (prerelease upgrade)" if is_prerelease_upgrade else ""))

    VersionDirectory.available.get_store_available_source_downloads(version)

    new_path = adapt_script(version,
                 previous_version)
    if not new_path:
        return False
    VersionDirectory.existing.append(_CPythonExistingScriptInfo(version,str(new_path)))

    cleanup_prerelease_upgrade(is_prerelease_upgrade, previous_version)

    handle_t_thunks(version, previous_version, is_prerelease_upgrade)

    print(version)
    return True


def cleanup_prerelease_upgrade(
        is_prerelease_upgrade: bool,
        previous_version: packaging.version.Version)\
        -> None:
    if is_prerelease_upgrade:
        previous_version_path = OUT_DIR / str(previous_version)
        logger.info(f'Deleting {previous_version_path}')
        previous_version_path.unlink()
        del VersionDirectory.existing[previous_version]


def handle_t_thunks(version, previous_version, is_prerelease_upgrade):
    if (version.major, version.minor) >= (3, 13):
        # an old thunk may have older version-specific code
        # so it's safer to write a known version-independent template
        thunk_path = OUT_DIR.joinpath(str(version) + "t")
        logger.info(f"Writing {thunk_path}")
        thunk_path.write_text(T_THUNK, encoding='utf-8')
        if is_prerelease_upgrade:
            previous_thunk_path = OUT_DIR.joinpath(str(previous_version) + "t")
            logger.info(f"Deleting {previous_thunk_path}")
            previous_thunk_path.unlink()

Arguments: argparse.Namespace

def main():
    global Arguments
    Arguments = parse_args()
    logging.basicConfig(level=logging.DEBUG if Arguments.verbose else logging.INFO)

    cached_session=requests_html.HTMLSession()
    global VersionDirectory
    VersionDirectory = _VersionDirectory(cached_session)

    VersionDirectory.existing.populate()
    VersionDirectory.available.populate()

    for initial_release in (v for v in frozenset(VersionDirectory.available.keys())
                            if v.micro == 0 and v not in VersionDirectory.existing):
        # may actually be a prerelease
        VersionDirectory.available.get_store_available_source_downloads(initial_release, True)
        del initial_release

    versions_to_add = sorted(VersionDirectory.available.keys() - VersionDirectory.existing.keys())

    logger.info("Versions to add:\n"+pprint.pformat(versions_to_add))
    result = False
    for version_to_add in versions_to_add:
        result = add_version(version_to_add) or result
    return int(not result)

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


T = typing.TypeVar('T', bound=object)

K = typing.TypeVar('K', bound=typing.Hashable)

class KeyedList(typing.List[T], typing.Mapping[K, T]):
    key_field: str
    item_init: typing.Callable[..., T] = None

    def __init__(self, seq: typing.Union[typing.Iterable[T], None] = None):
        super().__init__()
        self._map = {}
        if seq is not None:
            self.__iadd__(seq)

    # read

    def __getitem__(self, key: K) -> T:
        return self._map[key]

    def __contains__(self, key: K):
        return key in self._map

    def keys(self) -> typing.AbstractSet[K]:
        return self._map.keys()

    # write

    def append(self, item: T) -> None:
        key = self._getkey(item)
        if key in self:
            raise ValueError(f"Key '{key:r}' already present")
        super().append(item)
        self._map[key] = item

    def __iadd__(self, other: typing.Iterable[T]):
        for item in other:
            self.append(item)
        return self

    def __delitem__(self, key: K):
        super().remove(self[key])
        del self._map[key]

    def clear(self):
        super().__delitem__(slice(None,None))
        self._map.clear()

    # read-write

    def get_or_create(self, key: K, **kwargs):
        try:
            return self[key]
        except KeyError as e:
            if self.item_init is None:
                raise AttributeError("'item_init' must be set to use automatic item creation") from e
            kwargs[self.key_field] = key
            item = self.item_init(**kwargs)
            self.append(item)
            return item

    # info

    def __repr__(self):
        return self.__class__.__name__ + "([" + ", ".join(repr(i) for i in self) + "])"

    # private

    def _getkey(self, item: T) -> K:
        return getattr(item, self.key_field)

del T, K

@dataclasses.dataclass(frozen=True)
class _CPythonAvailableVersionDownloadInfo:
    extension: str
    package_name: str
    url: str

class _CPythonAvailableVersionDownloadsDirectory(KeyedList[_CPythonAvailableVersionDownloadInfo, str]):
    key_field = "extension"


@dataclasses.dataclass(frozen=True)
class _CPythonAvailableVersionInfo:
    version: packaging.version.Version
    download_page_url: str
    downloads: _CPythonAvailableVersionDownloadsDirectory = dataclasses.field(
        default_factory=lambda:_CPythonAvailableVersionDownloadsDirectory()
    )


class CPythonAvailableVersionsDirectory(KeyedList[_CPythonAvailableVersionInfo, packaging.version.Version]):
    key_field = "version"
    _session: requests.Session
    item_init = _CPythonAvailableVersionInfo

    def __init__(self, session: requests.Session, seq=None):
        super().__init__(seq)
        self._session = session

    def populate(self):
        """
        Fetch remote versions
        """
        logger.info("Fetching available CPython versions")
        for name, url in DownloadPage.enum_download_entries(
                "https://www.python.org/ftp/python/",
                r'^(\d+.*)/$', self._session,
                make_name= lambda m: m.group(1)
        ):
            v = packaging.version.Version(name)
            if v < CUTOFF_VERSION or v in EXCLUDED_VERSIONS:
                continue
            logger.debug(f'Available version: {name} ({v}), {url}')
            self.append(_CPythonAvailableVersionInfo(
                v,
                url
            ))

    def get_store_available_source_downloads(self, version, refine_mode=False):
        entry = self[version]
        if entry.downloads:
            #already retrieved
            return
        additional_versions_found =\
            CPythonAvailableVersionsDirectory(self._session) if refine_mode else None
        exact_download_found = False
        for name, url in DownloadPage.enum_download_entries(
                entry.download_page_url,
                r'Python-.*\.(tar\.xz|tgz)$',
                self._session):
            m = re.match(r'(?P<package>Python-(?P<version>.*))\.(?P<extension>tar\.xz|tgz)$', name)

            download_version = packaging.version.Version(m.group("version"))
            if download_version != version:
                if not refine_mode:
                    raise ValueError(f"Unexpectedly found a download {name} for {download_version} "
                                     f"at page {entry.download_page_url} for {version}")
                entry_to_fill = additional_versions_found.get_or_create(
                    download_version,
                    download_page_url=entry.download_page_url
                )
            else:
                exact_download_found = True
                entry_to_fill = entry

            entry_to_fill.downloads.append(_CPythonAvailableVersionDownloadInfo(
                m.group("extension"), m.group('package'), url
            ))

        if not exact_download_found:
            actual_version = max(additional_versions_found.keys())
            logger.debug(f"Refining available version {version} to {actual_version}")
            del self[version]

            self.append(
                additional_versions_found[
                    actual_version
                ])


class _CPythonExistingScriptInfo(typing.NamedTuple):
    version: packaging.version.Version
    filename: str

class CPythonExistingScriptsDirectory(KeyedList[_CPythonExistingScriptInfo, packaging.version.Version]):
    key_field = "version"
    _filename_pattern = r'^\d+\.\d+(?:(t?)(-\w+)|(.\d+((?:a|b|rc)\d)?(t?)))$'

    def populate(self):
        """
        Enumerate existing installation scripts in share/python-build/ by pattern
        """
        logger.info(f"Enumerating existing versions in {OUT_DIR}")
        for entry_name in (p.name for p in OUT_DIR.iterdir() if p.is_file()):
            if (not (m := re.match(self._filename_pattern, entry_name))
                    or m.group(1) == 't' or m.group(5) == 't'):
                continue
            try:
                v = packaging.version.Version(entry_name)
                if v < CUTOFF_VERSION:
                    continue
                # branch tip scrpts are different from release scripts and thus unusable as a pattern
                if v.dev is not None:
                    continue
                logger.debug(f"Existing version {v}")

                self.append(_CPythonExistingScriptInfo(v, entry_name))

            except ValueError as e:
                logger.error(f"Unable to parse existing version {entry_name}: {e}")

    def pick_previous_version(self,
                              version: packaging.version.Version) \
            -> _CPythonExistingScriptInfo:
        return max(v for v in self if v.version < version)


class _OpenSSLVersionInfo(typing.NamedTuple):
    version: packaging.version.Version
    package_name: str
    url: str
    hash: str

class OpenSSLVersionsDirectory(KeyedList[_OpenSSLVersionInfo, packaging.version.Version]):
    key_field = "version"

    def get_store_latest_release(self) \
            -> _OpenSSLVersionInfo:
        if self:
            #already retrieved
            return self[max(self.keys())]

        j = requests.get("https://api.github.com/repos/openssl/openssl/releases/latest").json()
        # noinspection PyTypeChecker
        # urlparse can parse str as well as bytes
        shasum_url = more_itertools.one(
            asset['browser_download_url']
            for asset in j['assets']
            if urllib.parse.urlparse(asset['browser_download_url']).path.split('/')[-1].endswith('.sha256')
        )
        shasum_text = requests.get(shasum_url).text
        shasum_data = jc.parse("hashsum", shasum_text, quiet=True)[0]
        package_hash, package_filename = shasum_data["hash"], shasum_data["filename"]
        del shasum_data, shasum_text, shasum_url

        # OpenSSL Github repo has tag names "openssl-<version>" as of this writing like we need
        # but let's not rely on that
        # splitext doesn't work with a chained extension, it only splits off the last one
        package_name, package_version_str = re.match(r"([^-]+-(.*?))\.\D", package_filename).groups()
        package_version = packaging.version.Version(package_version_str)

        package_url = more_itertools.one(
            asset['browser_download_url']
            for asset in j['assets']
            if urllib.parse.urlparse(asset['browser_download_url']).path.split('/')[-1] == package_filename
        )

        result = _OpenSSLVersionInfo(package_version, package_name, package_url, package_hash)
        self.append(result)

        return result


class _ReadlineVersionInfo(typing.NamedTuple):
    version : packaging.version.Version
    package_name : str
    url : str
    hash : str

class ReadlineVersionsDirectory(KeyedList[_ReadlineVersionInfo, packaging.version.Version]):
    key_field = "version"

    def get_store_latest_release(self):
        if not self:
            self._store_latest_release()
        return self._latest_release()

    def _store_latest_release(self):
        candidates = ReadlineVersionsDirectory()

        pattern = r'(?P<package_name>readline-(?P<version>\d+(?:\.\d+)+)).tar\.gz$'
        for name, url in DownloadPage.enum_download_entries(
                'https://ftpmirror.gnu.org/readline/', pattern, VersionDirectory.session):
            m = re.match(pattern, name)
            version = packaging.version.Version(m.group('version'))
            candidates.append(_ReadlineVersionInfo(
                version,
                m.group('package_name'),
                url,
                ""
            ))
        max_item = candidates._latest_release()
        hash_ = Url.sha256_url(max_item.url, VersionDirectory.session)

        result = _ReadlineVersionInfo(
            max_item.version,
            max_item.package_name,
            max_item.url,
            hash_)
        self.append(result)

        return result

    def _latest_release(self):
        return self[max(self.keys())]

class _VersionDirectory:
    def __init__(self, session):
        self.existing = CPythonExistingScriptsDirectory()
        self.available = CPythonAvailableVersionsDirectory(session)
        self.openssl = OpenSSLVersionsDirectory()
        self.readline = ReadlineVersionsDirectory()
        self.session = session
VersionDirectory : _VersionDirectory

class DownloadPage:
    class _DownloadPageEntry(typing.NamedTuple):
        name: str
        url: str

    @classmethod
    def enum_download_entries(cls, url, pattern, session=None,
                              make_name = lambda m: m.string ) \
            -> typing.Generator[_DownloadPageEntry, None, None]:
        """
        Enum download entries in a standard Apache directory page
        (incl. CPython download page https://www.python.org/ftp/python/)
        or a GNU mirror directory page
        (https://ftpmirror.gnu.org/<package>/ destinations)
        """
        if session is None:
            session = requests_html.HTMLSession()
        response = session.get(url)
        page = response.html
        table = page.find("pre", first=True)
        # some GNU mirrors format entries as a table
        # (e.g. https://mirrors.ibiblio.org/gnu/readline/)
        if table is None:
            table = page.find("table", first=True)
        links = table.find("a")
        for link in links:
            href = link.attrs['href']
            # CPython entries are directories
            name = link.text
            # skip directory entries
            if not (m:=re.match(pattern, name)):
                continue
            name = make_name(m)
            yield cls._DownloadPageEntry(name, urllib.parse.urljoin(response.url, href))


class Re:
    @dataclasses.dataclass
    class _interval:
        group: typing.Union[int, str, None]
        start: int
        end: int
    @staticmethod
    def sub_groups(match: re.Match,
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
    sys.exit(main())
