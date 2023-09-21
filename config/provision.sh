#! /bin/bash
set -ex

echo "debian-$DEBIAN_VERSION" > /etc/hostname
passwd -d root

apt -y install mobile-tweaks-common network-manager

########################
# KERNEL

mkdir -p /lib/modules/5.15.0-handsomekernel+/build
mkdir -p /lib/modules/5.15.0-handsomekernel+/source

dpkg -i /output/working/linux-headers-5.15.0-handsomekernel+_5.15.0-handsomekernel+-10.00.Custom_arm64.deb
dpkg -i /output/working/linux-image-5.15.0-handsomekernel+_5.15.0-handsomekernel+-10.00.Custom_arm64.deb

########################
# CONSOLE

mkdir -p /etc/systemd/system/serial-getty@ttyS0.service.d
cat <<EOF > /etc/systemd/system/serial-getty@ttyS0.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root -o '-p -- \\u' --keep-baud 115200,38400,9600 %I $TERM
EOF

########################
# FIRMWARE

# required wifi/vpu firmware; alternative is bulky: https://packages.debian.org/bullseye/firmware-qcom-soc ... and alternative: https://github.com/HandsomeMod/qcom-firmware
dpkg -i /output/working/linux-firmware-snapdragon_1.3-0ubuntu3_arm64.deb

########################
# ADBD & USB networking

# ADB daemon from https://github.com/hyx0329/openstick-failsafe-guard which was ripped from https://github.com/OpenStick/OpenStick/releases/download/v1/debian.zip, source not sure (alternative?: http://http.us.debian.org/debian/pool/main/a/android-tools/android-tools-adbd_5.1.1.r38-1.1_arm64.deb)
cp /output/working/openstick-failsafe-guard/bin/adbd-static /usr/bin/adbd && chmod +x /usr/bin/adbd

# gc tool from https://github.com/hyx0329/openstick-failsafe-guard which was ripped from https://github.com/OpenStick/OpenStick/releases/download/v1/debian.zip, source: https://github.com/HandsomeMod/gc
cp /output/working/openstick-failsafe-guard/bin/gc-static /usr/bin/gc && chmod +x /usr/bin/gc

# service bits from https://github.com/hyx0329/openstick-failsafe-guard
cp /output/working/openstick-failsafe-guard/openstick-gc-manager/openstick-gc-manager.sh /usr/sbin/ && chmod +x /usr/sbin/openstick-gc-manager.sh
cp /output/working/openstick-failsafe-guard/openstick-gc-manager/*.service /usr/lib/systemd/system/
ln -s /usr/lib/systemd/system/adbd.service /etc/systemd/system/multi-user.target.wants/adbd.service
ln -s /usr/lib/systemd/system/openstick-gc-startup.service /etc/systemd/system/multi-user.target.wants/openstick-gc-startup.service

# service bits from https://salsa.debian.org/Mobian-team/mobile-usb-networking
cp /output/working/mobile-usb-networking/mobile-usb-gadget /usr/sbin/ && chmod +x /usr/sbin/mobile-usb-gadget
cp /output/working/mobile-usb-networking/mobile-usb-network-setup /usr/sbin/ && chmod +x /usr/sbin/mobile-usb-network-setup
cp /output/working/mobile-usb-networking/debian/mobile-usb-networking.mobile-usb-gadget.service /usr/lib/systemd/system/mobile-usb-gadget.service
cp /output/working/mobile-usb-networking/debian/mobile-usb-networking.mobile-usb-network-setup.service /usr/lib/systemd/system/mobile-usb-network-setup.service
ln -s /usr/lib/systemd/system/mobile-usb-gadget.service /etc/systemd/system/multi-user.target.wants/mobile-usb-gadget.service
ln -s /usr/lib/systemd/system/mobile-usb-network-setup.service /etc/systemd/system/multi-user.target.wants/mobile-usb-network-setup.service

# DHCP server dnsmasq:
cat <<EOF >> /etc/dnsmasq.conf
listen-address=192.168.68.1
dhcp-range=192.168.68.10, 192.168.68.254, 12h
EOF

####

df -h /
