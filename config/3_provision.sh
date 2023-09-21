#! /bin/bash
set -ex

umount /rootfs || true
cp /output/working/rootfs_base.ext4 /output/rootfs.ext4
mount /output/rootfs.ext4 /rootfs


########################
# provision prep

mount --bind / /rootfs/mnt

mount --bind /proc /rootfs/proc 
mount --bind /dev /rootfs/dev # causes device busy
mount --bind /dev/pts /rootfs/dev/pts
mount --bind /sys /rootfs/sys

mkdir -p /rootfs/config
mkdir -p /rootfs/output
mount --bind /config /rootfs/config
mount --bind /output /rootfs/output

chroot /rootfs /bin/bash /config/provision.sh

########################
# boot.img

cat /output/working/Image.gz /output/working/msm8916-handsome-openstick-uz801.dtb > /output/working/kernel-dtb

mkbootimg \
    --base 0x80000000\
    --kernel_offset 0x00080000\
    --ramdisk_offset 0x02000000\
    --tags_offset 0x01e00000\
    --pagesize 2048\
    --second_offset 0x00f00000\
    --ramdisk /rootfs/boot/initrd.img-5.15.0-handsomekernel+\
    --cmdline "earlycon root=PARTUUID=a7ab80e8-e9d1-e8cd-f157-93f69b1d141e console=ttyMSM0,115200 no_framebuffer=true rw"\
    --kernel /output/working/kernel-dtb\
    -o /output/boot.img

########################

sync
sleep 5
umount -f /rootfs/* || true
umount -f /rootfs || true

sleep 5

## below seems to fail but image still works?

# losetup -d /dev/loop99 || true
# mknod -m 660 /dev/loop99 b 7 11 || true
# losetup -P /dev/loop99 /output/rootfs.ext4
# fsck -pf /dev/loop99
# echo y|sudo tune2fs -f -U a7ab80e8-e9d1-e8cd-f157-93f69b1d141e /dev/loop99
# losetup -d /dev/loop99

img2simg /output/rootfs.ext4 /output/rootfs.img

##

ls -la /output
