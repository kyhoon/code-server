#!/bin/bash
set -e

# Copy SSH keys from mounted volume
sudo cp -R /.ssh /home/coder/.ssh
sudo chown -R coder /home/coder/.ssh

# Give permission to docker
sudo chmod 777 /var/run/docker.sock

dumb-init -- $@
