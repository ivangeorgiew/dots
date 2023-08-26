#!/usr/bin/env bash
# Setup disk layout before installing Linux

# trigger error functions and pipes
set -Euo pipefail
shopt -s inherit_errexit failglob
#IFS=$'\n\t'

# switch to root
if [[ "$(whoami)" != "root" ]]; then
    echo "Must be run as root!"
    exit
fi

FUNC_NAME="unknown"
MOUNT_DIR="/mnt"
BOOT_LABEL="NIX_BOOT"
SWAP_LABEL="NIX_SWAP"
ROOT_LABEL="NIX_ROOT"

cleanup() {
    echo -e "\nCleanup Step\n"

    grep -qs "${MOUNT_DIR} " /proc/mounts && umount -R ${MOUNT_DIR}

    if cat /proc/swaps | grep -qs "/dev/"; then
        swapoff /dev/disk/by-label/${SWAP_LABEL}
    fi
}

# on interupt or exit
trap cleanup INT TERM HUP

catch() {
    cleanup

    echo "| Issue at: ${FUNC_NAME}"
    echo "| Line: ${1} | Error Code: ${2}"
    echo "| Command: ${BASH_COMMAND}"

    exit "${2}"
}

# proper error handling
trap 'catch ${LINENO} ${?}' ERR

read_diskname() {
    FUNC_NAME="read_diskname"

    read -u 2 -rp "${1}" disk
    while ! [[ -b "/dev/${disk}" ]]; do
        read -u 2 -rp "Please enter a valid device: " disk
    done

    echo "${disk}"
}

setup_disk() {
    FUNC_NAME="setup_disk"

    lsblk -o name,label,size
    echo

    dev_to_part=$(read_diskname "Select disk [ex: sda]: ")

    read -rp "Should we partition? [yes/no]: " should_partition

    if [[ ${should_partition} == "yes" ]]; then
        echo -e "\nPartitioning Step\n"

        echo "Make 1GB EFI, (RAM/2)GB swap, rest root"
        read -srp "Press enter to continue..."
        echo

        cfdisk /dev/"${dev_to_part}"
    fi

    read -rp "Should we format? [yes/no]: " should_format

    if [[ ${should_format} == "yes" ]]; then
        echo -e "\nFormatting Step\n"

        lsblk -o name,label,size
        echo

        boot_part=$(read_diskname "Enter BOOT partition [ex: sda1]: ")
        swap_part=$(read_diskname "Enter SWAP partition [ex: sda2]: ")
        root_part=$(read_diskname "Enter ROOT partition [ex: sda3]: ")

        mkfs.vfat -n ${BOOT_LABEL} -F 32 /dev/"${boot_part}"
        mkswap -L ${SWAP_LABEL} /dev/"${swap_part}"
        mkfs.btrfs -f -L ${ROOT_LABEL} /dev/"${root_part}"

        #re-read the disk
        partprobe /dev/"${dev_to_part}"
    fi
}

mount_disk() {
    FUNC_NAME="mount_disk"

    echo -e "\nMounting Step\n"

    # unmount just in case
    grep -qs "${MOUNT_DIR} " /proc/mounts && umount -R ${MOUNT_DIR}

    # enable swap
    if ! cat /proc/swaps | grep -qs "/dev/"; then
        swapon /dev/disk/by-label/${SWAP_LABEL}
    fi

    # mount root
    [[ -d ${MOUNT_DIR} ]] || mkdir -p ${MOUNT_DIR}
    grep -qs "${MOUNT_DIR} " /proc/mounts || \
        mount -t btrfs /dev/disk/by-label/${ROOT_LABEL} ${MOUNT_DIR}

    # create btrfs subvolumes
    if ! btrfs subvolume list /mnt | grep -qs "@home"; then
        btrfs subvolume create ${MOUNT_DIR}/@root
        btrfs subvolume create ${MOUNT_DIR}/@home
        btrfs subvolume create ${MOUNT_DIR}/@nix
    fi

    # unmount
    grep -qs "${MOUNT_DIR} " /proc/mounts && umount -R ${MOUNT_DIR}

    mount_opts="compress-force=zstd,commit=60,noatime,ssd,nodiscard"

    # mount root
    mount -o ${mount_opts},subvol=@root /dev/disk/by-label/${ROOT_LABEL} ${MOUNT_DIR}

    # create folders
    [[ -d ${MOUNT_DIR}/home ]] || mkdir -p ${MOUNT_DIR}/home
    [[ -d ${MOUNT_DIR}/nix ]] || mkdir -p ${MOUNT_DIR}/nix
    [[ -d ${MOUNT_DIR}/boot ]] || mkdir -p ${MOUNT_DIR}/boot

    # mount everything else
    mount -o ${mount_opts},subvol=@home /dev/disk/by-label/${ROOT_LABEL} ${MOUNT_DIR}/home
    mount -o ${mount_opts},subvol=@nix /dev/disk/by-label/${ROOT_LABEL} ${MOUNT_DIR}/nix
    mount /dev/disk/by-label/${BOOT_LABEL} ${MOUNT_DIR}/boot
}

install_nix() {
    FUNC_NAME="install_nix"

    echo -e "\nInstall Step\n"

    nixos-install --no-root-passwd --flake "github:ivangeorgiew/dotfiles?dir=nix#mahcomp"
}

# Execution
setup_disk
mount_disk
install_nix
