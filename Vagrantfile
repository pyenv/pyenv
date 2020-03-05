# VM provisioning for testing new python versions

# required to prevent virtualbox trying to start several servers
# on the same interface
# https://github.com/hashicorp/vagrant/issues/8878#issuecomment-345112810
class VagrantPlugins::ProviderVirtualBox::Action::Network
  def dhcp_server_matches_config?(dhcp_server, config)
    true
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.synced_folder "./", "/home/vagrant/.pyenv"
  #config.vm.network "private_network", type: "dhcp"

  config.vm.provision :shell, path: "test/vagrant/provision.sh"
end
