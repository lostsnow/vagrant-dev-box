# Optimized for Vagrant 1.7 and above.
Vagrant.require_version ">= 1.7.0"

Vagrant.configure(2) do |config|
  config.vm.boot_timeout = 600

  config.vm.box = "ubuntu/bionic64"

  config.vm.hostname = "dev-box"
  config.vm.define "dev-box"
  config.vm.provider :virtualbox do |vb|
    vb.name = "dev-box"
    vb.memory = 2048
    vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
    vb.customize [ "modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  # Disable the new default behavior introduced in Vagrant 1.7, to
  # ensure that all Vagrant machines will use the same SSH key pair.
  # See https://github.com/mitchellh/vagrant/issues/5005
  config.ssh.insert_key = false

  # Run Ansible from the Vagrant VM
  config.vm.provision "ansible_local" do |ansible|
    ansible.verbose = "vv"
    ansible.playbook = "playbooks/vagrant.yml"
  end

  config.vm.network "private_network", ip: "172.22.22.22"
end
