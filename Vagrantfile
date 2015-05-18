# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "chef/ubuntu-14.04"

  config.ssh.forward_agent = true
  config.vm.synced_folder ".", "/home/vagrant/project"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end

  config.berkshelf.enabled = false

  config.vm.provision "chef_solo" do |chef|
    chef.cookbooks_path = ["cookbooks", "berks-cookbooks"]
    chef.log_level = :info
    chef.add_recipe "dev-essential"
    chef.add_recipe "ruby"
    chef.add_recipe "postgresql"
  end
end
