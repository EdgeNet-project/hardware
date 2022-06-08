#!/bin/sh
# Adapted from http://ppa.linuxfactory.or.kr/mastering/android-odroidn2-20210930/userscript.sh
# TODO: Create a custom image with Kubernetes pre-installed (using buildroot?)
set -ux

LOCAL_URL=/tmp/image.xz
REMOTE_URL=https://de.eu.odroid.in/ubuntu_20.04lts/n2/ubuntu-20.04-4.9-minimal-odroid-n2-20220228.img.xz
# REMOTE_URL=http://192.168.2.1/ubuntu-20.04-4.9-minimal-odroid-n2-20220228.img.xz
REMOTE_MD5=efd20d51d03e2286c79768b37e031e79

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

# 2) Mount the root partition and install the firstboot service

partprobe
mkdir /tmp/root
mount /dev/mmcblk0p2 /tmp/root

wget -O /tmp/root/bootstrap.sh https://raw.githubusercontent.com/EdgeNet-project/hardware/main/bootstrap.sh
chmod +x /tmp/root/bootstrap.sh

cat > /tmp/root/etc/systemd/system/edgenet-firstboot.service <<END
[Unit]
Description=EdgeNet first boot

[Service]
ExecStart=/bootstrap.sh
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
END

ln -fs /etc/systemd/system/edgenet-firstboot.service /tmp/root/etc/systemd/system/multi-user.target.wants/edgenet-firstboot.service

# 3) Give some time to review the output and boot
sleep 5
