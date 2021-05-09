# Table of Content
- [Table of Content](#table-of-content)
- [Introduction to Vagrant Built Development VMs](#introduction-to-vagrant-built-development-vms)
- [Set Up Guide](#set-up-guide)
- [Usage Guide](#usage-guide)
# Introduction to Vagrant Built Development VMs

This repo contains a list of development VMs built and managed using the tool [Vagrant](https://www.vagrantup.com/) developed by HashiCorp. Currently there are two VMs built in this repo: Cento 7 in `centos7` directory and Kali Linux in `kali` directory.

# Set Up Guide

1. Download and install [Vagrant](https://www.vagrantup.com/)
2. Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
3. Clone this [repo](https://github.com/trantdai/devboxes): `git clone https://github.com/trantdai/devboxes.git`

# Usage Guide

1. Change working directory to VM directory like `devboxes\centos7`: `cd devboxes\centos7`
3. Bring up a virtual machine: `vagrant up`
3. SSH into the machine: `vagrant ssh`
4. Log out of the machine SSH session: `vagrant@vagrant:~$ logout`
5. Update the machine whenever `bootstrap.sh` is updated (similar to run `vagrant up` first time): `vagrant reload --provision`
6. Teardown an environment:
   1. Suspend the machine: `vagrant suspend`
   2. Halt the machine: `vagrant halt`
   3. Reload the machine: `vagrant reload`
   4. Destroy the machine: `vagrant destroy`

# References
https://www.howtoforge.com/setup-a-local-wordpress-development-environment-with-vagrant/
