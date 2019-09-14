#!/usr/bin/env bash

PACKAGES=("python" "ansible")

function setup_dns () {
    echo "Setting nameserver to 1.1.1.1"
    sed -i 's/^#DNS=.*$/DNS=1.1.1.1/' /etc/systemd/resolved.conf
    systemctl restart systemd-resolved
}

function setup_mirrors () {
    # seconds
    local recreate_mirrors_timeout=3600

    echo "Recreating Pacman mirrorlist"
    # shellcheck disable=SC2016
    echo 'Server = https://ftp.icm.edu.pl/pub/Linux/dist/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
    local recreate_indicator=/mirrorlist_recreated
    if ! [[ -f "${recreate_indicator}" ]] || [[ $(( $(date +'%s') - $(cat "${recreate_indicator}") )) -gt "${recreate_mirrors_timeout}" ]]; then
        rm -rf /etc/pacman.d/gnupg
        pacman-key --init &> /dev/null
        pacman-key --populate archlinux &> /dev/null
        date +'%s' > "${recreate_indicator}"
    fi
}

function install_packages () {
    declare -a packages_to_install

    for package in "${PACKAGES[@]}"; do
        if ! command -v "${package}" &> /dev/null; then
            echo "${package} is not installed. Scheduling for installation."
            packages_to_install+=("${package}")
        else
            echo "${package} is already installed. Skipping."
        fi
    done
    if [[ -n "${packages_to_install[*]}" ]]; then
        pacman -Sy --needed --noconfirm "${packages_to_install[@]}" > /dev/null
    fi
}

function main () {
    setup_dns
    setup_mirrors
    install_packages
}

main
