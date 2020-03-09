# Scripts for updating python-build

Install dependencies with `pip install -r requirements.txt`.

## add_miniconda.py

```_add_miniconda
usage: add_miniconda.py [-h] [-d] [-v]

Script to add non-"latest" miniconda releases. Written for python 3.7. Checks
the miniconda download archives for new versions, then writes a build script
for any which do not exist locally, saving it to plugins/python-
build/share/python-build. Ignores releases below 4.3.30. Also ignores sub-
patch releases if that major.minor.patch already exists, but otherwise, takes
the latest sub-patch release for given OS/arch. Assumes all miniconda3
releases < 4.7 default to python 3.6, and anything else 3.7.

optional arguments:
  -h, --help     show this help message and exit
  -d, --dry-run  Do not write scripts, just report them to stdout
  -v, --verbose  Increase verbosity of logging
```
