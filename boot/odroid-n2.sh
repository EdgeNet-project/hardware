#!/bin/sh
# Adapted from http://ppa.linuxfactory.or.kr/mastering/android-odroidn2-20210930/userscript.sh
set -ux

LOCAL_URL=/tmp/image.xz
REMOTE_URL=ftp://ftp.iris.dioptra.io/Armbian_22.08.0-trunk_Odroidn2_jammy_current_5.10.123_minimal.img.xz
REMOTE_MD5=82f8aefcbb01285dd5fa8ae3a0e8b106

# Download and write the disk image to the eMMC
wget -O ${LOCAL_URL} ${REMOTE_URL}
LOCAL_MD5=$(md5sum ${LOCAL_URL} | awk '{print $1}')

if [ "${LOCAL_MD5}" != "${REMOTE_MD5}" ]; then
	echo "invalid hash"
	sleep 60
	# Reboot
	echo 1 > /proc/sys/kernel/sysrq
	echo b > /proc/sysrq-trigger
fi

xzcat ${LOCAL_URL} | dd conv=fsync bs=500M of=/dev/mmcblk0
rm ${LOCAL_URL}

# Give some time to review the output before booting
sleep 5
