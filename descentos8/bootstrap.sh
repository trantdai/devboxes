#!/usr/bin/env bash
#SYNCHRONIZE LOCAL AND GUEST FILES
#mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g vagrant` vagrant /vagrant

echo ""
echo "*** START OF BOOTSTRAPPING SHELL ***"
echo ""
echo "INSTALL UTILS AND DEVELOPMENT TOOLS..."
yum install -y vim

echo "ADDING USERS, GROUPS AND SET PASSWORDS..."
#https://stackoverflow.com/questions/19648088/pass-environment-variables-to-vagrant-shell-provisioner
# mv /vagrant/.passwd /home/cyberauto/.passwd
#password="`head -1 /vagrant/.passwd`"
password="`cat /vagrant/.passwd`"
#useradd -d /home/cyberauto cyberauto -p $password
#https://www.cyberciti.biz/faq/check-if-a-directory-exists-in-linux-or-unix-shell/
#[ ! -d "/home/cyberauto cyberauto" ] && mkdir -p "/home/cyberauto cyberauto"
if [ $(grep -c "^cyberauto:" /etc/passwd) -eq 0 ]; then useradd -d /home/cyberauto cyberauto -p $password; fi;
echo "END OF USER ADDITION..."
#https://www.2daygeek.com/linux-passwd-chpasswd-command-set-update-change-users-password-in-linux-using-shell-script/
#https://www.systutorials.com/changing-linux-users-password-in-one-command-line/
echo $password | sudo passwd --stdin cyberauto
echo $password | sudo passwd --stdin vagrant
echo $password | sudo passwd --stdin root
#passwd --expire cyberauto

 echo "ADDING USER TO SUDOERS AND DISABLE PASSWORD PROMT AND WHEEL GROUP..."
# https://stackoverflow.com/questions/323957/how-do-i-edit-etc-sudoers-from-a-script
if [ -z "$(grep 'cyberauto    ALL=(ALL)       ALL' /etc/sudoers )" ]; then echo "cyberauto    ALL=(ALL)       ALL" | sudo EDITOR='tee -a' visudo; fi;
if [ -z "$(grep 'cyberauto        ALL=(ALL)       NOPASSWD: ALL' /etc/sudoers )" ]; then echo "cyberauto        ALL=(ALL)       NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo; fi;
#https://stackoverflow.com/questions/323957/how-do-i-edit-etc-sudoers-from-a-script
#echo '# %wheel  ALL=(ALL)       ALL' | sudo EDITOR='tee -a' visudo
#https://stackoverflow.com/questions/13626798/editing-the-sudo-file-in-a-shell-script
sudo sed -i 's/%wheel  ALL=(ALL)       ALL/# %wheel  ALL=(ALL)       ALL/g' /etc/sudoers

echo "ENABLING SSH PASSWORD AUTHENTICATION..."
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

# https://stackoverflow.com/questions/22643177/ssh-onto-vagrant-box-with-different-username
echo 'SETTING UP SSH KEY BASED AUTHENTICATION...'
mkdir -p /home/cyberauto/.ssh
mv /tmp/id_rsa /home/cyberauto/.ssh
mv /tmp/id_rsa.pub /home/cyberauto/.ssh
chmod 700 /home/cyberauto/.ssh
chmod 644  /home/cyberauto/.ssh/id_rsa.pub
chmod 600  /home/cyberauto/.ssh/id_rsa
chmod 755 /home/cyberauto

mkdir -p /home/cyberauto/pubkeys
#mv /tmp/dtran_id_rsa.pub /home/cyberauto/pubkeys
cat /home/cyberauto/.ssh/id_rsa.pub >> /home/cyberauto/.ssh/authorized_keys
#cat /home/cyberauto/pubkeys/dtran_id_rsa.pub >> /home/cyberauto/.ssh/authorized_keys
chmod -R 600 /home/cyberauto/.ssh/authorized_keys

# Change ownership of all files and directories recursively under
# /home/cyberauto/.ssh directory to cyberauto
sudo chown -R cyberauto:cyberauto /home/cyberauto

sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

#https://www.golinuxcloud.com/run-script-at-startup-boot-without-cron-linux/
#https://www.2daygeek.com/execute-run-linux-scripts-command-at-reboot-startup/
echo 'RUNNING HELLO MESSAGE AT STARTUP...'
cat <<-EOF! > /home/cyberauto/custom_startup.sh
#!/bin/bash
# Simple program to use for testing startup configurations
# with systemd.
#
echo "###############################"
echo "######### Hello DES! ########"
echo "###############################"
EOF!
chmod +x /home/cyberauto/custom_startup.sh
chmod +x /etc/rc.d/rc.local
if [ -z "$(grep '/home/cyberauto/custom_startup.sh' /etc/rc.d/rc.local)" ]; then echo "/home/cyberauto/custom_startup.sh" >> /etc/rc.d/rc.local; fi;
echo ""
echo "*** END OF BOOTSTRAPPING SHELL ***"
echo ""