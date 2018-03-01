Vagrant develop box
===================

Feature
-------

* Nginx
* MySQL 5.7
* PHP 7.2
* Golang

Requirements
------------

* Install [VirtualBox][1]
* Install [Vagrant][2]

Build
-----

```shell
vagrant up
vagrant ssh
```

> Change default config in [vagrant.yml][3] 

### Clean

```shell
sudo apt clean
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c && exit
```

Publish
-------

```shell
# create box version and provider
./make.sh create -v 0.2.0
# upload box file
./make.sh upload -v 0.2.0
# release box
./make.sh release -v 0.2.0
```

Run
----

Use [Vagrantfile][4] and change some config

```shell
vagrant up
vagrant ssh
```

[1]: https://www.virtualbox.org/wiki/Downloads
[2]: http://www.vagrantup.com/downloads
[3]: https://github.com/lostsnow/vagrant-dev-box/blob/master/playbooks/vagrant.yml
[4]: https://github.com/lostsnow/vagrant-dev-box/blob/master/build/Vagrantfile