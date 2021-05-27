# Release/1.0
- Created 3 boxes for DES, management, and automation from Centos8
- Created `cyberauto` user, added it to sudoers on all VMs to disable password prompt automatically
- Disabled `wheel` group automatically
- Replaced the default password for users `root` and `vagrant` to the one provided in `.passwd` automatically
- Enabled SSH password authentication automatically
- Docker service run automatically on autocentos8 VM
- Jenkins run within a Docker container automatically on autocentos8 VM

# Release/1.1
 - Replaced the default password for users `root` to the one provided in `.passwd` (provided by user) automatically
 - Provisioned SSH key authentication automatically using the private key (provided by user) in `../prikeys` directory and public key (provided by user) in `../pubkeys`
 - Set directory and file permissions with `/home/cyberauto` appropriately