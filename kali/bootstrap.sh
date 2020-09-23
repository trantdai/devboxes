#!/usr/bin/env bash
#SYNCHRONIZE LOCAL AND GUEST FILES
#mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g vagrant` vagrant /vagrant

#INSTALL PYTHON3 AND PIP3

#EXTRACT AND INSTALL CORPORATE CONTOSO CLOUD ROOT CA TO AVOID FOLLOWING ERROR CAUSED BY SSL INSPECTION WHEN DOCKER LOGIN
#Error response from daemon: Get https://registry-1.docker.io/v2/: x509: certificate signed by unknown authority
#openssl s_client -showcerts -connect registry-1.docker.io:443 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/pki/ca-trust/source/anchors/Contoso-Cloud-Services-Root-CA.crt
#update-ca-trust

#INSTALL & START DOCKER ENGINE

