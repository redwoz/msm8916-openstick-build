#! /bin/bash
set -ex

#download extras
pushd /output/working
git clone https://salsa.debian.org/Mobian-team/mobile-usb-networking --depth=1 && cd ./mobile-usb-networking && git checkout 056d9215bb38697b9dc59ba256fc6e904ee5923d && cd ..
git clone https://github.com/hyx0329/openstick-failsafe-guard --depth=1 && cd ./openstick-failsafe-guard && git checkout 07a8cc6e2558411f746a3cf529c7565dc88668ba && cd ..
wget http://ports.ubuntu.com/pool/multiverse/l/linux-firmware-snapdragon/linux-firmware-snapdragon_1.3-0ubuntu3_arm64.deb
popd

# prep rootfs image
truncate -s 1024M /output/working/rootfs_base.ext4
mkfs.ext4 /output/working/rootfs_base.ext4
sleep 5
mount /output/working/rootfs_base.ext4 /rootfs

# debootstrap bullseye
export DEBIAN_VERSION=bullseye
debootstrap --arch=arm64 --include openssh-server,nano,wget,initramfs-tools,cron,wpasupplicant,init,dbus,dnsmasq,ca-certificates,gawk $DEBIAN_VERSION /rootfs http://deb.debian.org/debian/

umount /rootfs
