PYENV_PIP_REHASH_ROOT="${BASH_SOURCE[0]%/*}/pip-rehash"
PYENV_REHASH_COMMAND="${PYENV_COMMAND##*/}"

# Remove any version information, from e.g. "pip2" or "pip3.10".
if [[ $PYENV_REHASH_COMMAND =~ ^(pip|easy_install)[23](\.[0-9]+)?$ ]]; then
  PYENV_REHASH_COMMAND="${BASH_REMATCH[1]}"
# Check for ` -m pip ` in arguments
elif [[ "$*" =~ [[:space:]]-m[[:space:]]pip[[:space:]] ]]; then
  PYENV_REHASH_COMMAND="pip"
fi

if [ -x "${PYENV_PIP_REHASH_ROOT}/${PYENV_REHASH_COMMAND}" ]; then
  PYENV_COMMAND_PATH="${PYENV_PIP_REHASH_ROOT}/${PYENV_REHASH_COMMAND##*/}"
  PYENV_BIN_PATH="${PYENV_PIP_REHASH_ROOT}"
  export PYENV_REHASH_REAL_COMMAND="${PYENV_COMMAND##*/}"
fi
