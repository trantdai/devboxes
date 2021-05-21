#!/usr/bin/env bash
#SYNCHRONIZE LOCAL AND GUEST FILES
#mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g vagrant` vagrant /vagrant

#INSTALL PYTHON3 AND PIP3
yum install -y vim

#ADD USERS AND GROUPS AND ADD USER TO SUDOERS
#https://stackoverflow.com/questions/19648088/pass-environment-variables-to-vagrant-shell-provisioner
# mv /vagrant/.passwd /home/cyberauto/.passwd
#password="`head -1 /vagrant/.passwd`"
password="`cat /vagrant/.passwd`"
echo "cat /vagrant/.passwd"
echo $password
useradd -d /home/cyberauto cyberauto -p $password
passwd --expire cyberauto

#ENABLE PASSWORD AUTHENTICATION
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

# https://stackoverflow.com/questions/323957/how-do-i-edit-etc-sudoers-from-a-script
if [ -z "$(grep 'cyberauto    ALL=(ALL)       ALL' /etc/sudoers )" ]; then echo "cyberauto    ALL=(ALL)       ALL" | sudo EDITOR='tee -a' visudo; fi;

# useradd -m username -p password
# Use shell script to modify /etc/sudoers as follows - test
# Disable wheel: %wheel ALL=(ALL) ALL in /etc/sudoers
# Add cyberauto user to /etc/sudoers to provide full sudo acess: cyberauto ALL=(ALL) ALL
# Set requiring entering password after 5 mins: Defaults timestamp_timeout=5
# Set password maybe from env var or edit file using shell script
# Enable ssh

#EDIT SSH CONFIG
#config.vm.provision "shell", inline: <<-SHELL
#   sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
#   systemctl restart sshd.service
#SHELL

# SET UP PASSWORD BASED AUTHENTICATION
# Set password provided in .passwd for cyberauto user
#cat /home/cyberauto/.passwd | sudo chpasswd

#SSH KEY BASED AUTHENTICATION
# https://stackoverflow.com/questions/22643177/ssh-onto-vagrant-box-with-different-username
echo 'Setting up SSH key based authentication'
#mkdir -p /home/cyberauto/.ssh
chmod 700 /home/cyberauto/.ssh
cat /home/cyberauto/pubkeys/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
cat /home/cyberauto/pubkeys/dtran_id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chmod -R 600 /home/cyberauto/.ssh/authorized_keys