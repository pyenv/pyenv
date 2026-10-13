# TEST

---

## Running test suite

Test suite could be launch with `make` by providing the right target depending what you want to achieve.

Under the hood, `pyenv` test suites use `bats` as a test framework and are run on the host or docker depending of the target provided to make.



### Targets

- `test`
  - Run the whole test suite on the local host
- `test-docker`
  - Run the whole test suite in Docker (in all environments)
- `test-unit`
  - Run core tests
- `test-python-build`
  - Run Python-Build tests
- `test-binary`
  - Run Pyenv-Binary tests
- `test-*-docker`
  - Run the corresponding test suite in Docker
- `test-*-docker-[BASH_VERSION]`, `test-*-docker-gnu-[BASH_VERSION]`
  - Run the corresponding test suite in the official Bash Docker container (alpine/busybox)
    against either Busybox tools or GNU tools, with the specified Bash version
    among those listed in the `Makefile`

## Targeting specific test / test file

 By setting some environment variables, it is possible to filter which test and/or test file will be run

- `BATS_FILE_FILTER`
  - Run tests from the specified file
- `BATS_TEST_FILTER`
  - Run tests with the names corresponding to the filter
