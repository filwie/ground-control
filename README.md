# Ground Control

## Roles

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


## Vagrant and interactive Ansible playbooks / shell scripts

Those do not mix - find a way to manage variables. Maybe env vars, dotenv file or something.

## Github account

### Add

1. Create GitHub API token for managing SSH keys and save it either to `/.token` or `/etc/profile.d/` (might cause troubles with fish shell) or set an env var some other way.
2. Generate SSH key-pair.
3. Register generated public key using previously created token.

### Remove (triggered by Vagrant destroy)

1. Delete public key from GitHub account using existing token for managing SSH keys.
2. Delete token using itself [docs]( https://developer.github.com/v3/oauth_authorizations/#delete-an-authorization )
