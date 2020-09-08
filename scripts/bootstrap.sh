#!/usr/bin/env bash
set -eu


function set_dns {
    cat <<EOF > /etc/resolv.conf
        nameserver 1.1.1.1
        nameserver 8.8.8.8
EOF
    echo "DNS updated"
}


function recreate_mirrorlist () {
    curl -s 'https://www.archlinux.org/mirrorlist/?country=PL&protocol=https&ip_version=4' \
        -Lo /etc/pacman.d/mirrorlist
    sed -i 's/^.//' /etc/pacman.d/mirrorlist
    echo "mirrorlist generated:"
    cat /etc/pacman.d/mirrorlist
}


function disable_hwf_gcrypt {
    mkdir /etc/gcrypt/
    cat <<EOF > /etc/gcrypt/hwf.deny
        padlock-rng
        padlock-aes
        padlock-sha
        padlock-mmul
        intel-cpu
        intel-fast-shld
        intel-bmi2
        intel-ssse3
        intel-pclmul
        intel-aesni
        intel-rdrand
        intel-avx
        intel-avx2
        intel-rdtsc
        arm-neon
EOF
    echo "Hardware features of gcrypt disabled"
}


function set_timezone {
    timedatectl set-timezone Europe/Warsaw
    hwclock -w
    echo "Timezone set"
    timedatectl
}


function reset_pacman {
    pacman -Sy --noconfirm archlinux-keyring
#    echo 'yes | pacman -Scc'
#    yes | pacman -Scc
#
#    echo 'rm -R /etc/pacman.d/gnupg/'
#    rm -R /etc/pacman.d/gnupg/
#
#    echo 'yes | gpg --refresh-keys'
#    yes | gpg --refresh-keys
#
#    echo 'yes | pacman-key --init'
#    yes | pacman-key --init
#
#    echo 'yes | pacman-key --populate archlinux'
#    yes | pacman-key --populate
#
#    # yes | pacman-key --refresh-keys
}


function main {
    if ! [ -f /.recreated ]; then
        set_dns
        recreate_mirrorlist
        disable_hwf_gcrypt
        set_timezone
        reset_pacman
        pacman -Syyu --noconfirm
        touch /.recreated
    fi
}


main
