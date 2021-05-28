#!/usr/bin/env bash
echo ""
echo "*** START OF BOOTSTRAPPING SHELL ***"
echo ""
echo "INSTALL UTILS AND DEVELOPMENT TOOLS..."
#https://www.digitalocean.com/community/tutorials/how-to-install-python-3-and-set-up-a-local-programming-environment-on-centos-7
yum -y update
yum -y install yum-utils
yum -y groupinstall development
yum install -y epel-release
#https://unix.stackexchange.com/questions/345124/dont-work-yum-update-yum-doesnt-have-enough-cached-data-to-continue
sed -i 's/#baseurl/baseurl/g'  /etc/yum.repos.d/epel.repo
sed -i 's/metalink/#metalink/g'  /etc/yum.repos.d/epel.repo
yum install -y python36 python36-pip
python3.6 -V
python3.6 -m pip install 'pylint==2.6.0' 'coverage==5.2.1' 'twine==3.2.0' --trusted-host pypi.python.org
python3.6 -m pip install 'paramiko==2.6.0' --trusted-host pypi.python.org
yum install -y vim
yum install -y tree
yum install -y git

#EXTRACT AND INSTALL CORPORATE CONTOSO ROOT CA TO AVOID FOLLOWING ERROR CAUSED BY SSL INSPECTION WHEN DOCKER LOGIN
#Error response from daemon: Get https://registry-1.docker.io/v2/: x509: certificate signed by unknown authority
openssl s_client -showcerts -connect registry-1.docker.io:443 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/pki/ca-trust/source/anchors/Contoso-Cloud-Services-Root-CA.crt
update-ca-trust

#INSTALL & START DOCKER ENGINE
yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
#Install specific version 18.09.1
yum install -y docker-ce-20.10.6 docker-ce-cli-20.10.6 containerd.io
#Add user vagrant to docker group to avoid permission denied error
usermod -aG docker vagrant
#Configure Docker to start on boot
systemctl start docker
systemctl enable docker

echo "ADDING USERS, GROUPS AND SET PASSWORDS..."
#https://stackoverflow.com/questions/19648088/pass-environment-variables-to-vagrant-shell-provisioner
# mv /vagrant/.passwd /home/cyberauto/.passwd
#password="`head -1 /vagrant/.passwd`"
password="`cat /vagrant/.passwd`"
#useradd -d /home/cyberauto cyberauto -p $password
#https://www.cyberciti.biz/faq/check-if-a-directory-exists-in-linux-or-unix-shell/
#[ ! -d "/home/cyberauto cyberauto" ] && mkdir -p "/home/cyberauto cyberauto"
if [ $(grep -c "^cyberauto:" /etc/passwd) -eq 0 ]; then useradd -d /home/cyberauto cyberauto -p $password; fi;
#https://www.2daygeek.com/linux-passwd-chpasswd-command-set-update-change-users-password-in-linux-using-shell-script/
#https://www.systutorials.com/changing-linux-users-password-in-one-command-line/
echo $password | sudo passwd --stdin cyberauto
echo $password | sudo passwd --stdin vagrant
echo $password | sudo passwd --stdin root

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

echo 'ADDING COMMON ALIASES TO .BASHRC...'
cat <<-EOF! >> /home/cyberauto/.bashrc
alias ll="ls -la"
alias auto="ssh cyberauto@10.0.0.10"
alias des="ssh cyberauto@10.0.0.5"
alias mgmt="ssh cyberauto@10.0.0.10"
EOF!
source /home/cyberauto/.bashrc

echo 'BUILDING DOCKER IMAGE USING JENKINS AS CODE...'
cd /home/cyberauto
git clone https://github.com/trantdai/jenkins.git
cd jenkins
docker build -t jenkins:jcasc .

echo 'RUN JENKINS CONTAINER FOR THE FIRST TIME...'
docker run --name jenkins --rm -p 8080:8080 --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=$password jenkins:jcasc &

#https://www.golinuxcloud.com/run-script-at-startup-boot-without-cron-linux/
#https://www.2daygeek.com/execute-run-linux-scripts-command-at-reboot-startup/
echo 'MAKING SURE JENKINS DOCKER CONTAINER RUN AUTOMATICALLY AT STARTUP...'
cat <<-EOF! > /home/cyberauto/custom_startup.sh
#!/bin/bash
docker run --name jenkins --rm -p 8080:8080 --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=$password jenkins:jcasc &
EOF!
chmod +x /home/cyberauto/custom_startup.sh
chmod +x /etc/rc.d/rc.local
if [ -z "$(grep '/home/cyberauto/custom_startup.sh' /etc/rc.d/rc.local)" ]; then echo "/home/cyberauto/custom_startup.sh" >> /etc/rc.d/rc.local; fi;
echo ""
echo "*** END OF BOOTSTRAPPING SHELL ***"
echo ""