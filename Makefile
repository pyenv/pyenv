test: build/bats/bin/bats
	build/bats/bin/bats --tap test plugins/python-build/test

build/bats/bin/bats:
	git clone https://github.com/sstephenson/bats.git build/bats

.PHONY: test
