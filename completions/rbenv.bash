_commands()
{
    local cur commands
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    commands="exec prefix rehash set-default set-local version versions\
        whence which"

    COMPREPLY=( $( compgen -W "${commands}" -- ${cur} ) )
}

_rubies()
{
    local cur rubies
    local ROOT=$HOME/.rbenv/versions
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    rubies=($ROOT/*)
    # remove all but the final part of the name
    rubies="${rubies[@]##*/}"

    COMPREPLY=( $( compgen -W "${rubies}" -- ${cur} ) )
}

_rbenv()
{
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ "${prev}" == set-default ]]; then
        _rubies
    else
        _commands
    fi
}

complete -F _rbenv rbenv

# vim: set ts=4 sw=4 tw=75 filetype=sh: