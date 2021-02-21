Vagrant develop box
===================

System
------

Ubuntu 20.04

Packages
--------

* [Nginx][Nginx]
* [MySQL][MySQL] 8.0
* [Redis][Redis]
* [MongoDB][MongoDB]
* [memcached][memcached]
* [beanstalkd][beanstalkd]
* [PHP][PHP] 7.3 with [composer][composer]
* [Golang][Golang]
* [NodeJS][NodeJS] 14.x with [yarn][yarn]
* [Docker][Docker] with [docker-compose][docker-compose]
* [Samba server][Samba server]

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
sudo apt autoclean
sudo rm -rf /var/lib/apt/lists/*
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
[Vagrant]: https://www.vagrantup.com/downloads.html
[vagrant.yml]: playbooks/vagrant.yml
[build/Vagrantfile]: build/Vagrantfile
[Nginx]: https://nginx.org/en/download.html
[MySQL]: https://dev.mysql.com/downloads/
[Redis]: https://redis.io/download
[MongoDB]: https://www.mongodb.com/download-center/community
[memcached]: https://memcached.org/downloads
[beanstalkd]: https://beanstalkd.github.io/download.html
[PHP]: https://www.php.net/downloads.php
[composer]: https://getcomposer.org/download/
[Golang]: https://golang.org/dl/
[NodeJS]: https://nodejs.org/en/download/
[yarn]: https://yarnpkg.com/en/docs/install
[Docker]: https://docs.docker.com/install/
[docker-compose]: https://docs.docker.com/compose/install/
[Samba server]: https://www.samba.org/samba/download/
