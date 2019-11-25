xdg_base_directory
=========

Creates `XDG` user directories, and sets env vars to configure more programs for
`XDG` standard compliance.

Role Variables
--------------

`xdg_base_directory_global` - set to `true` tells role to update global `rc` files
(such as `/etc/zshenv`, `/etc/profile` and `/etc/fish/conf.d/xdg.fish` - so it
requires superuser privileges). If it is set to `false`

Example Playbook
----------------

``` yaml
- hosts: workstation
  roles:
     - { role: xdg_base_directory, xdg_base_directory_global: false }
```

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a
website (HTML is not allowed).
