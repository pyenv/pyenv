TEST_BATS_VERSION = v1.10.0
TEST_BASH_VERSIONS = 3.2.57 4.1.17

TEST_UNIT_DOCKER_PREFIX = test-unit-docker
TEST_UNIT_DOCKER_TARGETS = $(foreach bash,$(TEST_BASH_VERSIONS),$(addsuffix -$(bash),$(TEST_UNIT_DOCKER_PREFIX)) $(addsuffix -gnu-$(bash),$(TEST_UNIT_DOCKER_PREFIX)))

TEST_PYTHON_BUILD_DOCKER_PREFIX = test-python-build-docker
TEST_PYTHON_BUILD_DOCKER_TARGETS = $(foreach bash,$(TEST_BASH_VERSIONS),$(addsuffix -$(bash),$(TEST_PYTHON_BUILD_DOCKER_PREFIX)) $(addsuffix -gnu-$(bash),$(TEST_PYTHON_BUILD_DOCKER_PREFIX)))

TEST_BINARY_DOCKER_PREFIX = test-binary-docker
TEST_BINARY_DOCKER_TARGETS = $(foreach bash,$(TEST_BASH_VERSIONS),$(addsuffix -$(bash),$(TEST_BINARY_DOCKER_PREFIX)) $(addsuffix -gnu-$(bash),$(TEST_BINARY_DOCKER_PREFIX)))

TEST_BATS_IMAGE_PREFIX = test-pyenv-docker-image
TEST_BATS_IMAGE_TARGETS = $(foreach bash,$(TEST_BASH_VERSIONS),$(addsuffix -$(bash),$(TEST_BATS_IMAGE_PREFIX)) $(addsuffix -gnu-$(bash),$(TEST_BATS_IMAGE_PREFIX)))

.PHONY: test-docker
test-docker: $(TEST_UNIT_DOCKER_PREFIX) $(TEST_PYTHON_BUILD_DOCKER_PREFIX) $(TEST_BINARY_DOCKER_PREFIX)

.PHONY: $(TEST_UNIT_DOCKER_PREFIX)
$(TEST_UNIT_DOCKER_PREFIX): $(TEST_UNIT_DOCKER_TARGETS)

# Run each unit test under bats docker
.PHONY: $(TEST_UNIT_DOCKER_TARGETS)
$(TEST_UNIT_DOCKER_TARGETS): DOCKER_IMAGE = $(TEST_BATS_IMAGE_PREFIX)
$(TEST_UNIT_DOCKER_TARGETS): GNU = $(if $(findstring -gnu-,$@),True,False)
$(TEST_UNIT_DOCKER_TARGETS): BASH = $(filter $(TEST_BASH_VERSIONS),$(subst -, ,$@))
$(TEST_UNIT_DOCKER_TARGETS): DOCKER_TAG = bash-$(BASH)-gnu-$(GNU)
$(TEST_UNIT_DOCKER_TARGETS): INTERACTIVE = $(if $(findstring true,$(CI)),,-ti)
$(TEST_UNIT_DOCKER_TARGETS): $(TEST_UNIT_DOCKER_PREFIX)-% : $(TEST_BATS_IMAGE_PREFIX)-%
	$(info Running test with docker image '$(DOCKER_IMAGE):$(DOCKER_TAG)')
	docker run \
		--init \
		-v $(PWD):/code:ro \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/group:/etc/group:ro \
		-u "$$(id -u $$(whoami)):$$(id -g $$(whoami))" \
		$${BATS_TEST_FILTER:+-e BATS_TEST_FILTER="$${BATS_TEST_FILTER}"} \
		$${BATS_FILE_FILTER:+-e BATS_FILE_FILTER="$${BATS_FILE_FILTER}"} \
		$${CI+-e CI="$${CI}"} \
		$(INTERACTIVE) \
		$(DOCKER_IMAGE):$(DOCKER_TAG) \
		test/run

.PHONY: $(TEST_PYTHON_BUILD_DOCKER_PREFIX)
$(TEST_PYTHON_BUILD_DOCKER_PREFIX): $(TEST_PYTHON_BUILD_DOCKER_TARGETS)

# Run each plugin test under bats docker
.PHONY: $(TEST_PYTHON_BUILD_DOCKER_TARGETS)
$(TEST_PYTHON_BUILD_DOCKER_TARGETS): DOCKER_IMAGE = $(TEST_BATS_IMAGE_PREFIX)
$(TEST_PYTHON_BUILD_DOCKER_TARGETS): GNU = $(if $(findstring -gnu-,$@),True,False)
$(TEST_PYTHON_BUILD_DOCKER_TARGETS): BASH = $(filter $(TEST_BASH_VERSIONS),$(subst -, ,$@))
$(TEST_PYTHON_BUILD_DOCKER_TARGETS): DOCKER_TAG = bash-$(BASH)-gnu-$(GNU)
$(TEST_PYTHON_BUILD_DOCKER_TARGETS): INTERACTIVE = $(if $(findstring true,$(CI)),,-ti)
$(TEST_PYTHON_BUILD_DOCKER_TARGETS): $(TEST_PYTHON_BUILD_DOCKER_PREFIX)-% : $(TEST_BATS_IMAGE_PREFIX)-%
	$(info Running test with docker image '$(DOCKER_IMAGE):$(DOCKER_TAG)')
	docker run \
		--init \
		-v $(PWD):/code:ro \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/group:/etc/group:ro \
		-u "$$(id -u $$(whoami)):$$(id -g $$(whoami))" \
		$${CI+-e CI="$${CI}"} \
		$(INTERACTIVE) \
		$(DOCKER_IMAGE):$(DOCKER_TAG) \
		bats $${BATS_TEST_FILTER:+--filter "$${BATS_TEST_FILTER}"} plugins/python-build/test/$${BATS_FILE_FILTER}

.PHONY: $(TEST_BINARY_DOCKER_PREFIX)
$(TEST_BINARY_DOCKER_PREFIX): $(TEST_BINARY_DOCKER_TARGETS)

.PHONY: $(TEST_BINARY_DOCKER_TARGETS)
$(TEST_BINARY_DOCKER_TARGETS): DOCKER_IMAGE = $(TEST_BATS_IMAGE_PREFIX)
$(TEST_BINARY_DOCKER_TARGETS): GNU = $(if $(findstring -gnu-,$@),True,False)
$(TEST_BINARY_DOCKER_TARGETS): BASH = $(filter $(TEST_BASH_VERSIONS),$(subst -, ,$@))
$(TEST_BINARY_DOCKER_TARGETS): DOCKER_TAG = bash-$(BASH)-gnu-$(GNU)
$(TEST_BINARY_DOCKER_TARGETS): INTERACTIVE = $(if $(findstring true,$(CI)),,-ti)
$(TEST_BINARY_DOCKER_TARGETS): $(TEST_BINARY_DOCKER_PREFIX)-% : $(TEST_BATS_IMAGE_PREFIX)-%
	$(info Running test with docker image '$(DOCKER_IMAGE):$(DOCKER_TAG)')
	docker run \
		--init \
		-v $(PWD):/code:ro \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/group:/etc/group:ro \
		-u "$$(id -u $$(whoami)):$$(id -g $$(whoami))" \
		$${CI+-e CI="$${CI}"} \
		$(INTERACTIVE) \
		$(DOCKER_IMAGE):$(DOCKER_TAG) \
		bats $${BATS_TEST_FILTER:+--filter "$${BATS_TEST_FILTER}"} plugins/pyenv-binary/test/$${BATS_FILE_FILTER}

# Build all images needed for bats under docker
.PHONY: $(TEST_BATS_IMAGE_PREFIX)
$(TEST_BATS_IMAGE_PREFIX): $(TEST_BATS_IMAGE_TARGETS)

# Build each image needed for bats under docker
.PHONY: $(TEST_BATS_IMAGE_TARGETS)
$(TEST_BATS_IMAGE_TARGETS): DOCKER_IMAGE = $(TEST_BATS_IMAGE_PREFIX)
$(TEST_BATS_IMAGE_TARGETS): GNU = $(if $(findstring -gnu-,$@),True,False)
$(TEST_BATS_IMAGE_TARGETS): BASH = $(filter $(TEST_BASH_VERSIONS),$(subst -, ,$@))
$(TEST_BATS_IMAGE_TARGETS): DOCKER_TAG = bash-$(BASH)-gnu-$(GNU)
$(TEST_BATS_IMAGE_TARGETS):
	if [ -z "$$(docker images -q '$(DOCKER_IMAGE):$(DOCKER_TAG)')" ]]; then \
	docker build \
		--quiet \
		-f "$(PWD)/test/Dockerfile" \
		--build-arg GNU="$(GNU)" \
		--build-arg BASH="$(BASH)" \
		--build-arg BATS_VERSION="$(TEST_BATS_VERSION)" \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) \
		./ ; \
	fi

.PHONY: test test-unit test-python-build test-binary

# Do not pass in user flags to build tests.
unexport PYTHON_CFLAGS
unexport PYTHON_CONFIGURE_OPTS

test: test-unit test-python-build test-binary

test-unit: bats
	PATH="./bats/bin:$$PATH" test/run
	
test-python-build: bats
	cd plugins/python-build && $(PWD)/bats/bin/bats $${CI:+--tap} $${BATS_TEST_FILTER:+--filter "$${BATS_TEST_FILTER}"} test/$${BATS_FILE_FILTER}

test-binary: bats
	cd plugins/pyenv-binary && $(PWD)/bats/bin/bats $${CI:+--tap} $${BATS_TEST_FILTER:+--filter "$${BATS_TEST_FILTER}"} test/$${BATS_FILE_FILTER}

.SECONDARY: bats-$(TEST_BATS_VERSION)
bats-$(TEST_BATS_VERSION):
	git clone --depth 1 --branch $(TEST_BATS_VERSION) https://github.com/bats-core/bats-core.git bats-$(TEST_BATS_VERSION)

.PHONY: bats
bats: bats-$(TEST_BATS_VERSION)
	if [ \( ! -L bats \) -o \( "x$$(readlink bats)" != "xbats-$(TEST_BATS_VERSION)" \) ]; then \
		rm -rf bats; ln -s bats-$(TEST_BATS_VERSION) bats; \
	fi
