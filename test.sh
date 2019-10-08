#!/usr/bin/env bash
set -eu

REPO_ROOT="$(dirname "$(realpath "${0}")")"
ROLES_DIR="${REPO_ROOT}/ansible/roles"

declare -a MOLECULE_FLAGS
MOLECULE_COMMANDS=(
    "converge"
)
KEEP_CONTAINERS=0

declare -A POSSIBLE_TEST_RESULTS=(
    ["SKIP"]="$(tput setaf 3)skipped$(tput sgr0)"
    ["PASS"]="$(tput setaf 2)passed$(tput sgr0)"
    ["FAIL"]="$(tput setaf 1)failed$(tput sgr0)"
)

declare -A TEST_RESULTS


function usage () {
    echo -e "USAGE: ./test.sh [-v|--verbose] [-l|--lint] [-i|--idempotence] [-k|--keep]"
    exit 1
}

function handle_arguments () {
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -h|--help)
                usage ;;
            -l|--lint)
                MOLECULE_COMMANDS+=("lint"); shift ;;
            -i|--idempotence)
                MOLECULE_COMMANDS+=("idempotence"); shift ;;
            -k|--keep)
                KEEP_CONTAINERS=1; shift ;;
            -v|--verbose)
                MOLECULE_FLAGS+=("--debug"); shift ;;
            *)
                usage ;;
        esac
    done
}

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
function run_log () { info "Running: ${*}"; eval "${@}"; }

function check_molecule () {
    if ! command -v molecule > /dev/null; then
        error "Molecule not installed. Install it before running this script.\n"
        exit 1
    fi
}

function run_molecule () {
    for molecule_command in "${MOLECULE_COMMANDS[@]}"; do
        cmd="molecule"
        [[ -n "${MOLECULE_FLAGS[*]}" ]] && cmd+=" ${MOLECULE_FLAGS[*]}"
        cmd+=" ${molecule_command}"
        if ! run_log "${cmd}"; then
            error "Molecule action %s failed.\n" "${molecule_command}"
            return 1
        fi
    done
    [[ "${KEEP_CONTAINERS}" == 0 ]] && molecule destroy
    return 0
}

function run_all_tests () {
    local role_name role_test_result
    for role in "${ROLES_DIR}"/*; do
        role_name="$(basename "${role}")"
        role_test_result="${POSSIBLE_TEST_RESULTS["FAIL"]}"
        if [[ -d "${role}/molecule" ]]; then
            pushd "${role}" > /dev/null || return
            if run_molecule; then
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
    handle_arguments "${@}"
    check_molecule
    run_all_tests
    echo
    display_as_table TEST_RESULTS
    echo
}

main "${@}"
