#! /bin/bash
set -ex

rm -rf /output/*; mkdir -p /output/working

# override kernel config
cp /config/msm8916_defconfig /linux/arch/arm64/configs/msm8916_defconfig

# compile
cd /linux
export CROSS_COMPILE=aarch64-linux-gnu-
export ARCH=arm64
make clean
make msm8916_defconfig
# make menuconfig
make -j16

# package kernel => .deb
fakeroot make-kpkg --initrd --cross-compile aarch64-linux-gnu- --arch arm64 kernel_image kernel_headers modules_image

# copy to working
cp /linux/arch/arm64/boot/Image.gz /output/working
cp /linux/arch/arm64/boot/dts/qcom/msm8916-handsome-openstick-uz801.dtb /output/working
cp /*.deb /output/working
