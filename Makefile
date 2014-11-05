test: build/bats/bin/bats
	build/bats/bin/bats --tap test
	cd plugins/python-build && $(PWD)/build/bats/bin/bats --tap test

build/bats/bin/bats:
	git clone https://github.com/sstephenson/bats.git build/bats

.PHONY: test
