#!/usr/bin/env bash
first_found="$(ls -1 | grep xml | head -1)"
NETWORK_XML="${NETWORK_XML:-${first_found}}"

if ! [ -f "${NETWORK_XML}" ]; then
    echo "File \"${NETWORK_XML}\" does not exist."
    exit 1
fi

declare -a existing_networks
readarray -t existing_networks <<<"$(virsh net-list --all | tail -n +3 | awk '{print $1}')"

net_def_file_contents="$(cat ${NETWORK_XML})"
re_net_name="<name>(.*)</name>"

if [[ ${net_def_file_contents} =~ ${re_net_name} ]]; then
    net_name="${BASH_REMATCH[1]}"

    if [[ " ${existing_networks[@]} " =~ " ${net_name} " ]]; then
        virsh net-destroy "${net_name}"
        virsh net-undefine "${net_name}"
    fi

    virsh net-define "${NETWORK_XML}"
    virsh net-start "${net_name}"
fi





