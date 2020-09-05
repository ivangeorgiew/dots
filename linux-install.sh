#!/bin/bash
# An error-handled script to install Void Linux by Ivan Georgiev

### SCRIPT SETTINGS ###
# Setup error handling everywhere
set -E
trap 'echo -e "Error ${?} at line ${LINENO}\n" >&2 && exit 1' ERR

echo -e "\nWelcome to the Voidlinux installation script!\n"

hostname='mahcomp'

read_diskname() {
    read -u 2 -p "${1}" disk
    while ! [[ -b "/dev/${disk}" ]]; do
        read -u 2 -p "Please enter a valid device: " disk
    done
    echo "${disk}"
}

read_keyword() {
    read -u 2 -p "${1}" keyword
    while ! [[ ${keyword} =~ ^[a-zA-Z0-9_-]+$ ]]; do
        read -u 2 -p "Please enter a valid keyword: " keyword
    done
    echo "${keyword}"
    unset keyword
}

read_secret() {
    read -u 2 -sp "${1}" secret && echo 1>&2
    while ! [[ ${secret} =~ ^[a-zA-Z0-9_-]+$ ]]; do
        read -u 2 -sp "Please enter a valid secret keyword: " secret && echo 1>&2
    done
    echo "${secret}"
    unset secret
}

### PARTITIONING ###
lsblk -o name,label,size
echo
boot_label=`read_keyword "Enter label for BOOT partition [ex: VOID-BOOT]: "`
swap_label=`read_keyword "Enter label for SWAP partition [ex: void-swap]: "`
root_label=`read_keyword "Enter label for ROOT partition [ex: void-root]: "`
echo
read -p "Should we partition? [y/N]: " should_partition
echo
if [[ ${should_partition} =~ ^\s*[yY]|^\s*$ ]]; then
    dev_to_part=`read_diskname "Which disk to partition? [ex: sda]: "`
    echo
    read -sp "Make EFI, swap and root then change their types. Press enter to continue..."
    echo
    fdisk /dev/${dev_to_part}
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
fi




### MOUNT AND DOWNLOAD ###
echo -e "Mounting disks...\n"
[[ -d /mnt/void ]] || mkdir -p /mnt/void
grep -qs "/mnt/void " /proc/mounts || mount /dev/disk/by-label/${root_label} /mnt/void
[[ -d /mnt/void/boot/efi ]] || mkdir -p /mnt/void/boot/efi
grep -qs "/mnt/void/boot/efi " /proc/mounts || mount /dev/disk/by-label/${boot_label} /mnt/void/boot/efi

if [[ ! -d "/mnt/void/root" ]]; then
    echo "Wait to download and extract voidlinux..."
    rootfs_name=`curl -sS "https://alpha.de.repo.voidlinux.org/live/current/" | grep -m 1 -o "void-x86_64-ROOTFS-[0-9]*.tar.xz" | head -1`
    curl -sS "https://alpha.de.repo.voidlinux.org/live/current/${rootfs_name}" | tar xfJ - -C /mnt/void
    echo -e "Finished\n"
fi

echo -e "Mounting subdirectories...\n"
for folder in dev sys proc run; do
    [[ -d /mnt/void/${folder} ]] || mkdir -p /mnt/void/${folder}
    if ! $(grep -qs "/mnt/void/${folder}" /proc/mounts); then
        mount -R /${folder} /mnt/void/${folder}
        mount --make-rslave /mnt/void/${folder}
    fi
done



### CONFIG FILES ###



### CHROOT AND INSTALL ###
export hostname boot_label swap_label root_label
export -f read_keyword read_secret

#Must escape(\) the characters \, $, `
#where we don't want to use expansion
chroot /mnt/void /bin/bash 1> /dev/null << 'CHR'
set -E
trap 'echo -e "Error ${?} at line ${LINENO}\n" >&2 && exit 1' ERR

echo -e "Modifying config files...\n" 1>&2

cat > /mnt/void/etc/resolv.conf << 'EOL'
nameserver 8.8.8.8
nameserver 8.8.4.4
EOL

echo "en_US.UTF-8 UTF-8" > /etc/default/libc-locales

echo "${hostname}" > /mnt/void/etc/hostname

cat > /mnt/void/etc/rc.conf << EOL
# /etc/rc.conf - system configuration for void

# Set the host name.
#
# NOTE: it's preferred to declare the hostname in /etc/hostname instead:
# 	- echo myhost > /etc/hostname
#
HOSTNAME="${hostname}"

# Set RTC to UTC or localtime.
HARDWARECLOCK="UTC"

# Set timezone, availables timezones at /usr/share/zoneinfo.
TIMEZONE="Europe/Sofia"

# Keymap to load, see loadkeys(8).
KEYMAP="dvorak"

# Console font to load, see setfont(8).
#FONT="lat9w-16"

# Console map to load, see setfont(8).
#FONT_MAP=

# Font unimap to load, see setfont(8).
#FONT_UNIMAP=

# Amount of ttys which should be setup.
#TTYS=
EOL

cat > /mnt/void/etc/fstab << EOL
# See fstab(5).
#
# <file system>	<dir> <type> <options> <dump> <pass>
LABEL="${boot_label}"  /boot/efi    vfat        defaults,discard        0       2
LABEL="${swap_label}"  swap         swap        defaults,discard        0       0
LABEL="${root_label}"  /            ext4        defaults,discard        0       1
tmpfs                  /tmp         tmpfs       defaults,nosuid,nodev   0       0
EOL

cat > /mnt/void/etc/dracut.conf << EOL
hostonly="yes"
add_dracutmodules+="resume"
tmpdir=/tmp
EOL

echo -e "User management..." 1>&2
username=`read_keyword "Enter username: "`

if ! id -u ${username} &> /dev/null; then
    pass1=`read_secret "Enter password: "`
    pass2=`read_secret "Repeat password: "`
    while ! [[ ${pass1} == ${pass2} ]]; do
        pass1=`read_secret "Passwords don't match or incorrect. Enter password: "`
        pass2=`read_secret "Repeat password: "`
    done

    useradd -m -g users -G wheel,input,video,disk,audio,kvm -s /bin/bash "${username}"
    yes ${pass1} | passwd ${username} &> /dev/null

    unset pass1 pass2
fi

chown root:root /
chmod 755 /
sed -Ei "s/^.*(%wheel.*NOPASSWD.*)/\1/" /etc/sudoers
passwd -dl root

echo -e "\nUpdating void...\n" 1>&2
xbps-install -Syu xbps void-repo-nonfree
xbps-install -Syu

echo -e "Installing base packages...\n" 1>&2
xbps-install -Sy base-system grub-x86_64-efi
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

sed -Ei 's/^.*(GRUB_TIMEOUT).*$/\1=2/' /etc/default/grub
sed -Ei 's/^.*(GRUB_CMDLINE_LINUX).*"$/\1="splash quiet i915.modeset=1"/' /etc/default/grub

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
rm -f /etc/runit/runsvdir/default/agetty-tty{3,4,5,6}
cat /etc/dhcpcd.conf | grep -qs "nohook resolv.conf" || echo "nohook resolv.conf" >> /etc/dhcpcd.conf
sed -Ei 's/^(.*)GETTY_ARGS=".*"/\1GETTY_ARGS="--autologin ${username} --noclear"/' /etc/runit/runsvdir/default/agetty-tty1/conf
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
