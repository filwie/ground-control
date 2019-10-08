#!/usr/bin/env bash

PACKAGES_TO_INSTALL=(
    "ansible"
)

function install_packages () {
    zypper --quiet --non-interactive install "${PACKAGES_TO_INSTALL[@]}"
}

function main () {
    install_packages
}

main
