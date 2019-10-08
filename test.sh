#!/usr/bin/env bash
set -eu

REPO_ROOT="$(dirname "$(realpath "${0}")")"
ROLES_DIR="${REPO_ROOT}/ansible/roles"

declare -A POSSIBLE_TEST_RESULTS=(
    ["SKIP"]="$(tput setaf 3)skipped$(tput sgr0)"
    ["PASS"]="$(tput setaf 2)passed$(tput sgr0)"
    ["FAIL"]="$(tput setaf 1)failed$(tput sgr0)"
)

declare -A TEST_RESULTS

function max_length () {
    local len=-1
    for el in "${@}"; do [[ ${#el} -gt ${len} ]] && len=${#el}; done
    printf "%s" "${len}"
}

function cprintf () {
    [ $# -lt 2 ] && return
    tput setaf "${1}"; shift
    # shellcheck disable=SC2059
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
    local role_name role_test_result molecule_commands
    molecule_command=(
        "lint"
        "converge"
    )

    for role in "${ROLES_DIR}"/*; do
        role_name="$(basename "${role}")"
        role_test_result="${POSSIBLE_TEST_RESULTS["FAIL"]}"
        if [[ -d "${role}/molecule" ]]; then
            pushd "${role}" > /dev/null || return
            if $(true); then
                info "Role %s passed all tests!\n" "${role_name}"
                role_test_result="${POSSIBLE_TEST_RESULTS["PASS"]}"
            else
                error "Role %s did not pass all tests!\n" "${role_name}"
            fi
            popd > /dev/null || return
        else
            warning "Role %s does not support Molecule. Skipping...\n" "${role_name}"
            role_test_result="${POSSIBLE_TEST_RESULTS["SKIP"]}"
        fi
        TEST_RESULTS+=(["${role_name}"]="${role_test_result:-${POSSIBLE_TEST_RESULTS["FAIL"]}}")
    done
}

function display_as_table () {
    local assoc_arr left_col_width right_col_width pad_char pad_key pad_val
    typeset -n assoc_arr=$1
    left_col_width=$(( 1 + $(max_length "${!assoc_arr[@]}") ))
    right_col_width=$(( 1 + $(max_length "${assoc_arr[@]}") ))
    for key in "${!assoc_arr[@]}"; do
        pad_char=' '
        pad_key=$(( left_col_width - ${#key} ))
        pad_val=$(( right_col_width - ${#assoc_arr[${key}]}))
        printf "%s%${pad_key}s| %s%${pad_val}s\n" "${key}" "${pad_char}" "${assoc_arr[${key}]}" "${pad_char}"
    done
}

function main () {
    check_molecule
    run_tests
    echo
    display_as_table TEST_RESULTS
    echo
}

main


