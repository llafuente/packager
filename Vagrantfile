# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # config.vm.box = "chef/centos-7.0" # bad
  #config.vm.box = "puppetlabs/centos-7.0-64-nocm"
  config.vm.box = "relativkreativ/centos-7-minimal"

  # config.vm.network "forwarded_port", guest: 80, host: 80

  for i in 9000..9100
    config.vm.network :forwarded_port, guest: i, host: i
  end

  # config.vm.network "private_network", ip: "192.168.33.10"

  # config.ssh.forward_agent = true

  config.vm.synced_folder File.dirname(__FILE__) + "/../", "/noboxout",  create: true

  config.vm.provision "shell", path: "prepare-instance.sh"
  config.vm.provision "shell", path: "mongodb.sh"
  config.vm.provision "shell", path: "node.sh"
  config.vm.provision "shell", path: "misc.sh"
  config.vm.provision "shell", path: "ntp.sh"
  config.vm.provision "shell", path: "git.sh"
end
