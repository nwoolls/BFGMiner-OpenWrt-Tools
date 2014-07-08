#!/bin/sh

# OpenWrt Image Builder image should be located in ~/openwrt-imagebuilder
# Also expects ./cross-compile-bfgminer.sh

# set these
bfgminer_version="4.3.0"
image_version="pr3"

# not these
full_version="v${bfgminer_version}-${image_version}"
image_output_dir="${HOME}/openwrt-imagebuilder/bin/ar71xx"
base_dir=$(dirname $0)

"${base_dir}/cross-compile-bfgminer.sh"
cd "${HOME}/openwrt-imagebuilder"
rm -rf tmp && make image PROFILE=TLWR703 PACKAGES="libcurl libpthread jansson libusb-1.0 kmod-usb-serial kmod-usb-serial-cp210x kmod-usb-serial-ftdi kmod-usb-acm -kmod-gpio-button-hotplug hotplug2 -dnsmasq -uboot-envtools -6relayd -libgcc -libc -firewall -iptables -ip6tables -swconfig -ppp -ppp-mod-pppoe -kmod-ipt-nathelper -kmod-ledtrig-netdev libncurses screen" FILES=files/

mv "${image_output_dir}/openwrt-ar71xx-generic-tl-wr703n-v1-squashfs-factory.bin" "${image_output_dir}/bfgminer-ar71xx-generic-tl-wr703n-${full_version}-squashfs-factory.bin"
mv "${image_output_dir}/openwrt-ar71xx-generic-tl-wr703n-v1-squashfs-sysupgrade.bin" "${image_output_dir}/bfgminer-ar71xx-generic-tl-wr703n-${full_version}-squashfs-sysupgrade.bin"
