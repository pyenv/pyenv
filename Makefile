TEST_BATS_VERSION = v1.10.0
TEST_BASH_VERSIONS = 3.2.57 4.1.17
TEST_UNIT_DOCKER_PREFIX = test-unit-docker
TEST_UNIT_DOCKER_TARGETS = $(foreach bash,$(TEST_BASH_VERSIONS),$(addsuffix -$(bash),$(TEST_UNIT_DOCKER_PREFIX)) $(addsuffix -gnu-$(bash),$(TEST_UNIT_DOCKER_PREFIX)))
TEST_PLUGIN_DOCKER_PREFIX = test-plugin-docker
TEST_PLUGIN_DOCKER_TARGETS = $(foreach bash,$(TEST_BASH_VERSIONS),$(addsuffix -$(bash),$(TEST_PLUGIN_DOCKER_PREFIX)) $(addsuffix -gnu-$(bash),$(TEST_PLUGIN_DOCKER_PREFIX)))
TEST_BATS_IMAGE_PREFIX = test-pyenv-docker-image
TEST_BATS_IMAGE_TARGETS = $(foreach bash,$(TEST_BASH_VERSIONS),$(addsuffix -$(bash),$(TEST_BATS_IMAGE_PREFIX)) $(addsuffix -gnu-$(bash),$(TEST_BATS_IMAGE_PREFIX)))

.PHONY:
test-docker: $(TEST_UNIT_DOCKER_PREFIX) $(TEST_PLUGIN_DOCKER_PREFIX)

# Run all unit test under bats docker
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

# Run all plugin test under bats docker
.PHONY: $(TEST_PLUGIN_DOCKER_PREFIX)
$(TEST_PLUGIN_DOCKER_PREFIX): $(TEST_PLUGIN_DOCKER_TARGETS)

# Run each plugin test under bats docker
.PHONY: $(TEST_PLUGIN_DOCKER_TARGETS)
$(TEST_PLUGIN_DOCKER_TARGETS): DOCKER_IMAGE = $(TEST_BATS_IMAGE_PREFIX)
$(TEST_PLUGIN_DOCKER_TARGETS): GNU = $(if $(findstring -gnu-,$@),True,False)
$(TEST_PLUGIN_DOCKER_TARGETS): BASH = $(filter $(TEST_BASH_VERSIONS),$(subst -, ,$@))
$(TEST_PLUGIN_DOCKER_TARGETS): DOCKER_TAG = bash-$(BASH)-gnu-$(GNU)
$(TEST_PLUGIN_DOCKER_TARGETS): INTERACTIVE = $(if $(findstring true,$(CI)),,-ti)
$(TEST_PLUGIN_DOCKER_TARGETS): $(TEST_PLUGIN_DOCKER_PREFIX)-% : $(TEST_BATS_IMAGE_PREFIX)-%
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
	$(info Building docker image '$(DOCKER_IMAGE):$(DOCKER_TAG)')
	docker build \
		--quiet \
		-f "$(PWD)/test/Dockerfile" \
		--build-arg GNU="$(GNU)" \
		--build-arg BASH="$(BASH)" \
		--build-arg BATS_VERSION="$(TEST_BATS_VERSION)" \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) \
		./

.PHONY: test test-build test-unit test-plugin

# Do not pass in user flags to build tests.
unexport PYTHON_CFLAGS
unexport PYTHON_CONFIGURE_OPTS

test: test-unit test-plugin

test-unit: bats
	PATH="./bats/bin:$$PATH" test/run
	
test-plugin: bats
	cd plugins/python-build && $(PWD)/bats/bin/bats $${CI:+--tap} $${BATS_TEST_FILTER:+--filter "$${BATS_TEST_FILTER}"} test/$${BATS_FILE_FILTER}

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

.SECONDARY: bats-$(TEST_BATS_VERSION)
bats-$(TEST_BATS_VERSION):
	rm -rf bats
	ln -sf bats-$(TEST_BATS_VERSION) bats
	git clone --depth 1 --branch $(TEST_BATS_VERSION) https://github.com/bats-core/bats-core.git bats-$(TEST_BATS_VERSION)

.PHONY: bats
bats: bats-$(TEST_BATS_VERSION)
	ln -sf bats-$(TEST_BATS_VERSION) bats
