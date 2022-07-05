#!/bin/sh
# Adapted from http://ppa.linuxfactory.or.kr/mastering/android-odroidn2-20210930/userscript.sh
set -ux

LOCAL_URL=/tmp/image.xz
REMOTE_URL=http://de.eu.odroid.in/ubuntu_22.04lts/N2/ubuntu-22.04-4.9-minimal-odroid-n2-20220622.img.xz
REMOTE_MD5=026cc5d1e23e1554a2b58783e1c50dec

# 1) Download and write the disk image to the eMMC

wget -O ${LOCAL_URL} ${REMOTE_URL}
LOCAL_MD5=$(md5sum ${LOCAL_URL} | awk '{print $1}')

if [ "${LOCAL_MD5}" != "${REMOTE_MD5}" ]; then
	echo "invalid hash"
	sleep 10
	exit 1
fi

xzcat ${LOCAL_URL} | dd conv=fsync bs=500M of=/dev/mmcblk0
rm ${LOCAL_URL}

# 2) Mount the root partition

partprobe
mkdir /tmp/root
mount /dev/mmcblk0p2 /tmp/root

# 3) Install the firstboot service

wget -O /tmp/root/bootstrap.sh https://raw.githubusercontent.com/EdgeNet-project/node/main/bootstrap.sh
chmod +x /tmp/root/bootstrap.sh

cat > /tmp/root/etc/systemd/system/edgenet-firstboot.service <<END
[Unit]
Description=EdgeNet first boot
After=network.target

[Service]
ExecStart=/bootstrap.sh
Type=oneshot
RemainAfterExit=yes
Restart=on-failure
RestartSec=15s
# Join the EdgeNet@home cluster
Environment="EDGENET_PLAYBOOK=edgenet-at-home-node.yml"

[Install]
WantedBy=multi-user.target
END

ln -fs /etc/systemd/system/edgenet-firstboot.service /tmp/root/etc/systemd/system/multi-user.target.wants/edgenet-firstboot.service

# 4) Enable the hardware watchdog

echo "RuntimeWatchdogSec=600" >> /tmp/root/etc/systemd/system.conf

# 5) Disable root SSH login

echo "PermitRootLogin no" >> /tmp/root/etc/ssh/sshd_config

# 6) Prevent unattended-upgrades from running on first boot

cat <<EOF > /tmp/root/etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

# 7) Give some time to review the output and boot
sleep 5
