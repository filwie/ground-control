#!/usr/bin/env bash
set -eu


function __cmd () {
    [[ "${#}" -ne 1 ]] && return

    echo "[L${BASH_LINENO}|$(date '+%T')] ${1}"
    # eval "${1}"
}

function configure_interface () {
    local default_ip_addr_mask ip_addr_mask netiface

    echo "Select network interface to configure:"
    select iface in $(ip link show | grep -E '^[1-9]' | awk '{print $2}' | sed 's/://'); do
        netiface="${iface}"; break
    done

    default_ip_addr_mask="192.168.56.100/24"
    read -p "Specify IP address and mask [${default_ip_addr_mask}]:" ip_addr_mask
    ip_addr_mask="${ip_addr_mask:-${default_ip_addr_mask}}"


    echo -e "Interface:\t${netiface}"
    echo -e "IP and mask:\t${ip_addr_mask}"

    __cmd "ip addr add ${ip_addr_mask} dev ${netiface}"
}

function configure_sshd () {
    systemctl start sshd
}


configure_interface


