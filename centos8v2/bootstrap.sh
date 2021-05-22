#!/usr/bin/env bash
#SYNCHRONIZE LOCAL AND GUEST FILES
#mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g vagrant` vagrant /vagrant

#INSTALL PYTHON3 AND PIP3
yum install -y vim

echo "ADDING USERS, GROUPS AND SET PASSWORDS..."
#https://stackoverflow.com/questions/19648088/pass-environment-variables-to-vagrant-shell-provisioner
# mv /vagrant/.passwd /home/cyberauto/.passwd
#password="`head -1 /vagrant/.passwd`"
password="`cat /vagrant/.passwd`"
useradd -d /home/cyberauto cyberauto -p $password
#https://www.2daygeek.com/linux-passwd-chpasswd-command-set-update-change-users-password-in-linux-using-shell-script/
#https://www.systutorials.com/changing-linux-users-password-in-one-command-line/
echo $password | sudo passwd --stdin cyberauto
echo $password | sudo passwd --stdin vagrant
#passwd --expire cyberauto

 echo "ADDING USER TO SUDOERS AND DISABLE PASSWORD PROMT AND WHEEL GROUP..."
# https://stackoverflow.com/questions/323957/how-do-i-edit-etc-sudoers-from-a-script
if [ -z "$(grep 'cyberauto    ALL=(ALL)       ALL' /etc/sudoers )" ]; then echo "cyberauto    ALL=(ALL)       ALL" | sudo EDITOR='tee -a' visudo; fi;
if [ -z "$(grep 'cyberauto        ALL=(ALL)       NOPASSWD: ALL' /etc/sudoers )" ]; then echo "cyberauto        ALL=(ALL)       NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo; fi;
#https://stackoverflow.com/questions/323957/how-do-i-edit-etc-sudoers-from-a-script
#echo '# %wheel  ALL=(ALL)       ALL' | sudo EDITOR='tee -a' visudo
#https://stackoverflow.com/questions/13626798/editing-the-sudo-file-in-a-shell-script
sed -i 's/%wheel  ALL=(ALL)       ALL/# %wheel  ALL=(ALL)       ALL/g' /etc/sudoers

echo "ENABLING SSH PASSWORD AUTHENTICATION..."
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

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

# https://stackoverflow.com/questions/22643177/ssh-onto-vagrant-box-with-different-username
echo 'SETTING UP SSH KEY BASED AUTHENTICATION...'
#mkdir -p /home/cyberauto/.ssh
chmod 700 /home/cyberauto/.ssh
cat /home/cyberauto/pubkeys/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
cat /home/cyberauto/pubkeys/dtran_id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chmod -R 600 /home/cyberauto/.ssh/authorized_keys