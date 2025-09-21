# TEST

---

## Running test suite

Test suite could be launch with `make` by providing the right target depending what you want to achieve.

Under the hood, `pyenv` test suites use `bats` as a test framework and are run on the host or docker depending of the target provided to make.



### Targets

- `test`
  - Run the whole test suite on the local host
- `test-docker`
  - Run the whole test suite on docker
    - Some volumes are used in read-only mode
- `test-unit`
  - Run the unit test
- `test-plugin`
  - Run the plugin test
- `test-unit-docker-[BASH_VERSION]`
  - Run the unit test under **official** bash docker container (alpine/busybox) with the specified bash version if present is in the `Makefile`
  - Some volumes are used in read-only mode
- `test-unit-docker-gnu-[BASH_VERSION]`
  - Run the unit test under **official** bash docker container (alpine/busybox), completed by **GNU Tools**, with the specified bash version if present is in the `Makefile`
  - Some volumes are used in read-only mode
- `test-plugin-docker-[BASH_VERSION]`
  - Run the plugin test under **official** bash docker container (alpine/busybox), completed by **GNU Tools**, with the specified bash version if present is in the `Makefile`
  - Some volumes are used in read-only mode
- `test-plugin-docker-gnu-[BASH_VERSION]`
  - Run the plugin test under **official** bash docker container (alpine/busybox), completed by **GNU Tools**, with the specified bash version if present is in the `Makefile`
  - Some volumes are used in read-only mode

## Targeting specific test / test file

 By setting some environment variables, it is possible to filtering which test and/or test file who will be tested with bats

- `BATS_FILE_FILTER`

  - Run test only with the specified file

- `BATS_TEST_FILTER`
  - Run test only who corresponding to the filter provided


### Examples

```bash
    $ BATS_TEST_FILTER=".*installed.*" BATS_FILE_FILTER="build.bats" make test-plugin-docker-gnu-3.2.57
    build.bats
     ✓ yaml is installed for python
     ✓ homebrew is used in Linux if Pyenv is installed with Homebrew
     ✓ homebrew is not used in Linux if Pyenv is not installed with Homebrew
    
    3 tests, 0 failures
    
    $ BATS_TEST_FILTER=".*installed.*" BATS_FILE_FILTER="build.bats" make test-plugin
    build.bats
     ✓ yaml is installed for python
     ✓ homebrew is used in Linux if Pyenv is installed with Homebrew
     ✓ homebrew is not used in Linux if Pyenv is not installed with Homebrew
    
    3 tests, 0 failures
```



## Writing test

To be reproducible, each test use/should use its own `TMPDIR` .  
It's achieved by using the environment variable `BATS_TEST_TMPDIR` provided by bats that is automatically deleted at the end of each test. More info [here](https://bats-core.readthedocs.io/en/stable/writing-tests.html#special-variables)

Another variable who could be used to source some file who need to be tested is `BATS_TEST_DIRNAME` who point to the directory in which the bats test file is located.