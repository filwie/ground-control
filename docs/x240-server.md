# Closing the lid without sleeping

1. Set `HandleLidSwitchExternalPower` to `ignore` in `etc/systemd/logind.conf` or `/etc/systemd/logind.conf.d/*.conf`.
2. To apply changes:
   ``` sh
   systemctl kill -s HUP systemd-logind
   ```

Reference: [Power management with systemd](https://wiki.archlinux.org/title/Power_management#Power_management_with_systemd)
