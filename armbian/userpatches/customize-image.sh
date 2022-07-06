#!/bin/bash

# Disable root login.
passwd -l root
rm /root/.not_logged_in_yet

# Disable zram service: incompatible with k8s.
echo "ENABLED=false" > /etc/default/armbian-zram-config

# Enable the hardware watchdog.
echo "RuntimeWatchdogSec=600" >> /etc/systemd/system.conf

# Uncomment to enter a shell during build.
# bash

# Run EdgeNet bootstrap script.
export EDGENET_PLAYBOOK=edgenet-at-home-node-prep.yml
wget -O /tmp/bootstrap.sh https://raw.githubusercontent.com/EdgeNet-project/node/main/bootstrap.sh
chmod +x /tmp/bootstrap.sh && /tmp/bootstrap.sh
