#!/bin/bash
set -e

# Copy SSH keys from mounted volume
sudo cp -R /.ssh /home/coder/.ssh
sudo chmod 700 /home/coder/.ssh
if [ -e "/home/coder/.ssh/id_rsa.pub" ]
then
    sudo chmod 644 /home/coder/.ssh/id_rsa.pub
fi
if [ -e "/home/coder/.ssh/id_rsa.pub" ]
then
    sudo chmod 400 /home/coder/.ssh/id_rsa
fi

# Give permission to docker
sudo chmod 777 /var/run/docker.sock

dumb-init -- $@
