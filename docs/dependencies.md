# Orion OS — Dependency & Licensing Inventory

This document is a curated inventory of the upstream open-source packages
Orion OS depends on, with their licenses and the role they play. The full
package list lives in `distro/archiso/packages.x86_64`; this document explains
the licensing picture at a higher level.

## 1. Base system

| Package | License | Role |
|---|---|---|
| `linux` (kernel) | GPL-2.0-only with firmware blobs | Kernel |
| `systemd` | LGPL-2.1-or-later | Init, services, journal, logind, networkd, resolved (resolved disabled by default) |
| `pacman` | GPL-2.0-or-later | Package manager |
| `pacman-mirrorlist` | Public domain | Mirror list |
| `archlinux-keyring` | GPL-3.0-or-later | Arch package signing keys |
| `filesystem` | GPL-3.0-or-later | Base directory layout |
| `glibc` | LGPL-2.1-or-later | C library |
| `gcc-libs` | GPL-3.0-or-later with GCC Runtime Library Exception | C/C++ runtime |
| `bash` | GPL-3.0-or-later | Default shell |
| `coreutils` | GPL-3.0-or-later | Standard utilities |
| `util-linux` | GPL-2.0-or-later / BSD / LGPL | Partitioning, mount, etc. |
| `e2fsprogs` | GPL-2.0-or-later / LGPL / MIT | ext4 |
| `btrfs-progs` | GPL-2.0-or-later | Btrfs |
| `dosfstools` | GPL-3.0-or-later | FAT for EFI System Partition |

## 2. Boot chain

| Package | License | Role |
|---|---|---|
| `systemd-boot` (via `systemd`) | LGPL-2.1-or-later | UEFI bootloader (default) |
| `grub` | GPL-3.0-or-later | Legacy BIOS bootloader |
| `efibootmgr` | GPL-2.0-or-later | Manage UEFI boot entries |
| `mkinitcpio` | GPL-2.0-or-later | initramfs generator (default) |
| `dracut` (optional) | GPL-2.0-or-later / LGPL | Alternative initramfs generator |
| `sbctl` | MIT | Secure Boot key management (future) |

## 3. Display server and compositor

| Package | License | Role |
|---|---|---|
| `wayland` (libwayland) | MIT | Wayland protocol library |
| `xorg-xwayland` | MIT | X11 compatibility layer |
| `plasma-desktop` | GPL-2.0-or-later / LGPL | KDE Plasma desktop (used as KWin host) |
| `kwin` | GPL-2.0-or-later / LGPL | Wayland compositor |
| `layer-shell-qt` | LGPL-3.0-or-later | Layer-shell protocol for Orion panel/start menu |
| `qt6-base` | GPL-3.0-only (commercial dual) / LGPL-3.0-or-later | Qt 6 core |
| `qt6-declarative` | GPL-3.0-only / LGPL-3.0-or-later | QML engine |
| `qt6-wayland` | GPL-3.0-only / LGPL-3.0-or-later | Qt Wayland platform plugin |
| `qt6-tools` | GPL-3.0-only / LGPL-3.0-or-later | Qt dev tools |
| `extra-cmake-modules` | BSD-3-Clause | KDE CMake modules |

## 4. System services

| Package | License | Role |
|---|---|---|
| `networkmanager` | GPL-2.0-or-later | Network management |
| `pipewire` | MIT | Audio/video server |
| `wireplumber` | MIT | PipeWire session manager |
| `polkit` | LGPL-2.0-or-later | Authorization framework |
| `packagekit` | GPL-2.0-or-later | Package management D-Bus API |
| `udisks2` | GPL-2.0-or-later / LGPL | Disk management |
| `upower` | GPL-2.0-or-later | Power management |
| `bluez` | GPL-2.0-or-later / LGPL | Bluetooth |
| `accountsservice` | GPL-3.0-or-later | User account D-Bus API |
| `colord` | GPL-2.0-or-later / LGPL | Color management |
| `geoclue` | LGPL-2.1-or-later | Geolocation |
| `power-profiles-daemon` | GPL-3.0-or-later | Power profiles |
| `rtkit` | GPL-3.0-or-later / BSD | Real-time scheduling for audio |
| `polkit-qt6-1` (via `polkit-qt-1`) | LGPL-2.1-or-later | Qt6 polkit binding |

## 5. Login / session

| Package | License | Role |
|---|---|---|
| `sddm` | GPL-2.0-or-later | Display manager |
| `sddm-theme-orion` (Orion-authored) | CC-BY-SA-4.0 | Default SDDM theme |
| `pam` | GPL-2.0-or-later / BSD | Authentication |
| `gnome-keyring` | GPL-2.0-or-later / LGPL | Secrets storage |

## 6. User-facing applications (default set)

| Package | License | Role |
|---|---|---|
| `firefox` (or `chromium`) | MPL-2.0 / BSD-3-Clause | Web browser |
| `dolphin` (orion-branded wrapper) | GPL-2.0-or-later | File manager fallback |
| `konsole` (orion-branded) | GPL-2.0-or-later / LGPL | Terminal (wrapped) |
| `kate` (orion-branded) | GPL-2.0-or-later | Text editor |
| `gwenview` (orion-branded) | GPL-2.0-or-later | Image viewer |
| `spectacle` (orion-branded) | GPL-2.0-or-later | Screenshot tool |
| `ark` (orion-branded) | GPL-2.0-or-later | Archive manager |
| `calamares` | GPL-3.0-or-later | Installer |
| `noto-fonts`, `noto-fonts-cjk`, `ttf-jetbrains-mono` | OFL-1.1 | Default fonts |
| `inter-font` | OFL-1.1 | Default sans-serif |

## 7. Developer tools (optional profile, installable from Software Center)

| Package | License | Role |
|---|---|---|
| `git` | GPL-2.0-or-later | Version control |
| `base-devel` | various | Build essentials |
| `gcc` | GPL-3.0-or-later | C/C++ compiler |
| `clang` | Apache-2.0 with LLVM exceptions | C/C++/ObjC compiler |
| `python` | PSF-2.0 | Python interpreter |
| `nodejs` | MIT | Node.js runtime |
| `rust` | Apache-2.0 / MIT | Rust toolchain |
| `cmake` | BSD-3-Clause | Build system |
| `ninja` | Apache-2.0 | Build executor |
| `docker` | Apache-2.0 | Containers |
| `podman` | Apache-2.0 | Containers (rootless) |
| `openssh` | BSD-2-Clause / ISC | SSH client/server |

## 8. Compatibility layer (optional)

| Package | License | Role |
|---|---|---|
| `wine`, `wine-gecko`, `wine-mono` | LGPL-2.1-or-later | Windows API compatibility |
| `proton-ge` (Steam tool) | various | Steam Play compatibility tool |
| `bottles` | GPL-3.0-or-later | Wine prefix manager |
| `steam` (via Flatpak preferred) | Steam Subscriber Agreement | Game launcher |
| `lutris` | GPL-3.0-or-later | Game library manager |

Steam is a **non-free** application. Orion OS does not preinstall it; the
Welcome Center offers installation via Flatpak (which keeps Steam sandboxed).

## 9. Orion-authored components

All Orion-authored source code in this repository is licensed under
**GPL-3.0-or-later**. Branding assets (logos, wallpapers, themes) and
documentation are additionally licensed under **CC-BY-SA-4.0**. See
[`LICENSE`](../LICENSE) and [`NOTICE.md`](../NOTICE.md).

| Component | License |
|---|---|
| `orion-framework` (shared Qt6 library) | GPL-3.0-or-later |
| `orion-shell`, `orion-panel`, `orion-start-menu`, `orion-settings`, `orion-file-manager`, `orion-welcome-center`, `orion-software-center`, `orion-notifications`, `orion-quick-settings`, `orion-system-monitor`, `orion-update-manager`, `orion-screenshot-tool`, `orion-search`, `orion-lockscreen` | GPL-3.0-or-later |
| `orion-keyring` (packaging) | GPL-3.0-or-later (the keys themselves are public) |
| `orion-branding` (logos, name) | CC-BY-SA-4.0 |
| `orion-themes-*` | CC-BY-SA-4.0 (art) + GPL-3.0-or-later (code) |
| `orion-wallpapers` | CC-BY-SA-4.0 |
| `orion-defaults` (default config) | GPL-3.0-or-later (config files) |
| `orion-sddm-theme` | CC-BY-SA-4.0 (theme) + GPL-3.0-or-later (config) |
| Documentation (`docs/`, `README.md`, etc.) | CC-BY-SA-4.0 |

## 10. Proprietary components

**Orion OS does not bundle proprietary software.** Specifically:

- No proprietary NVIDIA driver in the ISO (installed on demand, post-install).
- No Steam preinstalled (installed on demand, via Flatpak to keep it
  sandboxed).
- No proprietary media codecs (MP3, H.264, etc.) preinstalled — use the
  Flatpak runtime which carries them.
- No proprietary fonts (Microsoft fonts, Apple fonts) included.
- No proprietary firmware beyond what is in `linux-firmware` upstream.

## 11. License compatibility

All Orion dependencies use licenses compatible with GPL-3.0-or-later. The
table in §4 of `LICENSE` (the GPL-3.0 compatibility appendix) summarizes which
licenses are compatible. Orion's own code is GPL-3.0-or-later; mixing with
LGPL-2.1-or-later components (e.g. systemd-libs) is allowed via the GPL-3.0
linking exception rules.

## 12. Updating this inventory

This file is regenerated by `scripts/update-dependency-inventory.sh` which
parses `distro/archiso/packages.x86_64` and queries the local pacman database
for each package's `License:` field. Run it after every release-cycle package
addition.

The script does **not** modify this file in place; it produces a candidate
`docs/dependencies.md.new` for human review before merging.
