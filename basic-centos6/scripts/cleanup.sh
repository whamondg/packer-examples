#!/bin/bash -eux

echo "==> Cleaning up temporary network addresses"
# Make sure udev doesn't block our network
rm -rf /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm /lib/udev/rules.d/75-persistent-net-generator.rules

rm -rf /dev/.udev/
if [ -f /etc/sysconfig/network-scripts/ifcfg-eth0 ] ; then
    sed -i "/^HWADDR/d" /etc/sysconfig/network-scripts/ifcfg-eth0
    sed -i "/^UUID/d" /etc/sysconfig/network-scripts/ifcfg-eth0
fi

echo "==> Removing temporary files used to build box"
rm -rf /tmp/*
yum -y clean all
rm -rf VBoxGuestAdditions*.iso

echo '==> Zeroing out empty area to save space in the final image'
# Contiguous zeroed space compresses down to nothing.
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync