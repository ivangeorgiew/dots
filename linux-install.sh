#!/bin/bash
# A script to install linux by Ivan Georgiev

# switch to root
if [[ "$(whoami)" != "root" ]]; then
    sudo su -s "$0"
    exit
fi

# trigger error functions and pipes
set -Euo pipefail
shopt -s inherit_errexit failglob

# write to shell and to logfile
exec > >(tee "linux-install.log") 2>&1

# constants
func_descr="doing something"
chroot_dir="/mnt/inst"
boot_label="BOOT"
swap_label="swap"
root_label="root"
home_label="home"

cleanup() {
    func_descr="cleaning up"
    echo -e "\nCleaning up...\n"
    grep -qs "${chroot_dir} " /proc/mounts && umount -R ${chroot_dir}

    return 0
}

catch() {
    echo "Issue with ${func_descr}:"
    echo "  command \"${3}\" failed with error code ${1} at line ${2}"

    read -p "Should we proceed with the script? [yes/no]: " should_proceed
    if [[ ${should_proceed} != "yes" ]]; then
        cleanup
        exit ${2}
    else
        echo
    fi
    return 0
}

trap 'catch ${?} ${LINENO} ${BASH_COMMAND}' ERR

# reused functions
read_diskname() {
    func_descr="choosing a disk"
    read -u 2 -p "${1}" disk
    while ! [[ -b "/dev/${disk}" ]]; do
        read -u 2 -p "Please enter a valid device: " disk
    done
    return "${disk}"
}

read_keyword() {
    func_descr="entering a keyword"
    read -u 2 -p "${1}" keyword
    while ! [[ ${keyword} =~ ^[a-zA-Z0-9_-]+$ ]]; do
        read -u 2 -p "Please enter a valid keyword: " keyword
    done
    return "${keyword}"
}

read_secret() {
    func_descr="entering a secret keyword"
    read -u 2 -sp "${1}" secret && echo 1>&2
    while ! [[ ${secret} =~ ^[a-zA-Z0-9_-]+$ ]]; do
        read -u 2 -sp "Please enter a valid secret keyword: " secret && echo 1>&2
    done
    return "${secret}"
}

# Actual beginning of the script
echo -e "\nWelcome to my linux installation script!"

cleanup

partition() {
    func_descr="partitioning"
    read -p "Should we partition? [yes/no]: " should_partition
    [[ ${should_partition} != "yes" ]] && return 0
    echo -e "\nPartitioning...\n"

    lsblk -o name,label,size
    echo
    dev_to_part=`read_diskname "Which disk to partition? [ex: sda]: "`
    echo "Make 1GB EFI, 12GB swap, 30GB root, rest home."
    read -sp "Press enter to continue..."
    echo
    cfdisk /dev/${dev_to_part}

    return 0
} && partition

format() {
    func_descr="formating"
    read -p "Should we format? [yes/no]: " should_format
    [[ ${should_format} != "yes" ]] && return 0
    echo -e "\nFormatting...\n"

    lsblk -o name,label,size
    echo
    boot_part=`read_diskname "Enter BOOT partition [ex: sda1]: "`
    mkfs.vfat -n ${boot_label} -F 32 /dev/${boot_part}
    swap_part=`read_diskname "Enter SWAP partition [ex: sda2]: "`
    mkswap -L ${swap_label} /dev/${swap_part}
    root_part=`read_diskname "Enter ROOT partition [ex: sda3]: "`
    mkfs.ext4 -L ${root_label} /dev/${root_part}
    home_part=`read_diskname "Enter HOME partition [ex: sda4]: "`
    mkfs.ext4 -L ${home_label} /dev/${home_part}
    #re-read the partition disk
    blockdev --rereadpt /dev/${dev_to_part}

    return 0
} && format

mount_disks() {
    func_descr="mounting disks"
    echo -e "\nMounting disks...\n"

    [[ -d ${chroot_dir} ]] || mkdir -p ${chroot_dir}
    grep -qs "${chroot_dir} " /proc/mounts || \
        mount /dev/disk/by-label/${root_label} ${chroot_dir}
    [[ -d "${chroot_dir}/home" ]] || mkdir -p ${chroot_dir}/home
    grep -qs "${chroot_dir}/home " /proc/mounts || \
        mount /dev/disk/by-label/${home_label} ${chroot_dir}/home
    [[ -d ${chroot_dir}/boot/efi ]] || mkdir -p ${chroot_dir}/boot/efi
    grep -qs "${chroot_dir}/boot/efi " /proc/mounts || \
        mount /dev/disk/by-label/${boot_label} ${chroot_dir}/boot/efi

    return 0
} && mount_disks

download_linux() {
    func_descr="downloading and extracting linux"
    echo -e "\nDownloading and extracting linux...\n"
    [[ -d "${chroot_dir}/root" ]] && return 0

    XBPS_ARCH=x86_64 xbps-install -S -r ${chroot_dir} -R \
        "https://alpha.de.repo.voidlinux.org/current" \
        base-system grub-x86_64-efi wifi-firmware linux-firmware

    return 0
} && download_linux

mount_dirs() {
    func_descr="mounting subdirectories"
    echo -e "\nMounting subdirectories...\n"

    for folder in dev sys proc; do
        [[ -d ${chroot_dir}/${folder} ]] || mkdir -p ${chroot_dir}/${folder}
        if ! $(grep -qs "${chroot_dir}/${folder} " /proc/mounts); then
            mount -R --make-rslave /${folder} ${chroot_dir}/${folder}
        fi
    done

    return 0
} && mount_dirs

creating_user() {
    func_descr="choosing username and password"
    read -p "Should we create a user? [yes/no]: " should_create_user
    [[ ${should_create_user} != "yes" ]] && return 0
    echo -e "\nCreating a user...\n"

    username=`read_keyword "Enter username: "`
    pass1=`read_secret "Enter password: "`
    pass2=`read_secret "Repeat password: "`

    while [[ ${pass1} != ${pass2} ]]; do
        pass1=`read_secret "Passwords don't match or incorrect. Enter password: "`
        pass2=`read_secret "Repeat password: "`
    done

    return 0
} && creating_user

chrooting() {
    func_descr="executing chroot commands"
    echo -e "\nExecuting chroot commands...\n"

    if $(id ${username} &> /dev/null); then
        useradd -m -g users -G wheel,input,video,disk,audio,kvm -s /bin/bash "${username}"
        yes ${pass1} | passwd ${username} &> /dev/null
    fi

    chown root:root /
    chmod 755 /
    passwd -dl root

    echo "Updating linux..."
    xbps-install -Syu xbps void-repo-nonfree
    xbps-install -Syu

    echo "Installing base packages..."
    xbps-install -Sy base-system grub-x86_64-efi wifi-firmware linux-firmware git
    xbps-query -s base-voidstrap | grep -qs "voidstrap" && xbps-remove -y base-voidstrap

    echo "Installing GRUB..."
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=void_grub --boot-directory=/boot

    echo "Installing cpu microcode.."
    if $(cat /proc/cpuinfo | grep -qs "GenuineIntel"); then
        xbps-install -Sy intel-ucode
        if $(cat /etc/dracut.conf.d/intel_ucode.conf | grep -qs "early_microcode=yes"); then
            echo 'early_microcode="yes"' >> /etc/dracut.conf.d/intel_ucode.conf
        fi
    else
        xbps-install -Sy linux-firmware-amd
    fi

    echo "Removing old kernels..."
    vkpurge rm all

    echo "Reconfiguring files..."
    xbps-reconfigure -fa

    echo "Setup runit services..."
    rm -f /etc/runit/runsvdir/default/agetty-tty{4,5,6}
    ln -sf /etc/sv/dhcpcd /etc/runit/runsvdir/default/

    return 0
} && chrooting

modify_files() {
    func_descr="modifying configuration files"
    read -p "Should we modify the config files? [yes/no]: " should_modify
    [[ ${should_modify} != "yes" ]] && return 0
    echo -e "\nModifying config files...\n"

    echo "mahcomp" > ${chroot_dir}/etc/hostname

    echo "en_US.UTF-8 UTF-8" > ${chroot_dir}/etc/default/libc-locales

    sed -Ei 's/^.*HARDWARECLOCK=.*/HARDWARECLOCK="UTC"/g' ${chroot_dir}/etc/rc.conf
    sed -Ei 's/^.*TIMEZONE=.*/TIMEZONE="Europe/Sofia"/g' ${chroot_dir}/etc/rc.conf
    sed -Ei 's/^.*KEYMAP=.*/KEYMAP="dvorak"/g' ${chroot_dir}/etc/rc.conf

    sed -Ei "s/^.*(%wheel.*NOPASSWD.*)/\1/g" ${chroot_dir}/etc/sudoers

    sed -Ei 's/^.*(GRUB_TIMEOUT).*$/\1=2/g' ${chroot_dir}/etc/default/grub
    sed -Ei 's/^.*(GRUB_CMDLINE_LINUX).*"$/\1="splash quiet i915.modeset=1"/g' ${chroot_dir}/etc/default/grub

    cat ${chroot_dir}/etc/dhcpcd.conf | grep -qs "nohook resolv.conf" || echo "nohook resolv.conf" >> ${chroot_dir}/etc/dhcpcd.conf

    sed -Ei 's/^(.*)GETTY_ARGS=".*"/\1GETTY_ARGS="--autologin ${username} --noclear"/g' ${chroot_dir}/etc/runit/runsvdir/default/agetty-tty1/conf

    cat > ${chroot_dir}/etc/resolv.conf <<- EOF
    nameserver 1.1.1.1
    nameserver 1.0.0.1
EOF

    cat > ${chroot_dir}/etc/fstab <<- EOF
    LABEL="${boot_label}"  /boot/efi    vfat        defaults,discard        0       2
    LABEL="${swap_label}"  swap         swap        defaults,discard        0       0
    LABEL="${root_label}"  /            ext4        defaults,discard        0       1
    tmpfs                  /tmp         tmpfs       defaults,nosuid,nodev   0       0
EOF

    cat > ${chroot_dir}/etc/dracut.conf <<- EOF
    hostonly="yes"
    add_dracutmodules+="resume"
    tmpdir=/tmp
EOF

    cat > ${chroot_dir}/etc/grub.d/40_custom <<- 'EOF'
    #Copy to /etc/grub.d/40_custom
    exec tail -n +3 $0
    # Dont change the 'exec tail' line aove.
    # SET THE LABEL WIN_BOOT FOR THE PARTITION FROM WHICH WINDOWS BOOTS
    menuentry "Windows 10" --class windows --class os {
        search --no-floppy --set=root --label WIN_BOOT
        chainloader (${root})/EFI/Microsoft/Boot/bootmgfw.efi
    }
EOF

    return 0
} && modify_files

cleanup
