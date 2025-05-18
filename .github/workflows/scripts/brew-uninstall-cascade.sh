#!/bin/bash

declare -a packages rdepends
packages=("$@")

# have to try one by one, otherwise `brew uses` would only print
# packages that require them all rather than any of them
for package in "${packages[@]}"; do
  rdepends+=($(brew uses --installed --include-build --include-test --include-optional --recursive "$package"))
done
brew uninstall "${packages[@]}" "${rdepends[@]}"