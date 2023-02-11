#!/usr/bin/env bash
# Error-handled script to install Linux
# Link to bash cheatsheet: https://devhints.io/bash

# bash script mode without "-e" on purpose
set -uo pipefail; IFS=$'\n\t'

readonly SPACER="----------------------------------------------------------------------"
readonly KEYWORD_REGEX="^[a-zA-Z0-9_-]{6,}$"

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
    set -euo pipefail; IFS=$'\n\t'

    [[ ${HAS_CLEANED} ]] && exit ${?}
    HAS_CLEANED=true

    e
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
    result=$(set -euo pipefail; IFS=$'\n\t'; "${@}")
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

    # written like this to detect errors
    curr_date=$(call date "+%D %T")
    e "${curr_date}"

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

#functions execution
e "${SPACER}"
call welcome
e "${SPACER}"
call test1
