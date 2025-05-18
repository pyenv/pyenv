#!/usr/bin/env python3
'Adds the latest miniforge and mambaforge releases.'
from pathlib import Path
import logging
import os
import string

import requests

logger = logging.getLogger(__name__)
logging.basicConfig(level=os.environ.get('LOGLEVEL', 'INFO'))

MINIFORGE_REPO = 'conda-forge/miniforge'
DISTRIBUTIONS = ['miniforge', 'mambaforge']

SKIPPED_RELEASES = [
    '4.13.0-0',     #has no Mambaforge. We already generated scripts for Miniforge
    '22.11.1-0',    #MacOS packages are broken (have broken dep tarballs, downloading them fails with 403)
    '22.11.1-1',    #MacOS packages are broken (have broken dep tarballs, downloading them fails with 403)
    '22.11.1-2',    #MacOS packages are broken (have broken dep tarballs, downloading them fails with 403)
]

install_script_fmt = """
case "$(anaconda_architecture 2>/dev/null || true)" in
{install_lines}
* )
  {{ echo
    colorize 1 "ERROR"
    echo ": The binary distribution of {flavor} is not available for $(anaconda_architecture 2>/dev/null || true)."
    echo
  }} >&2
  exit 1
  ;;
esac
""".lstrip()

install_line_fmt = """
"{os}-{arch}" )
  install_script "{filename}" "{url}#{sha}" "miniconda" verify_py{py_version}
  ;;
""".strip()

here = Path(__file__).resolve()
out_dir: Path = here.parent.parent / "share" / "python-build"

def download_sha(url):
    logger.info('Downloading SHA file %(url)s', locals())
    tup = tuple(reversed(requests.get(url).text.replace('./', '').rstrip().split()))
    logger.debug('Got %(tup)s', locals())
    return tup

def create_spec(filename, sha, url):
    flavor_with_suffix, version, subversion, os, arch = filename.replace('.sh', '').split('-')
    suffix = flavor_with_suffix[-1]

    if suffix in string.digits:
        flavor = flavor_with_suffix[:-1]
    else:
        flavor = flavor_with_suffix

    spec = {
        'filename': filename,
        'sha': sha,
        'url': url,
        'py_version': py_version(version),
        'flavor': flavor,
        'os': os,
        'arch': arch,
        'installer_filename': f'{flavor_with_suffix.lower()}-{version}-{subversion}',
    }

    logger.debug('Created spec %(spec)s', locals())

    return spec

def py_version(release):
    """Suffix for `verify_pyXXX` to call in the generated build script"""
    release_line = tuple(int(part) for part in release.split(".")[:2])
    # current version: mentioned under https://github.com/conda-forge/miniforge?tab=readme-ov-file#miniforge3
    # transition points:
    # https://github.com/conda-forge/miniforge/blame/main/Miniforge3/construct.yaml
    # look for "- python <version>" in non-pypy branch and which tag the commit is first in
    if release_line >= (24,5):
        # yes, they jumped from 3.10 directly to 3.12
        # https://github.com/conda-forge/miniforge/commit/bddad0baf22b37cfe079e47fd1680fdfb2183590
        return "312"
    if release_line >= (4,14):
        return "310"
    raise ValueError("Bundled Python version unknown for release `%s'"%release)

def supported(filename):
    return ('pypy' not in filename) and ('Windows' not in filename)

def add_version(release):
    tag_name = release['tag_name']
    download_urls = { f['name']: f['browser_download_url'] for f in release['assets'] }
    # can assume that sha files are named similar to release files so can also check supported(on their names)
    shas = dict([download_sha(url) for (name, url) in download_urls.items() if name.endswith('.sha256') and supported(os.path.basename(name)) and tag_name in name])
    specs = [create_spec(filename, sha, download_urls[filename]) for (filename, sha) in shas.items() if supported(filename)]

    for distribution in DISTRIBUTIONS:
        distribution_specs = [spec for spec in specs if distribution in spec['flavor'].lower()]
        count = len(distribution_specs)

        if count > 0:
            output_file = out_dir / distribution_specs[0]['installer_filename']

            logger.info('Writing %(count)d specs for %(distribution)s to %(output_file)s', locals())

            script_str = install_script_fmt.format(
                install_lines="\n".join([install_line_fmt.format_map(s) for s in distribution_specs]),
                flavor=distribution_specs[0]['flavor'],
            )

            with open(output_file, 'w') as f:
                f.write(script_str)
        else:
            logger.info('Did not find specs for %(distribution)s', locals())

for release in requests.get(f'https://api.github.com/repos/{MINIFORGE_REPO}/releases').json():
    version = release['tag_name']

    logger.info('Looking for %(version)s in %(out_dir)s', locals())

    # This release has no mambaforge artifacts which causes the next check to always trigger.
    # Build scripts for miniforge3-4.13.0-0 have already been generated.
    # Assuming this was a fluke, we don't yet need to implement proactively checking all releases for contents
    # or ignoring a release if _any_ of the flavors is already present in Pyenv.
    if version in SKIPPED_RELEASES:
        continue

    if any(not list(out_dir.glob(f'{distribution}*-{version}')) for distribution in DISTRIBUTIONS):
        logger.info('Downloading %(version)s', locals())
        add_version(release)
