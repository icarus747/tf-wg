#!/bin/bash

apt-get update
apt-get install -y \
  software-properties-common \
  add-apt-key \
  munin \
  git \
  sshguard

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
apt-get upgrade -y

# enable automatic reboots and package pruning 
# to keep disk usage in check

sed \
  -e 's/\/\/Unattended-Upgrade::Automatic-Reboot/Unattended-Upgrade::Automatic-Reboot/' \
  -e 's/\/\/Unattended-Upgrade::Remove-Unused-Kernel-Packages/Unattended-Upgrade::Remove-Unused-Kernel-Packages/' \
  -e 's/\/\/Unattended-Upgrade::Remove-New-Unused-Dependencies/Unattended-Upgrade::Remove-New-Unused-Dependencies/' \
  < /etc/apt/apt.conf.d/50unattended-upgrades \
  > /tmp/50unattended-upgrades
mv /tmp/50unattended-upgrades /etc/apt/apt.conf.d/

DOCKER_CONFIG=${DOCKER_CONFIG:-/home/ubuntu/.docker}

mkdir -p $DOCKER_CONFIG/cli-plugins

DOCKER_COMPOSE=$DOCKER_CONFIG/cli-plugins/docker-compose

curl -SL https://github.com/docker/compose/releases/download/v2.24.0-birthday.10/docker-compose-linux-x86_64 -o $DOCKER_COMPOSE


chmod +x $DOCKER_COMPOSE
usermod -aG docker ubuntu
reboot