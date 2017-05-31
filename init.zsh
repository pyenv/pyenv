root=$(dirname $0)

for plugin in ${root}/plugins/*; do
    [ -d "${plugin}/bin" ] && export PATH="${plugin}/bin:$PATH"
done

export PATH="${root}/bin:$PATH"
export PYENV_SHELL=zsh
# fpath=($root/completions $fpath)

# lazy pyenv init/rehash
pyenv() {
    unset -f pyenv

    # make sure the shims are initiated and usable
    mkdir -p "${PYENV_ROOT}/"{shims,versions}
    export PATH="${PYENV_ROOT}/shims:${PATH}"
    command pyenv rehash 2>/dev/null

    ${root}/bin/pyenv "$@"
}

true # Return success exit code otherwise antigen breaks
