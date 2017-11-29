function __fish_rbenv_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'rbenv' ]
    return 0
  end
  return 1
end

function __fish_rbenv_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c rbenv -n '__fish_rbenv_needs_command' -a '(rbenv commands)'
for cmd in (rbenv commands)
  complete -f -c rbenv -n "__fish_rbenv_using_command $cmd" -a \
    "(rbenv completions (commandline -opc)[2..-1])"
end
