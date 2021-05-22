# Table of Content
- [Table of Content](#table-of-content)
- [Introduction to Vagrant Built Development VMs](#introduction-to-vagrant-built-development-vms)
- [Set Up Guide](#set-up-guide)
- [Usage Guide](#usage-guide)
- [References](#References)

# Introduction to Vagrant Built Development VMs

This repo contains a list of development VMs built and managed using the tool [Vagrant](https://www.vagrantup.com/) developed by HashiCorp. Currently there are three VMs built in this repo: Cento 7 in `centos7` directory, Centos 8 in `centos8` and Kali Linux in `kali` directory.
The following are provisioned/installed automatically during the VM boot process using the shell script `bootstrap.sh`:
- Utils
- Development tools
- Python36 and Python libraries
- Vim
- Tree
- Active Docker service
- Replacement of the user `vagrant`'s default password with password provided in `.passwd`
- User `cyberauto` creation with password provided in `.passwd`
- Enablement of SSH password authentication
- Passwordless `sudo` setup for user `cyberauto`
- Removal of the `sudo` privilege from the `wheel` group

# Set Up Guide

1. Download and install [Vagrant](https://www.vagrantup.com/)
2. Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
3. Clone this [repo](https://github.com/trantdai/devboxes): `git clone https://github.com/trantdai/devboxes.git`

# Usage Guide

1. Change working directory to VM directory like `devboxes\centos8`: `cd devboxes\centos8`
2. Create the `.passwd` file that contains the password for user `cyberauto`: `echo "<yourpassword>" > .passwd` 
3. Bring up a virtual machine: `vagrant up`
4. SSH into the machine: `vagrant ssh`
5. Log out of the machine SSH session: `vagrant@vagrant:~$ logout`
6. Update the machine whenever `bootstrap.sh` is updated (similar to run `vagrant up` first time): `vagrant reload --provision` or `vagrant --provision` or `vagrant provision`
7. Teardown an environment:
   1. Suspend the machine: `vagrant suspend`
   2. Halt the machine: `vagrant halt`
   3. Reload the machine: `vagrant reload`
   4. Destroy the machine: `vagrant destroy`
8. Debugging: `vagrant up --debug` or `vagrant up --debug 2>&1 | Tee-Object -FilePath ".\vagrant.log"`

# References
https://www.howtoforge.com/setup-a-local-wordpress-development-environment-with-vagrant/
