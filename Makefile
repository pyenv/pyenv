.PHONY: test test-build test-unit test-plugin

# Do not pass in user flags to build tests.
unexport PYTHON_CFLAGS
unexport PYTHON_CONFIGURE_OPTS

test: test-unit test-plugin

test-unit: bats
	PATH="./bats/bin:$$PATH" test/run
	
test-plugin: bats
	cd plugins/python-build && $(PWD)/bats/bin/bats $${CI:+--tap} test

PYTHON_BUILD_ROOT := $(CURDIR)/plugins/python-build
PYTHON_BUILD_OPTS ?= --verbose
PYTHON_BUILD_VERSION ?= 3.8-dev
PYTHON_BUILD_TEST_PREFIX ?= $(PYTHON_BUILD_ROOT)/test/build/tmp/dist

test-build:
	$(RM) -r $(PYTHON_BUILD_TEST_PREFIX)
	$(PYTHON_BUILD_ROOT)/bin/python-build $(PYTHON_BUILD_OPTS) $(PYTHON_BUILD_VERSION) $(PYTHON_BUILD_TEST_PREFIX)
	[ -e $(PYTHON_BUILD_TEST_PREFIX)/bin/python ]
	$(PYTHON_BUILD_TEST_PREFIX)/bin/python -V
	[ -e $(PYTHON_BUILD_TEST_PREFIX)/bin/pip ]
	$(PYTHON_BUILD_TEST_PREFIX)/bin/pip -V

bats:
	git clone --depth 1 --branch v1.2.0 https://github.com/bats-core/bats-core.git bats
