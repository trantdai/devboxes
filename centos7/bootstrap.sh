#!/usr/bin/env bash
#SYNCHRONIZE LOCAL AND GUEST FILES
#mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g vagrant` vagrant /vagrant

#INSTALL PYTHON3 AND PIP3
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
#yum install -y docker-ce-18.09.1 docker-ce-cli-18.09.1 containerd.io
#Add user vagrant to docker group to avoid permission denied error
usermod -aG docker vagrant
#Configure Docker to start on boot
systemctl start docker
systemctl enable docker

