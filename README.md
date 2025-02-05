# Ground Control
__WIP__
This repository contains:
- Ansible roles for configuring development environment
- Vagrantfiles for setting up development VMs with a single command
- __Tests!__
- Outdated README 😢

## #TODO
- [x] Add a fancy test runner with colorful output
- [ ] Add `Ansible Molecule` tests for each role
- [ ] Write a good README for each role
- [ ] Support three distributions: `Arch` `OpenSUSE Tumbleweed` and `Ubuntu:18.04`

## Usage
### Running tests
Execute `./test.sh` script and wait for a couple of <s>hours</s>minutes expecting
wonderfull colorful output:

<img src="https://raw.githubusercontent.com/filwie/images/master/ground-control/tests.png" alt="demo" width="100%"/>

### Vagrant
There are currently two supported distros (__WIP__): `Arch Linux` and `OpenSUSE Tumbleweed`.
<i>Choose your destiny</i> - navigate to appropriate path:

    vagrant/
    ├── arch
    │   └── Vagrantfile
    └── opensuse
        ├── Vagrantfile
        └── init.sh

Run `vagrant up --provision` in either `arch` or `opensuse` directory.
Ofcourse, `vagrant` must be installed for this to work. Ansible does not have to, as
`ansible_local` provisioner is used to provision the VMs.

#### GitHub
To generate SSH keypair and add public key to GitHub set following environment
variables before running `vagrant provison` (or `vagrant up --provison`):

variable | contents
--- | ---
`GITHUB_USERNAME` | self-explanatory
`GITHUB_TOKEN` | GitHub API token with permissions to manage SSH keys

To __remove__ generated key from GitHub account once again export above variables
and use `varant destroy` - Vagrant should trigger `github` role with `delete` mode.

## Table of Contents

- [Ground Control](#Ground-Control)
  - [Table of Contents](#Table-of-Contents)
  - [Roles](#Roles)
    - [arch_aur](#archaur)
    - [arch_bluetooth](#archbluetooth)
    - [arch_locale](#archlocale)
    - [arch_reflector](#archreflector)
    - [fonts](#fonts)
    - [git](#git)
  - [Issues](#Issues)
    - [Meta tasks as handlers](#Meta-tasks-as-handlers)

## Roles

Default values can be found in roles' `defaults` directories and can be overwritten on basically
any level: `playbook`, `inventory`, `group/host vars`, `extra-vars` etc.

### arch_aur

- Installs `git`, `base-devel` and `python-pip` packages which are required to build packages from `AUR`
- Creates `aur_builder` user with privileges set to run `sudo pacman` witbout providing password
- Installs `yay` `AUR` helper

Defaults

- `pacman` operation's timeout is set to 5 minutes which might sometimes be too short

Reference:

- [Arch User Repository](https://wiki.archlinux.org/index.php/Arch_User_Repository)
- [yay](https://github.com/Jguer/yay)

### arch_bluetooth

- Installs `bluez`, `blueman` and `pulseaudio-bluetooth` packages
- Creates `wheel` group if it is nonexistant
- Adds user to the group
- Creates `polkit` rule allowing aforementioned group's users access to bluetooth functions
- starts and enables `bluetooth` service

Defaults:

- `wheel` as the group allowed to use `bluetooth`
- file containing polikit rule: `/etc/polkit-1/rules.d/51-blueman.rules`

Reference:

- [bluetooth](https://wiki.archlinux.org/index.php/Bluetooth#Front-ends)

### arch_locale

- Generates specified locales
- Makes sure `libxkbcommon` package is installed (for setting x11 keymap)
- Sets locale and keymap using `localectl`
- Sets timezone

Defaults:

- locale `en_US.UTF-8`
- keymap `pl`
- timezone `Europe/Warsaw`

### arch_reflector

- Installs `reflector`
- creates `systemd` service and timer

Defaults:

- repositories are sorted once a week
- only HTTPS repositories are selected
- 100 most recently synchronized repositories are used

Reference:

- [reflector](https://wiki.archlinux.org/index.php/Reflector)
- [systemd/timers](https://wiki.archlinux.org/index.php/Systemd/Timers)

### fonts

- Installs `fontconfig` and `unzip`
- Creates user's fonts directory (different for `Mac OS` and `Linux`)
- Downloads and unarchives fonts
- Refreshes font cache
- Cleans up non-truetype fonts files

Defaults:

- Fonts: `Iosevka`, `Mononoki`, `Fantasque` and `Noto`

Vars:

- Linux font dir: `~/.local/share/fonts`
- Mac OS font dir: `~/Library/Fonts`

Reference:

- [fantasque](https://github.com/belluzj/fantasque-sans)
- [iosevka](https://github.com/be5invis/Iosevka)
- [mononoki](https://madmalik.github.io/mononoki/)
- [noto](https://www.google.com/get/noto/)

### git

- Installs git
- Creates git config file
- Places global gitignore in specified path
- Installs `neovim` and `python-neovim` if `nvim` is set as `git_core_editor`

Defaults:

- `nvim` as core editor, diff and merge tools
- global gitignore path `~/.gitglobalignore`

## Issues

### Meta tasks as handlers

Currently (as of Jul 3rd 2019) Ansible's meta tasks cannot be used as handlers, so
I added `ignore_errors` to them. As soon as [this](https://github.com/ansible/ansible/issues/50306)
is implemented, that line can be deleted.

In case of below roles it is used primarely to reset SSH connection and allow new
groups to be applied to the user.
