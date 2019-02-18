.PHONY: test test-build

# Do not pass in user flags to build tests.
unexport PYTHON_CFLAGS
unexport PYTHON_CONFIGURE_OPTS

test: bats
	PATH="./bats/bin:$$PATH" test/run
	cd plugins/python-build && $(PWD)/bats/bin/bats $${CI:+--tap} test

test-build: bats
	cd plugins/python-build && $(PWD)/bats/bin/bats $${CI:+--tap} test/build

bats:
	git clone --depth 1 https://github.com/bats-core/bats-core.git bats
