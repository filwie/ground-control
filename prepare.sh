#!/usr/bin/env bash

declare -A PM_MAP=(
    ["apt-get"]="env DEBIAN_FRONTEND=noninteractive apt-get -qq install --yes python3 python3-pip"
    ["pacman"]="pacman -Sy --needed python3"
    ["zypper"]="zypper --non-interactive install python3"
)


function get_pm_cmd {
    for pm in "${!PM_MAP[@]}"; do
        if command -v "${pm}" > /dev/null; then
            printf "%s" "${PM_MAP["${pm}"]}"
            return 0
        fi
    done
    echo "Cannot determine package manager" >> /dev/stderr
    exit 1
}

pm_cmd="$(get_pm_cmd)"

eval "${pm_cmd}"

pip3 install ansible
ansible-galaxy collection install community.crypto
