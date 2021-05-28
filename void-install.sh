#!/bin/bash
# A script to install Void Linux by Ivan Georgiev
if [[ "$(whoami)" != "root" ]]; then
    sudo su -s "$0"
    exit
fi

echo "Welcome to the Void-linux installation script!"

# trigger error functions and pipes
set -Euo pipefail
shopt -s inherit_errexit failglob

# trap all errors
trap 'catch ${?} ${LINENO}' ERR
has_error=false

# show errors info
catch() {
    has_error=true
    if [[ ${2} -ne 28 && ${2} -ne 33 ]]; then
        echo "Error with code ${1} at line ${2}" >&2
    fi
}

# call functions with error handling
call() {
    (set -e; ${1};)
    while [[ $has_error == true ]]; do
        read -p "How to proceed? [1) retry; 2) exit; 3) continue]: " should_retry
        has_error=false
        if [[ ${should_retry} =~ ^\s*[1] ]]; then
            (set -e; ${1};)
        elif [[ ${should_retry} =~ ^\s*[2] ]]; then
            exit 1
        fi
    done
}

boot_label="VOID-BOOT"
swap_label="void-swap"
root_label="void-root"

read_diskname() {
    read -u 2 -p "${1}" disk
    while ! [[ -b "/dev/${disk}" ]]; do
        read -u 2 -p "Please enter a valid device: " disk
    done
    return "${disk}"
}

read_keyword() {
    read -u 2 -p "${1}" keyword
    while ! [[ ${keyword} =~ ^[a-zA-Z0-9_-]+$ ]]; do
        read -u 2 -p "Please enter a valid keyword: " keyword
    done
    return "${keyword}"
}

read_secret() {
    read -u 2 -sp "${1}" secret && echo 1>&2
    while ! [[ ${secret} =~ ^[a-zA-Z0-9_-]+$ ]]; do
        read -u 2 -sp "Please enter a valid secret keyword: " secret && echo 1>&2
    done
    return "${secret}"
}

partition() {
    echo -e "\n...Partitioning..."
    read -p "Should we partition? [y/N]: " should_partition
    [[ ! ${should_partition} =~ ^\s*[yY] ]] && return 0
    echo
    lsblk -o name,label,size
    echo
    dev_to_part=`read_diskname "Which disk to partition? [ex: sda]: "`
    echo
    read -sp "Make EFI, swap and root. Press enter to continue..."
    echo
    cfdisk /dev/${dev_to_part}
} && call partition

format() {
    echo -e "\n...Formatting..."
    read -p "Should we format? [y/N]: " should_format
    [[ ! ${should_format} =~ ^\s*[yY] ]] && return 0
    echo
    lsblk -o name,label,size
    echo
    boot_part=`read_diskname "Enter BOOT partition [ex: sda1]: "`
    mkfs.vfat -n ${boot_label} -F 32 /dev/${boot_part}
    swap_part=`read_diskname "Enter SWAP partition [ex: sda2]: "`
    mkswap -L ${swap_label} /dev/${swap_part}
    root_part=`read_diskname "Enter ROOT partition [ex: sda3]: "`
    mkfs.ext4 -L ${root_label} /dev/${root_part}
    #re-read the partition disk
    blockdev --rereadpt /dev/${dev_to_part}
} && call format

mount_disks() {
    echo -e "\n...Mounting disks..."
    [[ -d /mnt/void ]] || mkdir -p /mnt/void
    grep -qs "/mnt/void " /proc/mounts || \
        mount /dev/disk/by-label/${root_label} /mnt/void
    [[ -d /mnt/void/boot/efi ]] || mkdir -p /mnt/void/boot/efi
    grep -qs "/mnt/void/boot/efi " /proc/mounts || \
        mount /dev/disk/by-label/${boot_label} /mnt/void/boot/efi
} && call mount_disks

download_void() {
    [[ -d "/mnt/void/root" ]] && return 0
    echo "...Downloading and extracting voidlinux..."
    XBPS_ARCH=x86_64 xbps-install -S -r /mnt/void -R \
        "https://alpha.de.repo.voidlinux.org/current" \
        base-system grub-x86_64-efi wifi-firmware linux-firmware
} && call download_void

mount_dirs() {
    echo -e "...Mounting subdirectories...\n"
    for folder in dev sys proc; do
        [[ -d /mnt/void/${folder} ]] || mkdir -p /mnt/void/${folder}
        if ! $(grep -qs "/mnt/void/${folder}" /proc/mounts); then
            mount -R --make-rslave /${folder} /mnt/void/${folder}
        fi
    done
} && call mount_dirs

<< 'COMMENT'
### CHROOT AND INSTALL ###
export boot_label swap_label root_label
export -f read_keyword read_secret

# Must escape(\) the characters \, $, `
# where we don't want to use expansion
chroot /mnt/void /bin/bash 1> /dev/null << 'CHR'
set -E
trap 'echo -e "Error ${?} at line ${LINENO}\n" >&2 && exit 1' ERR

echo -e "Modifying config files...\n" 1>&2

cat > /etc/resolv.conf << 'EOL'
nameserver 1.1.1.1
nameserver 1.0.0.1
EOL

echo "mahcomp" > /etc/hostname

echo "en_US.UTF-8 UTF-8" > /etc/default/libc-locales

sed -Ei 's/^.*HARDWARECLOCK=.*/HARDWARECLOCK="UTC"/g' /etc/rc.conf
sed -Ei 's/^.*TIMEZONE=.*/TIMEZONE="Europe/Sofia"/g' /etc/rc.conf
sed -Ei 's/^.*KEYMAP=.*/KEYMAP="dvorak"/g' /etc/rc.conf

cat > /etc/fstab << EOL
LABEL="${boot_label}"  /boot/efi    vfat        defaults,discard        0       2
LABEL="${swap_label}"  swap         swap        defaults,discard        0       0
LABEL="${root_label}"  /            ext4        defaults,discard        0       1
tmpfs                  /tmp         tmpfs       defaults,nosuid,nodev   0       0
EOL

cat > /etc/dracut.conf << EOL
hostonly="yes"
add_dracutmodules+="resume"
tmpdir=/tmp
EOL

echo -e "User management..." 1>&2
username=`read_keyword "Enter username: "`

if ! id -u ${username} &> /dev/null; then
    pass1=`read_secret "Enter password: "`
    pass2=`read_secret "Repeat password: "`
    while [[ ${pass1} != ${pass2} ]]; do
        pass1=`read_secret "Passwords don't match or incorrect. Enter password: "`
        pass2=`read_secret "Repeat password: "`
    done
    useradd -m -g users -G wheel,input,video,disk,audio,kvm -s /bin/bash "${username}"
    yes ${pass1} | passwd ${username} &> /dev/null
    unset pass1 pass2
fi

chown root:root /
chmod 755 /
sed -Ei "s/^.*(%wheel.*NOPASSWD.*)/\1/g" /etc/sudoers
passwd -dl root

echo -e "\nUpdating void...\n" 1>&2
xbps-install -Syu xbps void-repo-nonfree
xbps-install -Syu

echo -e "Installing base packages...\n" 1>&2
xbps-install -Sy base-system grub-x86_64-efi wifi-firmware linux-firmware
xbps-query -s base-voidstrap | grep -qs "voidstrap" && xbps-remove -y base-voidstrap

echo -e "Installing GRUB..." 1>&2
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=void_grub --boot-directory=/boot

cat > /etc/grub.d/40_custom << 'EOL'
#Copy to /etc/grub.d/40_custom
exec tail -n +3 $0
# Dont change the 'exec tail' line aove.
# SET THE LABEL WIN_BOOT FOR THE PARTITION FROM WHICH WINDOWS BOOTS
menuentry "Windows 10" --class windows --class os {
	search --no-floppy --set=root --label WIN_BOOT
	chainloader (${root})/EFI/Microsoft/Boot/bootmgfw.efi
}
EOL

sed -Ei 's/^.*(GRUB_TIMEOUT).*$/\1=2/g' /etc/default/grub
sed -Ei 's/^.*(GRUB_CMDLINE_LINUX).*"$/\1="splash quiet i915.modeset=1"/g' /etc/default/grub

echo -e "\nInstalling cpu microcode..\n" 1>&2
if $(cat /proc/cpuinfo | grep -qs "GenuineIntel"); then
    xbps-install -Sy intel-ucode
    echo 'early_microcode="yes"' >> /etc/dracut.conf.d/intel_ucode.conf
else
    xbps-install -Sy linux-firmware-amd
fi

echo -e "Removing old kernels...\n" 1>&2
vkpurge rm all

echo -e "Reconfiguring files...\n" 1>&2
xbps-reconfigure -fa

echo -e "Setup runit services...\n" 1>&2
rm -f /etc/runit/runsvdir/default/agetty-tty{4,5,6}
cat /etc/dhcpcd.conf | grep -qs "nohook resolv.conf" || echo "nohook resolv.conf" >> /etc/dhcpcd.conf
sed -Ei 's/^(.*)GETTY_ARGS=".*"/\1GETTY_ARGS="--autologin ${username} --noclear"/g' /etc/runit/runsvdir/default/agetty-tty1/conf
ln -sf /etc/sv/dhcpcd /etc/runit/runsvdir/default/

#TODO
#echo -e "Create dotfiles...\n" 1>&2
#xbps-install -Sy git
#git clone https://github.com/ivangeorgiew/dotfiles.git /home/${username}/dotfiles

exit
CHR

### FINAL STEPS ###
umount -R /mnt/void
echo -e "Finished!!!"
COMMENT
