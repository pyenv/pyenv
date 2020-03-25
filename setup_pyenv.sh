#pyenv
git clone https://github.com/nkpro2000sr/pyenv.git ~/.pyenv
# pyenv-virtualenv
git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
# pyenv-pip-migrate
git clone git://github.com/pyenv/pyenv-pip-migrate.git ~/.pyenv/plugins/pyenv-pip-migrate
# pyenv-update
git clone https://github.com/pyenv/pyenv-update.git ~/.pyenv/plugins/pyenv-update
# adding pyenv to environment
echo '#pyenv{' >> ~/.bashrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'if command -v pyenv 1>/dev/null 2>&1' >> ~/.bashrc
echo 'then' >> ~/.bashrc
echo '  eval "$(pyenv init -)"' >> ~/.bashrc
echo '  eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
echo 'fi' >> ~/.bashrc
# aliases
echo 'alias py="pyenv "' >> ~/.bashrc
echo 'alias pyv="pyenv virtualenv "' >> ~/.bashrc 
echo 'py-uninstall () {' >> ~/.bashrc
echo '  if [ `expr length "$(grep -En "^#pyenv{$|^#pyenv}$" ~/.bashrc | cut -d: -f1)"` != 0 ]' >> ~/.bashrc
echo '  then' >> ~/.bashrc
echo '    sed -i $(echo $(grep -En "^#pyenv{$|^#pyenv}$" ~/.bashrc | cut -d: -f1) | sed -r "s/ /,/g")d ~/.bashrc;' >> ~/.bashrc
echo '    rm -rf ~/.pyenv;' >> ~/.bashrc
echo '    echo "if you still getting py, manually restart shell by \`exec \$SHELL\` command"' >> ~/.bashrc
echo '    exec $SHELL' >> ~/.bashrc
echo '  fi' >> ~/.bashrc
echo '}' >> ~/.bashrc
echo '#pyenv}' >> ~/.bashrc
# HELP
echo "\`py install Version\` to install specific version of python"
echo "\`pyv Version VenvName\` to create virtualenv"
echo "\`py uninstall Version(or)VenvName\` to uninstall python version or virtualenv"
echo "\`py shell Version\` to change default \`python\` in current shell"
echo "\`py global Version\` to change default \`python\`"
echo "\`py local VenvName\` to change default \`python\` in \$PWD"
echo "\`py versions\` to get all installed versions of python and virtualenvs"
echo "\`py install -l\` to get all installable versions of python"
echo "\`py-uninstall\` to uninstall pyenv package"
# restating shell
echo "if you not getting py, manually restart shell by \`exec \$SHELL\` command"
exec $SHELL
