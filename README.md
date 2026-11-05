# Orion OS

> A polished, Arch-Linux-based desktop operating system with a distinctive
> Windows-inspired workflow, original Orion branding, and a path toward an
> independent desktop experience.

**Internal codename:** Orion
**Base:** Arch Linux (rolling)
**Architecture:** x86_64
**Primary display server:** Wayland
**Compositor:** KDE KWin (initial release)
**UI framework:** Qt 6 / QML
**Installer:** Calamares (customized Orion branding)
**Image builder:** Archiso

---

## What this repository is

This repository contains the **complete source tree** for Orion OS — distribution
configuration, desktop components, branding assets, installer configuration,
themes, packaging, build scripts, tests, and documentation.

It is **not** a desktop theme, a screenshot collection, or a mockup. Every file
in this tree is intended to be buildable on an appropriate Arch Linux host.

## What this repository is NOT (yet)

The current sandbox in which this repository was created does **not** contain
the Arch Linux toolchain required to actually produce and boot an ISO. The
following tools are **not available** in the sandbox:

- `pacman`, `archiso`, `mkarchiso`
- `calamares`
- `qemu-system-x86_64`, `ovmf`
- `cmake`, `ninja`, `qmake6`

Therefore, **no ISO has been built or booted here**. The build and test scripts
in [`scripts/`](scripts/) are written to be reproducible on a real Arch Linux
host. See [`docs/installation.md`](docs/installation.md) for the host setup
procedure, and see [`STATUS.md`](STATUS.md) for an honest, current statement of
what is implemented versus planned.

## Repository layout

```
orion-os/
├── docs/                 Architecture, security, install, dev, release docs
├── distro/               Archiso profile, packages, services, defaults, branding
│   ├── archiso/          Archiso configuration (profiledef.sh, packages, airootfs)
│   ├── packages/         Orion-specific package sources
│   ├── services/         systemd unit files shipped by the image
│   ├── defaults/          Default config files (pacman, NetworkManager, PipeWire, …)
│   └── branding/         Logos, name files, boot splash
├── desktop/              Orion-branded desktop components (Qt6/QML)
│   ├── orion-framework/  Shared library: theme, tokens, common QML components
│   ├── shell/            Orion Shell (KWin integration + session)
│   ├── panel/            Bottom taskbar
│   ├── start-menu/       Start menu / launcher
│   ├── settings/         Unified settings app
│   ├── file-manager/     File manager (Explorer-like)
│   ├── welcome-center/   First-run experience
│   ├── software-center/  Graphical package manager
│   ├── notifications/    Notification daemon + UI
│   ├── quick-settings/   Quick-settings panel
│   ├── system-monitor/   System monitor
│   ├── update-manager/   Update notifier + UI
│   ├── screenshot-tool/  Screenshot utility
│   ├── search/           Global search (Orion Search)
│   └── lockscreen/       Lock-screen integration
├── installer/            Calamares configuration + branding
├── themes/               Orion Dark/Light/Midnight/Aurora/High-Contrast
├── wallpapers/           Default wallpapers (SVG + PNG)
├── packaging/            PKGBUILD templates + repo helper
├── scripts/             Build, test, dev, render scripts
├── tests/                Unit, integration, security, VM tests
└── .github/workflows/    CI pipelines
```

## Quick start (on a real Arch Linux host)

```bash
# 1. Set up the build environment (installs archiso, calamares-config, …)
sudo ./scripts/setup-build-env.sh

# 2. Build the Orion OS ISO
./scripts/build-iso.sh

# 3. Test boot in QEMU (requires qemu-system-x86_64, ovmf)
./scripts/test-iso-qemu.sh distro/archiso/out/orion-os-*.iso
```

See [`docs/installation.md`](docs/installation.md) for the full procedure and
troubleshooting.

## Design philosophy

1. Simplicity for beginners.
2. Flexibility for advanced users.
3. Fast startup and responsive operation.
4. Strong security and sensible defaults.
5. A consistent and visually appealing interface.
6. Transparency about the underlying Linux system.
7. Repairability, maintainability, and documented configuration.
8. Accessibility and support for different hardware capabilities.

## Licensing

Most Orion-authored source code is released under the **GNU General Public
License v3 or later** (see [`LICENSE`](LICENSE)). Documentation is released
under **CC-BY-SA 4.0**. Branding assets (logos, wallpapers) are released under
**CC-BY-SA 4.0**. Each subcomponent's `LICENSE` file states the exact license.

Orion OS is a **community project** and is not affiliated with, endorsed by, or
sponsored by Microsoft, Arch Linux, KDE, or any other upstream project. Orion OS
does not ship proprietary Windows assets. The desktop takes inspiration from
familiar Windows workflows but uses entirely original artwork, icons, sounds,
and branding.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Security reports follow
[`SECURITY.md`](SECURITY.md).

## Status

See [`STATUS.md`](STATUS.md) for the current implementation status, what works,
what is planned, and the next milestone.
