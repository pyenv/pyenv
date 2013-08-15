function __fish_pyenv
  pyenv commands
end

complete -f -c pyenv -a '(__fish_pyenv)'
