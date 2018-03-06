Vagrant develop box
===================

Feature
-------

* Nginx
* MySQL 5.7
* PHP 7.2
* Golang
* Redis
* NodeJS 9.x with yarn
* memcached
* beanstalkd
* Samba server

Requirements
------------

* Install [VirtualBox][VirtualBox]
* Install [Vagrant][Vagrant]

Build
-----

```shell
vagrant up
vagrant ssh
```

> Change default config in [vagrant.yml][vagrant.yml] 

### Clean

```shell
sudo apt autoremove
sudo apt clean
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c && exit
```

Publish
-------

```shell
# package box
./make.sh package
# create box version and provider
./make.sh create -v 0.2.0
# upload box file
./make.sh upload -v 0.2.0
# release box
./make.sh release -v 0.2.0
```

Run
----

Use [Vagrantfile][build/Vagrantfile] and change some config

```shell
vagrant up
vagrant ssh
```

[VirtualBox]: https://www.virtualbox.org/wiki/Downloads
[Vagrant]: http://www.vagrantup.com/downloads
[vagrant.yml]: https://github.com/lostsnow/vagrant-dev-box/blob/master/playbooks/vagrant.yml
[build/Vagrantfile]: https://github.com/lostsnow/vagrant-dev-box/blob/master/build/Vagrantfile