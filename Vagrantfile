# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "archlinux/archlinux"

    config.vm.provision "file", source: "~/.ansible-auto.txt", destination: ".ansible-auto.txt"

  # config.vm.provision "ansible_local" do |ansible|
  #   ansible.install = true
  #   ansible.verbose = "v"
  #   ansible.playbook = "local.yml"
  #   ansible.raw_arguments = "--connection=local"
  # end

  config.vm.provision "shell" do |s|
    s.inline = "pacman -Syu --noconfirm -q ansible && \
    ansible-playbook --connection=local /vagrant/local.yml"
  end
end
