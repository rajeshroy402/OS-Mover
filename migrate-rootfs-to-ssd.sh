#!/bin/bash
# =============================================================================
# Script Name: migrate-rootfs-to-ssd.sh
# Description: Migrates the root filesystem (/) from internal storage to an SSD
#              partition. It mounts the SSD, uses rsync to duplicate the
#              filesystem (excluding virtual directories), and updates extlinux.conf
#              to point to the new root.
#
# Author: Rajesh Roy
# Email:  rajeshroy402@gmail.com
# =============================================================================

# Ensure the script is run as root.
if [[ $(id -u) -ne 0 ]]; then
    echo "Error: You must run this script as root."
    exit 1
fi

# If a device name is passed as an argument, use it; otherwise default to /dev/nvme0n1p1.
if [[ -n "$1" ]]; then
    SSD_DEVICE="$1"
else
    SSD_DEVICE="/dev/nvme0n1p1"
fi

# Flag to control which extlinux.conf to update.
UPDATE_MOUNTED_EXTLINUX=false

# Validate the SSD device variable.
if [[ -z "$SSD_DEVICE" ]]; then
    echo "Error: SSD device path is not specified."
    exit 1
fi

# Check that the SSD device exists.
if [[ ! -e "$SSD_DEVICE" ]]; then
    echo "Error: SSD device $SSD_DEVICE not found."
    exit 1
fi

# Confirm that the SSD device is not already mounted.
if mount | grep -q "$SSD_DEVICE"; then
    echo "Error: $SSD_DEVICE is already mounted. Please unmount it and try again."
    exit 1
fi

# Mount the SSD partition temporarily at /mnt.
echo "Mounting $SSD_DEVICE at /mnt..."
mount "$SSD_DEVICE" /mnt || { echo "Error: Could not mount $SSD_DEVICE."; exit 1; }

# Use rsync to copy the root filesystem to the SSD.
echo "Copying root filesystem to SSD. This may take several minutes..."
rsync -axHAWX --numeric-ids --info=progress2 \
  --exclude={"/dev/","/proc/","/sys/","/tmp/","/run/","/mnt/","/media/*","/lost+found"} \
  / /mnt

# Ensure all data is written to disk.
sync
echo "Filesystem copy is complete."

echo -n "Current root parameter in extlinux.conf: "
grep "root=" /mnt/boot/extlinux/extlinux.conf

# Retrieve the current boot partition device as reported by df.
CURRENT_ROOT=$(df / | tail -1 | awk '{print $1}')

# Escape forward slashes for sed replacement.
ESCAPED_CURRENT_ROOT=$(echo "$CURRENT_ROOT" | sed 's/\//\\\//g')
ESCAPED_SSD_DEVICE=$(echo "$SSD_DEVICE" | sed 's/\//\\\//g')

# Update extlinux.conf to point to the new SSD root.
if [[ "$UPDATE_MOUNTED_EXTLINUX" == true ]]; then
    sed -i "s/root=$ESCAPED_CURRENT_ROOT/root=$ESCAPED_SSD_DEVICE/g" /mnt/boot/extlinux/extlinux.conf
else
    sed -i "s/root=$ESCAPED_CURRENT_ROOT/root=$ESCAPED_SSD_DEVICE/g" /boot/extlinux/extlinux.conf
    cp /boot/extlinux/extlinux.conf /mnt/boot/extlinux/extlinux.conf
fi

echo -n "Updated extlinux.conf (new root parameter): "
grep "root=" /mnt/boot/extlinux/extlinux.conf

echo "Update complete. Please reboot your system for the changes to take effect."
