# OpenStick Builder

Inspired by cheap MSM8916 4G USB dongles that run Linux, and the effort put into [OpenStick](https://github.com/OpenStick/OpenStick).

This repo contains a Dockerfile which aims to make it easier to build and customise OpenStick images for MSM8916 4G USB dongles.

## Quickstart

### Dependencies

What I built this using:

- Ubuntu 22.04
- ...?

### Build:

See comments in the files.

Build:
```
docker build --tag openstick .
docker run --privileged -v $(pwd)/config:/config:ro -v $(pwd)/output:/output openstick /bin/bash /config/1_kernel.sh
docker run --privileged -v $(pwd)/config:/config:ro -v $(pwd)/output:/output openstick /bin/bash /config/2_rootfs.sh
docker run --privileged -v $(pwd)/config:/config:ro -v $(pwd)/output:/output openstick /bin/bash /config/3_provision.sh
```

### Build Output (./output/)
| file | description |
| - | - |
| boot.img | Debian boot image |
| rootfs.img | Debian rootfs image (fastboot format) |
| rootfs.ext4 | Debian rootfs image (raw EXT4) |

### Flash Device:

1. Fresh devices need to have their non-rootfs partitions flashed using the OpenStick process https://www.kancloud.cn/handsomehacker/openstick/2636506 (Chinese - loosely transalted at https://extrowerk.com/2022-07-31/OpenStick.html):
    - download & extract https://github.com/OpenStick/OpenStick/releases/download/v1/base-generic.zip
    - plug in device - this should present a RNDIS network interface
    - enable the devices usb debug mode (i.e. allowing adb) by hitting this in your browser: http://192.168.100.1/usbdebug.html
    - put device into fastboot mode:
        ```
        adb devices
        adb reboot bootloader
        fastboot devices
        ```
    - flash:
        ```
        base/flash.sh
        ```

2. Flash your freshly built boot partition & kernel/rootfs:
    ```
    fastboot flash boot output/boot.img
    fastboot -S 200M flash rootfs output/rootfs.img
    fastboot reboot
    ```

### To Connect:
```
adb shell
```

## Un-Bricking

The MSM8916 4G USB dongle I was using was a UZ801 coded version, which provides a number of solder pads along one side of the board. Shorting 2 of them during bootup forces the device into EDL mode, where it can be imaged using https://github.com/bkerler/edl - you can easily solder a small push-button which makes it a lot easier if you find yourself resorting to recovery repeatedly. Two of the others are TTL level RX/TX pins making it easy to view the boot log to see where it all goes wrong. All this and links to clean images to recover the device back to standard can be found at https://forum.openwrt.org/t/uf896-qualcomm-msm8916-lte-router-384mib-ram-2-4gib-flash-android-openwrt/131712/82.

## Future Plans

The inital motivation for this repo was to have a repeatable build system for producing the Debian-based OS images that [OpenStick](https://github.com/OpenStick/OpenStick) provided as a release image, so this could be customised and/or extended to cater for other use cases. One such use case would be to present the stick as a USB mass storage device, and sync whatever was written to it by the host device up to cloud-based storage (i.e. OneDrive) over WIFI or 4G (something similar to what [teslausb](https://github.com/marcone/teslausb) achieves, however this requires a re-partition of the device using clues from [here](https://github.com/96boards/documentation/blob/master/consumer/dragonboard/dragonboard410c/guides/customize-emmc-partition.md)). Ping me if you put the effort in to make it work =)

## Credits

- https://github.com/OpenStick/linux
- https://www.kancloud.cn/handsomehacker/openstick/2637565
- https://github.com/hyx0329/openstick-failsafe-guard
- https://salsa.debian.org/Mobian-team/mobile-usb-networking