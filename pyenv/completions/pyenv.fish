function __fish_pyenv_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'pyenv' ]
    return 0
  end
  return 1
end

function __fish_pyenv_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c pyenv -n '__fish_pyenv_needs_command' -a '(pyenv commands)'
for cmd in (pyenv commands)
  complete -f -c pyenv -n "__fish_pyenv_using_command $cmd" -a \
    "(pyenv completions (commandline -opc)[2..-1])"
end
