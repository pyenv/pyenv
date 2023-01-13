Too many issues will kill our team's development velocity, drastically.
Make sure you have checked all steps below.

### Prerequisite
* [ ] Make sure your problem is not listed in [the common build problems](https://github.com/pyenv/pyenv/wiki/Common-build-problems).
* [ ] Make sure no duplicated issue has already been reported in [the pyenv issues](https://github.com/pyenv/pyenv/issues). You should look for closed issues, too.
* [ ] Make sure you are not asking us to help solving your specific issue.
  * GitHub issues is opened mainly for development purposes. If you want to ask someone to help solving your problem, go to some community site like [Gitter](https://gitter.im/yyuu/pyenv), [StackOverflow](https://stackoverflow.com/questions/tagged/pyenv), etc.
* [ ] Make sure your problem is not derived from packaging (e.g. [Homebrew](https://brew.sh)).
  * Please refer to the package documentation for the installation issues, etc.
* [ ] Make sure your problem is not derived from plugins.
  * This repository is maintaining `pyenv` and the default `python-build` plugin only. Please refrain from reporting issues of other plugins here.

### Description
- [ ] Platform information (e.g. Ubuntu Linux 16.04):
- [ ] OS architecture (e.g. amd64):
- [ ] pyenv version:
- [ ] Python version:
- [ ] C Compiler information (e.g. gcc 7.3): 
- [ ] Please attach the debug trace of the failing command as a gist:
  * Run `env PYENV_DEBUG=1 <faulty command> 2>&1 | tee trace.log` and attach `trace.log`. E.g. if you have a problem with installing Python, run `env PYENV_DEBUG=1 pyenv install -v <version> 2>&1 | tee trace.log` (note the `-v` option to `pyenv install`).
- [ ] If you have a problem with installing Python, please also attach `config.log` from the build directory
  * The build directory is reported after the "BUILD FAILED" message and is usually under `/tmp`.
- [ ] If the build succeeds but the problem is still with the build process (e.g. the resulting Python is missing a feature), please attach
  * the debug trace from reinstalling the faulty version with `env PYENV_DEBUG=1 pyenv install -f -k -v <version> 2>&1 | tee trace.log`
  * `config.log` from the build directory. When using `pyenv install` with `-k` as per above, the build directory will be under `$PYENV_ROOT/sources`.
