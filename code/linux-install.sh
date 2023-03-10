#!/usr/bin/env bash
# Error-handled script to install Linux
# Link to bash cheatsheet: https://devhints.io/bash

# -e is for exiting on error
# -E is making functions inherit the error trap
# -u is for error on undefined variable
# -o pipefail is ending piped commands with an error if one of them does
set -euo pipefail
# inherit_errexit is for throwing errors in command substitutions: var=$()
# failglob is for throwing errors when failed filename expansions
shopt -s inherit_errexit failglob
# better word splitting than the default ' \n\t'
# ("Aaron Johnson" "Brus Wayne") should wield 2 words, not 4
IFS=$'\n\t'

# constants
readonly SPACER="----------------------------------------------------------------------"
readonly KEYWORD_REGEX="^[a-zA-Z0-9_-]{6,}$"

# variables
HAS_CLEANED=false

# use it for printing without returning result
e() {
    echo "${@}" 1>&2 # to stderr for correct print order
}

# ask for user input. provide a second arg to hide the input
ask() {
    if [[ ${#} == 1 ]]; then
        read -rp "${1}" answer
    else
        read -srp "${1}" answer && e
    fi

    echo "${answer}"
}

# cleaning commands before an exit
cleanup() {
    [[ ${HAS_CLEANED} == true ]] && exit ${?}
    HAS_CLEANED=true

    e "${SPACER}"
    e "Cleaning up..."
    #grep -qs "${CHROOT_DIR} " /proc/mounts && umount -R ${CHROOT_DIR}
    e "Done"
    exit ${?}
}

# on interupt or exit
trap cleanup INT TERM HUP EXIT

# every function belowe this one must use "call funcName"
# samo goes for every subshell $(call command)
call() {
    # executes the function and saves the result if any
    # uses bash strict mode
    result=$(set -euo pipefail;"${@}" >&1)
    echo "result: ${result}"
    echo "end"
    err_code=${?}
    line_num=${BASH_LINENO[0]:-unknown}
    func=${1}

    # skip function name for the args
    shift

    # join args in format: "x", "y", "z"
    sprtr="\", \""
    args=$(printf "${sprtr}%s" "${@}")
    args=${args:${#sprtr}}

    # if there was an error
    if [[ ${err_code} -ne 0 ]]; then
        e "ERROR:"
        e "  Cmd: ${func}"
        e "  Args: \"${args}\""
        e "  Line: ${line_num}"
        e "  ErrCode: ${err_code}"
        e
        proceed_num=$(ask "How should we proceed? [1) exit; 2) retry; else) continue]: ")
        e

        if [[ "${proceed_num}" = 1 ]]; then
            exit 1
        elif [[ "${proceed_num}" = 2 ]]; then
            call "${func}" "${@}"
        fi
    fi

    if [[ -n "${result}" ]]; then
        echo "${result}"
    fi
}

read_diskname() {
    disk=$(ask "${1}")

    while ! [[ -b "/dev/${disk}" ]]; do
        e "Invalid device!"
        disk=$(ask "${1}")
    done

    echo "${disk}"
}

read_keyword() {
    keyword=$(ask "${1}")

    while ! (echo "${keyword}" | grep -Eqs "${KEYWORD_REGEX}" ); do
        e "Invalid keyword! Must match: ${KEYWORD_REGEX}"
        keyword=$(ask "${1}")
    done

    echo "${keyword}"
}

read_secret() {
    secret=$(ask "${1}" "s")

    while ! (echo "${secret}" | grep -Eqs "${KEYWORD_REGEX}" ); do
        e "Invalid secret keyword! Must match: ${KEYWORD_REGEX}"
        secret=$(ask "${1}" "s")
    done

    echo "${secret}"
}

welcome() {
    # script must be run as root
    user=$(call whoami)
    if [[ ${user} != "root" ]]; then
        e "Rerun with root priviliges!"
        exit 1
    fi

    call date "+%D %T"
    e "Welcome to my Linux install script!"
}

test1() {
    e "Testing..."

    r1=$(call read_diskname "Enter disk: ")
    e "Disk is: ${r1}"

    r2=$(call read_keyword "Enter username: ")
    e "Username is: ${r2}"

    r3=$(call read_secret "Enter password: ")
    e "Password is: ${r3}"
}

# write to shell and to logfile
# exec > >(tee -a "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/linux-install.log") 2>&1

#functions execution
e "${SPACER}"
welcome
e "${SPACER}"
test1

# ask for and verify all the input before actually doing the installation
# GRUB must be >=2.04 for zstd support
# use btrfs with -o compress-force=zstd:5,noatime,autodefrag
# use services.fstrim.enable = true; instead of discard=async just to be safe
# use swap file
# test compression rates with "compsize"
# check out Nix Options for "btrfs". I should enable/configure autoScrub and bees deduplication

# use better kernel than the default with: boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
# use boot.supportedFilesystems = [ "zfs" ];
