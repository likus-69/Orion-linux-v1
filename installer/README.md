# Orion OS Installer (Calamares)

Orion OS uses **Calamares** as its installer. This directory contains
the Orion-specific configuration, branding, and post-install modules.

## Layout

```
installer/
├── settings.conf                     # Top-level Calamares config
├── branding/
│   ├── orion.branding                # Branding descriptor
│   ├── show.qml                      # Slideshow played during installation
│   ├── logo.png                      # Orion logo (rendered)
│   ├── icon.png                      # App icon (rendered)
│   └── welcome.png                   # Welcome slide background (rendered)
└── modules/
    ├── partition.conf                # Default filesystem = Btrfs, LUKS support
    ├── users.conf                    # New user → wheel group; no root pw
    ├── bootloader.conf               # systemd-boot (UEFI) / GRUB (BIOS)
    ├── displaymanager.conf           # SDDM; default session = orion.desktop
    ├── welcome.conf                  # Storage 24 GB min, RAM 2 GB min
    ├── orion-postinstall/             # Custom Python module
    │   ├── module.desc
    │   └── main.py                    # Removes live-ISO polkit/sudoers
    └── orion-finalize/                # Trivial shell-process placeholder
        └── module.desc
```

## What the installer does

1. **Welcome** — language, requirements check (storage ≥ 24 GB, RAM ≥ 2 GB).
2. **Locale** — region + zone.
3. **Keyboard** — layout.
4. **Partition** — guided (erase disk) or manual. Defaults to Btrfs on root
   with subvolumes for `/`, `/home`, `/var/cache`, `/var/log`, `/.snapshots`.
   Optional LUKS full-disk encryption.
5. **Users** — create the user account; first user is added to `wheel` for
   `sudo` access. `root` is locked.
6. **Summary** — explicit review screen showing every destructive action.
7. **Install** — copies the squashfs to disk, sets up the bootloader,
   runs `mkinitcpio`, installs systemd-boot.
8. **Post-install cleanup** — the Orion post-install module removes the
   live-ISO's permissive polkit rule and sudoers file, so the installed
   system uses standard policies.
9. **Finish** — reboot prompt.

## Customization notes

- **No internet required** during install. All packages come from the
  ISO's local repo (built into the squashfs).
- **No auto-login** on the installed system. The user logs in via SDDM.
- **Root is locked.** Use `sudo` for administrative tasks.
- **zram** handles swap by default; manual swap is optional.

## Build + install

The `orion-installer` package installs everything in this directory to
`/etc/calamares/`. The `orion-installer` desktop entry (in
`distro/archiso/airootfs/usr/share/applications/`) launches Calamares with
the Orion config.

## License

Calamares is GPL-3.0-or-later; the Orion configuration here is also
GPL-3.0-or-later. See `LICENSE` at the repository root.
