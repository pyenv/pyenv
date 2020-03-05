#!/bin/bash
set -e
set -x
export DEBIAN_FRONTEND=noninteractive

apt-get update
sudo apt-get install -y \
	make \
	build-essential \
	libssl-dev \
	zlib1g-dev \
	libbz2-dev \
	libreadline-dev \
	libsqlite3-dev \
	wget \
	curl \
	llvm \
	libncurses5-dev \
	libncursesw5-dev \
	xz-utils \
	tk-dev \
	libffi-dev \
	liblzma-dev \
	python-openssl \
	git

echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /home/vagrant/.profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/vagrant/.profile
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> /home/vagrant/.profile
chown vagrant:vagrant /home/vagrant/.profile

