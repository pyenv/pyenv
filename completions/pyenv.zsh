#compdef pyenv

# Install as _pyenv into your fpath e.g., /usr/share/zsh/site-functions/ or:
#
#   $ . <gitdir>/completions/pyenv.zsh
#   $ compdef _pyenv pyenv

_pyenv() {
    _arguments \
        ': :("${(f)$(pyenv commands)}")' \
        '*: :("${(f)$(pyenv completions ${words[2,-2]})}")'
}
