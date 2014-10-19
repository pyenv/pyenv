#!/usr/bin/env bash
# Usage: rbenv echo [-F<char>] VAR

if [[ $1 == -F* ]]; then
  sep="${1:2}"
  echo "${!2}" | tr "${sep:-:}" $'\n'
else
  echo "${!1}"
fi
