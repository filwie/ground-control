#!/usr/bin/env zsh
set -e

declare -aU things_to_backup=(
    "${HOME}/work"
    "${HOME}/.dotfiles"
    "${HOME}/bin"
)

for arg in "${@}"
do
    things_to_backup+=("${arg}")
done

declare -a directories
declare -a files

local backup_dir="${HOME}/backup/$(hostname)"
local filename_suffix="$(date +'%F')"

local italic=$(tput sitm)
local bold=$(tput bold)
local green="$(tput setaf 2)"
local yellow="$(tput setaf 3)"
local red="$(tput setaf 1)"
local reset="$(tput sgr0)"

local GB="1073741824"

function info_msg () {
    local msg="${green}[$(date +'%T')] "
    echo "${msg}${1}${reset}"
}

function error_msg () {
    local msg="${red}[$(date +'%T')] "
    echo "${msg}${1}${reset}"
    (exit "${2:-0}")
}

function validate_backup_dir () {
    if [[ -d "${backup_dir}" ]]; then
        info_msg "${backup_dir} found."
    else
        mkdir -p "${backup_dir}"
        info_msg "${backup_dir} not found. Creating..."
    fi
}


function categorize_things_to_backup () {
    for thing in "${things_to_backup[@]}"
    do
        [[ -d "${thing}" ]] && {
            directories+=("${thing}")
        }

        [[ -f "${thing}" ]] && {
            files+=("${thing}")
        }
    done

    echo -e "\nDirectories to compress and copy:\n"
    for d in "${directories[@]}"; do echo -e "\t${d}"; done
    echo -e "\nFiles to copy:\n"
    for f in "${files[@]}"; do echo -e "\t${f}"; done
    echo
}


function ask_for_confirmation () {
    vared -p 'Proceed? [Y/n]: ' -c choice
    case "${choice}" in
        "Y"|"y"|"\n"|"")
            info_msg "Proceeding..."
            return 0
            ;;
        "n")
            error_msg "Aborting..."
            return 1
            ;;
        *)
            error_msg "Unrecognized option: ${choice}"
            return 1
            ;;
    esac
}


function backup_the_things () {
    for dir in "${directories[@]}"
    do
        local target="${backup_dir}/$(basename ${dir})_${filename_suffix}.tar.gz"
        local excluded="--exclude='.tox' --exclude='*.pyc' --exclude='*.pyo'"
        local cmd="tar "${excluded}" -hczf "${target}" -C "${dir}/.." "$(basename ${dir})""
        info_msg "Running: ${cmd}"
        eval "${cmd}" && info_msg "Done" || error_msg "Something went wrong"
    done

    for file in "${files[@]}"
    do
        local target="${backup_dir}/$(basename ${file})_${filename_suffix}.tar.gz"
        local cmd="cp "${file}" "${target}""
        info_msg "Running: ${cmd}"
        eval "${cmd}" && info_msg "Done" || error_msg "Something went wrong"
    done
}

function main () {
    validate_backup_dir
    categorize_things_to_backup
    ask_for_confirmation \
        && backup_the_things \
        || exit 1

    tree -a ${backup_dir}
    du -ah ${backup_dir}
}


main
