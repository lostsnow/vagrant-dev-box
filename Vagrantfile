# Optimized for Vagrant 1.7 and above.
Vagrant.require_version ">= 1.7.0"

required_plugins = %w( vagrant-vbguest vagrant-disksize )
_retry = false
required_plugins.each do |plugin|
  unless Vagrant.has_plugin? plugin
    system "vagrant plugin install #{plugin}"
      _retry=true
  end
end

if (_retry)
  exec "vagrant " + ARGV.join(' ')
end

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.hostname = "dev-box"
  config.vm.define "dev-box"
  config.vm.provider :virtualbox do |vb|
    vb.name = "dev-box"
    #vb.memory = 2048
  end

  #config.disksize.size = "50GB"

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