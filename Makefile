.PHONY: test

# Do not pass in user flags to build tests.
unexport PYTHON_CFLAGS
unexport PYTHON_CONFIGURE_OPTS

test: bats
	PATH="./bats/bin:$$PATH" test/run
	cd plugins/python-build && $(PWD)/bats/bin/bats $${CI:+--tap} test

bats:
	git clone https://github.com/sstephenson/bats.git
