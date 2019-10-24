#!/bin/bash
set -e

# Copy SSH keys from mounted volume
cp -R /.ssh /home/coder/.ssh
sudo chmod 700 /home/coder/.ssh
sudo chmod 644 /home/coder/.ssh/id_rsa.pub
sudo chmod 400 /home/coder/.ssh/id_rsa

# Give permission to docker
sudo chmod 777 /var/run/docker.sock

dumb-init -- $@
