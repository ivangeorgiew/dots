#!/usr/bin/env bash
# Script to install linux

# trigger error functions and pipes
set -Euo pipefail
shopt -s inherit_errexit failglob

# switch to root
if [[ "$(whoami)" != "root" ]]; then
    echo "Must be run as root!"
    exit
fi

# constants
FUNC_DESCR="unknown function"
CHROOT_DIR="/mnt/void"
BOOT_LABEL="VOID-BOOT"
SWAP_LABEL="void-swap"
ROOT_LABEL="void-root"
HOME_LABEL="void-home"

cleanup() {
    FUNC_DESCR="cleaning up"

    echo -e "\nCleaning up...\n"
    grep -qs "${CHROOT_DIR} " /proc/mounts && umount -R ${CHROOT_DIR}
}

# on interupt or exit
trap cleanup INT TERM HUP EXIT

catch() {
    echo " Issue at: ${FUNC_DESCR}"
    echo " Command: ${1}; Line: ${2}; Error Code: ${3}"
    read -rp "Should we proceed with the script? [y/n]: " should_proceed
    echo

    if [[ ${should_proceed} != "y" ]]; then
        exit "${3}"
    fi
}

# proper error handling
trap 'catch ${BASH_COMMAND} ${LINENO} ${?}' ERR

# write to shell and to logfile
exec > >(tee -a "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/linux-install.log") 2>&1

read_diskname() {
    FUNC_DESCR="choosing a disk"

    read -u 2 -rp "${1}" disk
    while ! [[ -b "/dev/${disk}" ]]; do
        read -u 2 -rp "Please enter a valid device: " disk
    done
    return "${disk}"
}

read_keyword() {
    FUNC_DESCR="entering a keyword"

    read -u 2 -rp "${1}" keyword
    while ! [[ ${keyword} =~ ^[a-zA-Z0-9_-]+$ ]]; do
        read -u 2 -rp "Please enter a valid keyword: " keyword
    done
    return "${keyword}"
}

read_secret() {
    FUNC_DESCR="entering a secret keyword"

    read -u 2 -srp "${1}" secret && echo 1>&2
    while ! [[ ${secret} =~ ^[a-zA-Z0-9_-]+$ ]]; do
        read -u 2 -srp "Please enter a valid secret keyword: " secret && echo 1>&2
    done
    return "${secret}"
}

welcome() {
    FUNC_DESCR="entering a secret keyword"

    # script must be run as root
    if [[ $(whoami) != "root" ]]; then
        echo "Rerun with root priviliges!"
        exit 1
    fi

    date "+%D %T"

    bla
    echo "Welcome to my Linux install script!"
}

partition() {
    FUNC_DESCR="partitioning"

    read -rp "Should we partition? [yes/no]: " should_partition
    [[ ${should_partition} != "yes" ]] && return 0
    echo -e "\nPartitioning...\n"

    lsblk -o name,label,size
    echo
    dev_to_part=$(read_diskname "Which disk to partition? [ex: sda]: ")
    echo "Make 1GB EFI, 10GB swap, rest root"
    read -srp "Press enter to continue..."
    echo
    cfdisk /dev/"${dev_to_part}"
}

format() {
    FUNC_DESCR="formating"

    read -rp "Should we format? [yes/no]: " should_format
    [[ ${should_format} != "yes" ]] && return 0
    echo -e "\nFormatting...\n"

    lsblk -o name,label,size
    echo

    boot_part=$(read_diskname "Enter BOOT partition [ex: sda1]: ")
    swap_part=$(read_diskname "Enter SWAP partition [ex: sda2]: ")
    root_part=$(read_diskname "Enter ROOT partition [ex: sda3]: ")
    home_part=$(read_diskname "Enter HOME partition [ex: sda4]: ")

    mkfs.vfat -n ${BOOT_LABEL} -F 32 /dev/"${boot_part}"
    mkswap -L ${SWAP_LABEL} /dev/"${swap_part}"
    mkfs.ext4 -L ${ROOT_LABEL} /dev/"${root_part}"
    mkfs.ext4 -L ${HOME_LABEL} /dev/"${home_part}"

    #re-read the partition disk
    blockdev --rereadpt /dev/"${dev_to_part}"
}

mount_disks() {
    FUNC_DESCR="mounting disks"

    echo -e "\nMounting disks...\n"

    [[ -d ${CHROOT_DIR} ]] || mkdir -rp ${CHROOT_DIR}
    grep -qs "${CHROOT_DIR} " /proc/mounts || \
        mount /dev/disk/by-label/${ROOT_LABEL} ${CHROOT_DIR}
    [[ -d "${CHROOT_DIR}/home" ]] || mkdir -rp ${CHROOT_DIR}/home
    grep -qs "${CHROOT_DIR}/home " /proc/mounts || \
        mount /dev/disk/by-label/${HOME_LABEL} ${CHROOT_DIR}/home
    [[ -d ${CHROOT_DIR}/boot/efi ]] || mkdir -rp ${CHROOT_DIR}/boot/efi
    grep -qs "${CHROOT_DIR}/boot/efi " /proc/mounts || \
        mount /dev/disk/by-label/${BOOT_LABEL} ${CHROOT_DIR}/boot/efi
}

download_linux() {
    FUNC_DESCR="downloading and extracting linux"

    echo -e "\nDownloading and extracting linux...\n"
    [[ -d "${CHROOT_DIR}/root" ]] && return 0

    XBPS_ARCH=x86_64 xbps-install -S -r ${CHROOT_DIR} -R \
        "https://alpha.de.repo.voidlinux.org/current" \
        base-system grub-x86_64-efi wifi-firmware linux-firmware
}

mount_dirs() {
    FUNC_DESCR="mounting subdirectories"

    echo -e "\nMounting subdirectories...\n"

    for folder in dev sys proc run sys/firmware/efi/efivars; do
        [[ -d ${CHROOT_DIR}/${folder} ]] || mkdir -rp ${CHROOT_DIR}/${folder}
        if ! grep -qs "${CHROOT_DIR}/${folder} " /proc/mounts; then
            mount -R --make-rslave /${folder} ${CHROOT_DIR}/${folder}
        fi
    done
}

chrooting() {
    FUNC_DESCR="executing chroot commands and modifying files"

    read -rp "Should we chroot and modify? [yes/no]: " should_chroot
    [[ ${should_chroot} != "yes" ]] && return 0

    echo -e "\nCreating a new user...\n"
    username=$(read_keyword "Enter username: ")
    pass1=$(read_secret "Enter password: ")
    pass2=$(read_secret "Repeat password: ")
    while [[ ${pass1} != [[${pass2}]] ]]; do
        pass1=$(read_secret "Passwords don't match or incorrect. Enter password: ")
        pass2=$(read_secret "Repeat password: ")
    done
    if id "${username}" &> /dev/null; then
        chroot ${CHROOT_DIR} useradd -m -g users -G wheel,input,video,disk,audio,kvm -s /bin/bash "${username}" && \
                             yes "${pass1}" | passwd "${username}" &> /dev/null
        echo "User ${username} created !!!"
        unset pass1 pass2
    fi

    echo -e "\nModifying resolv.conf for internet...\n"
    cat > ${CHROOT_DIR}/etc/resolv.conf <<- EOF
    nameserver 1.1.1.1
    nameserver 1.0.0.1
EOF

    # chroot ${CHROOT_DIR} chown root:root / && \
    #                      chmod 755 / && \
    #                      passwd -dl root

    # echo "Updating linux..."
    # xbps-install -Syu xbps void-repo-nonfree
    # xbps-install -Syu

    # echo "Installing base packages..."
    # xbps-install -Sy base-system grub-x86_64-efi wifi-firmware linux-firmware git
    # xbps-query -s base-voidstrap | grep -qs "voidstrap" && xbps-remove -y base-voidstrap

    # echo "Installing GRUB..."
    # grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=void_grub --boot-directory=/boot

    # echo "Installing cpu microcode.."
    # if $(cat /proc/cpuinfo | grep -qs "GenuineIntel"); then
    #     xbps-install -Sy intel-ucode
    #     if $(cat /etc/dracut.conf.d/intel_ucode.conf | grep -qs "early_microcode=yes"); then
    #         echo 'early_microcode="yes"' >> /etc/dracut.conf.d/intel_ucode.conf
    #     fi
    # else
    #     xbps-install -Sy linux-firmware-amd
    # fi

    # echo "Removing old kernels..."
    # vkpurge rm all

    # echo "Reconfiguring files..."
    # xbps-reconfigure -fa

    # echo "Setup runit services..."
    # rm -f /etc/runit/runsvdir/default/agetty-tty{4,5,6}
    # ln -sf /etc/sv/dhcpcd /etc/runit/runsvdir/default/
}

modify_files() {
    FUNC_DESCR="modifying configuration files"

    read -rp "Should we modify the config files? [yes/no]: " should_modify
    [[ ${should_modify} != "yes" ]] && return 0
    echo -e "\nModifying config files...\n"

    echo "mahcomp" > ${CHROOT_DIR}/etc/hostname

    echo "en_US.UTF-8 UTF-8" > ${CHROOT_DIR}/etc/default/libc-locales

    sed -Ei 's/^.*HARDWARECLOCK=.*/HARDWARECLOCK="UTC"/g' ${CHROOT_DIR}/etc/rc.conf
    sed -Ei 's/^.*TIMEZONE=.*/TIMEZONE="Europe/Sofia"/g' ${CHROOT_DIR}/etc/rc.conf
    sed -Ei 's/^.*KEYMAP=.*/KEYMAP="dvorak"/g' ${CHROOT_DIR}/etc/rc.conf

    sed -Ei "s/^.*(%wheel.*NOPASSWD.*)/\1/g" ${CHROOT_DIR}/etc/sudoers

    sed -Ei 's/^.*(GRUB_TIMEOUT).*$/\1=2/g' ${CHROOT_DIR}/etc/default/grub
    sed -Ei 's/^.*(GRUB_CMDLINE_LINUX).*"$/\1="splash quiet i915.modeset=1"/g' ${CHROOT_DIR}/etc/default/grub

    cat ${CHROOT_DIR}/etc/dhcpcd.conf | grep -qs "nohook resolv.conf" || echo "nohook resolv.conf" >> ${CHROOT_DIR}/etc/dhcpcd.conf

    sed -Ei "s/^(.*)GETTY_ARGS=\".*\"/\1GETTY_ARGS=\"--autologin ${username} --noclear\"/g" ${CHROOT_DIR}/etc/runit/runsvdir/default/agetty-tty1/conf

    cat > ${CHROOT_DIR}/etc/fstab <<- EOF
    LABEL="${BOOT_LABEL}"  /boot/efi    vfat        defaults,discard        0       2
    LABEL="${SWAP_LABEL}"  swap         swap        defaults,discard        0       0
    LABEL="${ROOT_LABEL}"  /            ext4        defaults,discard        0       1
    tmpfs                  /tmp         tmpfs       defaults,nosuid,nodev   0       0
EOF

    cat > ${CHROOT_DIR}/etc/dracut.conf <<- EOF
    hostonly="yes"
    add_dracutmodules+="resume"
    tmpdir=/tmp
EOF

    cat > ${CHROOT_DIR}/etc/grub.d/40_custom <<- 'EOF'
    #Copy to /etc/grub.d/40_custom
    exec tail -n +3 $0
    # Dont change the 'exec tail' line aove.
    # SET THE LABEL WIN_BOOT FOR THE PARTITION FROM WHICH WINDOWS BOOTS
    menuentry "Windows 10" --class windows --class os {
        search --no-floppy --set=root --label WIN_BOOT
        chainloader (${root})/EFI/Microsoft/Boot/bootmgfw.efi
    }
EOF
}

welcome
