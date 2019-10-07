#!/usr/bin/env bash

REPO_ROOT="$(dirname "$(realpath "${0}")")"
ROLES_DIR="${REPO_ROOT}/ansible/roles"

function cprintf () {
    [ $# -lt 2 ] && return
    tput setaf "${1}"; shift
    printf "${@}"
    tput sgr0
}

function info () { cprintf 2 "${@}"; }
function warning () { cprintf 3 "${@}"; }
function error () { cprintf 1 "${@}"; }

function check_molecule () {
    if ! command -v molecule > /dev/null; then
        error "Molecule not installed. Install it before running this script.\n"
        exit 1
    fi
}

function run_tests () {
    for role in "${ROLES_DIR}"/*; do
        if [[ -d "${role}/molecule" ]]; then
            pushd "${role}" > /dev/null
            molecule converge
            popd > /dev/null
        else
            warning "Role %s does not support Molecule\n" "${role}"
        fi
    done
}

function main () {
    check_molecule
    run_tests
}

main
