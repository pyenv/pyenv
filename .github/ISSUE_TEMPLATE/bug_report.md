---
name: Bug report
about: Create a report to help us improve
title: ''
labels: ''
assignees: ''

---

### Prerequisites
* [ ] Make sure your problem is not listed in [the common build problems](https://github.com/pyenv/pyenv/wiki/Common-build-problems).
* [ ] Make sure no duplicated issue has already been reported in [the pyenv issues](https://github.com/pyenv/pyenv/issues?q=is%3Aissue). For build errors, a reported issue typically mentions a key error message. This key error message is often not in the 10 last build log lines reported to the console but is rather earlier in the build log -- typically, it's the first error message encountered in the log.
* [ ] Make sure you are reporting a problem in Pyenv and not seeking consultation with Pyenv usage.
  * GitHub issues are intended mainly for Pyenv development purposes. If you are seeking help with Pyenv usage, check [Pyenv documentation](https://github.com/pyenv/pyenv?tab=readme-ov-file#simple-python-version-management-pyenv), go to a user community site like [Gitter](https://gitter.im/yyuu/pyenv), [StackOverflow](https://stackoverflow.com/questions/tagged/pyenv), etc, or to [Discussions](https://github.com/orgs/pyenv/discussions).
* [ ] Make sure your problem is not derived from packaging (e.g. [Homebrew](https://brew.sh)).
  * Please refer to the package documentation for the installation issues, etc.
* [ ] Make sure your problem is not derived from plugins.
  * This repository is maintaining `pyenv` and the default `python-build` plugin only. Please refrain from reporting issues of other plugins here.

### Describe the bug
A clear and concise description of what the bug is.
Do specify what the expected behaviour is if that's not obvious from the bug's nature.

#### Reproduction steps
Listing the commands to run in a new console session and their output is usually sufficient.
Please use a Markdown code block (three backticks on a line by themselves before and after the text) to denote a console output excerpt.
Usually not needed for build errors (since the arguments can already be seen in the debug trace) unless you are using an unusual invocation (e.g. setting environment variables that affect the build).

#### Diagnostic details
- [ ] Platform information (e.g. Ubuntu Linux 24.04):
- [ ] OS architecture (e.g. amd64):
- [ ] pyenv version:
- [ ] Python version:
- [ ] C Compiler information (e.g. gcc 7.3): 
- [ ] Please attach the debug trace of the failing command as a [gist](https://gist.github.com/):
  * Run `env PYENV_DEBUG=1 <faulty command> 2>&1 | tee trace.log` and attach `trace.log`. E.g. if you have a problem with installing Python, run `env PYENV_DEBUG=1 pyenv install -v <version> 2>&1 | tee trace.log` (note the `-v` option to `pyenv install`).
- [ ] If you have a problem with installing Python, please also attach `config.log` from the build directory
  * The build directory is reported after the "BUILD FAILED" message and is usually under `/tmp`.
- [ ] If the build succeeds but the problem is still with the build process (e.g. the resulting Python is missing a feature), please attach
  * the debug trace from reinstalling the faulty version with `env PYENV_DEBUG=1 pyenv install -f -k -v <version> 2>&1 | tee trace.log`
  * `config.log` from the build directory. When using `pyenv install` with `-k` as per above, the build directory will be under `$PYENV_ROOT/sources`.
- [ ] If the problem happens in another Pyenv invocation, turn on debug logging by setting `PYENV_DEBUG=1`, e.g. `env PYENV_DEBUG=1 pyenv local 3.6.4`, and attach the resulting trace as a gist
- [ ] If the problem happens outside of a Pyenv invocation, get the debug trace like this:
     ```
     export PYENV_DEBUG=1
     # for Bash
     export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
     # for Zsh
     export PS4='+(%x:%I): %N(%i): '

     set -x
     <reproduce the problem>
     set +x
     ```
