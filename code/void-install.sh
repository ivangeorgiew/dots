#!/bin/sh
# A script to install Void Linux by Ivan Georgiev

readonly SPACER="----------------------------------------"
readonly CHROOT_DIR="/mnt/void"
# readonly LOG_FILE="log.txt"
# readonly BOOT_LABEL="VOID-BOOT"
# readonly SWAP_LABEL="void-swap"
# readonly ROOT_LABEL="void-root"

# on interupt or exit
trap '{ stty echo; echo; call cleanup; exit 1; }' INT TERM HUP

e() {
    echo "$@" 1>&2
}

p() {
    printf %s "$@" 1>&2
}

cleanup() {
    e "Cleaning up..."
    grep -qs "$CHROOT_DIR " /proc/mounts && umount -R $CHROOT_DIR
    e "Done"
    e "$SPACER"
    exit 0
}

call() {
    e "$SPACER"

    result=$(set -e; "$@")
    err_code=$?
    line_num=$LINENO
    func=$1
    shift
    args="$*"

    if [ $err_code -ne 0 ]; then
        e "$SPACER"
        e "Error at: $func"
        e "Arguments: $args"
        e "Exit code $err_code on line ${line_num:-unknown}"

        p "How should we proceed? [1 - exit; 2 - retry; 3 - continue]: "
        read -r proceed_num

        if [ "$proceed_num" = 1 ]; then
            e "Exiting..."
            call cleanup
            exit 0
        elif [ "$proceed_num" = 2 ]; then
            e "Retrying..."
            call "$func" "$@"
        else
            e "Proceeding..."
        fi
        e "$SPACER"
    fi

    if [ -n "$result" ]; then
        echo "$result"
    fi
}

read_diskname() {
    p "$1"
    read -r disk
    while ! [ -b "/dev/$disk" ]; do
        e "Invalid device!"
        p "$1"
        read -r disk
    done

    echo "$disk"
}

read_keyword() {
    p "$1" && read -r keyword

    while ! (echo "$keyword" | grep -Eqs "^[a-zA-Z0-9_-]+$" ); do
        e "Invalid keyword!"
        p "$1" && read -r keyword
    done

    echo "$keyword"
}

read_secret() {
    p "$1" && stty -echo && read -r secret && stty echo && e

    while ! (echo "$secret" | grep -Eqs "^[a-zA-Z0-9_-]+$" ); do
        e "Invalid secret keyword!"
        p "$1" && stty -echo && read -r secret && stty echo && e
    done

    echo "$secret"
}

start() {
    e "$(date +%D) - Beginning installation"

    if [ "$(whoami)" != "root" ]; then
        sudo su -s "$0"
        exit 0
    fi
}

testt() {
    e "Testing..."

    r1=$(read_diskname "Enter disk: ")
    e "Disk is: $r1"
    r2=$(read_keyword "Enter username: ")
    e "Username is: $r2"
    r3=$(read_secret "Enter password: ")
    e "Password is: $r3"
}

#functions execution
call start
call testt
call cleanup
