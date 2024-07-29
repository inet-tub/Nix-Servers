#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"
check_variables DRIVES RAID_LEVEL

check_zpool_status() {
    local pool_name="$1"

    if zpool status "$pool_name" > /dev/null 2>&1; then
        echo "ZFS pool '$pool_name' created successfully with $RAID_LEVEL"
        return 0
    else
        echo "Error: ZFS pool '$pool_name' not found or is unhealthy."
        return 1
    fi
}

if [ "$NUM_HOT_SPARES" -gt 0 ]; then
    check_variables HOT_SPARES
    spare_bpool="spare ${HOT_SPARES[@]/%/-part2}"
    spare_rpool="spare ${HOT_SPARES[@]/%/-part3}"
else
    spare_bpool=""
    spare_rpool=""
fi

echo -e "\n\nCreating boot pool ...\n"

zpool create \
    -o compatibility=grub2 \
    -o ashift=12 \
    -o autotrim=on \
    -O atime=off \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=lz4 \
    -O devices=off \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O com.sun:auto-snapshot=true \
    -O mountpoint=/boot \
    -R /mnt \
    "bpool" \
    "$RAID_LEVEL" \
    "${DRIVES[@]/%/-part2}" \
    $spare_bpool  # Splitting here is important, otherwise the array will be treated as a single element

check_zpool_status "bpool"
echo -e "\nCreating root pool ..."

zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O atime=off \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O com.sun:auto-snapshot=true \
    -O mountpoint=/ \
    -R /mnt \
    "rpool" \
    "$RAID_LEVEL" \
    "${DRIVES[@]/%/-part3}" \
    $spare_rpool

check_zpool_status "rpool"

zfs create -o canmount=off -o mountpoint=none "rpool/nixos"
zfs create -o mountpoint=legacy "rpool/nixos/root"
zfs create -o mountpoint=legacy "rpool/nixos/home"
zfs create -o mountpoint=legacy "rpool/nixos/var"
zfs create -o mountpoint=legacy "rpool/nixos/var/lib"
zfs create -o mountpoint=legacy "rpool/nixos/var/log"
zfs create -o mountpoint=none "bpool/nixos"
zfs create -o mountpoint=legacy "bpool/nixos/root"
zfs create -o mountpoint=legacy "rpool/nixos/empty"

mount -t zfs "rpool/nixos/root" "/mnt/"
mkdir "/mnt/home"
mkdir "/mnt/boot"
mount -t zfs "rpool/nixos/home" "/mnt/home"
mount -t zfs "bpool/nixos/root" "/mnt/boot"

zfs snapshot "rpool/nixos/empty@start"

for disk in "${DRIVES[@]}"; do
    mkdir -p /mnt/boot/efis/"${disk##*/}"-part1
    mount -t vfat -o iocharset=iso8859-1 "$disk"-part1 /mnt/boot/efis/"${disk##*/}"-part1
done
