release_version := $(shell GIT_CEILING_DIRECTORIES=$(PWD) bin/rbenv --version | cut -d' ' -f2)

share/man/man1/rbenv.1: share/man/man1/rbenv.1.adoc
	asciidoctor -b manpage -a version=$(release_version:v%=%) $<
