# Orion OS — Current Status

**Last updated:** 2026-10-23
**Sandbox OS:** Debian GNU/Linux 13 (trixie) — *not* Arch Linux
**Sandbox capability:** git, python3, cairosvg, matplotlib — **no** pacman, archiso,
calamares, qemu, or Qt6 build tools.

This file is an honest statement of what is implemented versus planned. It is
updated as work progresses.

---

## Test results (run in the sandbox)

```
$ python3 -m pytest tests/ -q
157 passed, 5 skipped in 0.32s

$ ./scripts/security-scan.sh
SECURITY SCAN SUMMARY
  HIGH:   0
  MEDIUM: 0
  LOW:    1
```

The single LOW finding is the placeholder Orion signing key fingerprint
(`0000…`), which is intentional — it gets replaced with a real fingerprint
at first signed release.

---

## Repository at a glance

| Directory | Files | Purpose |
|---|---|---|
| `desktop/` | 236 | 15 Orion desktop components (orion-framework + 14 apps) |
| `distro/` | 64 | Archiso profile, packages, services, defaults, branding |
| `installer/` | 15 | Calamares config + branding + post-install module |
| `themes/` | 25 | 5 themes × 5 files each (dark/light/midnight/aurora/HC) |
| `wallpapers/` | 8 | 4 wallpapers × 2 formats (SVG + PNG) |
| `packaging/` | 14 | PKGBUILD templates for every Orion component |
| `scripts/` | 9 | Build / dev / test / render scripts |
| `tests/` | 7 | Unit + integration + security + VM smoke tests |
| `docs/` | 9 | Architecture, install, dev, security, troubleshooting, release, design-system, hardware, dependencies |
| `.github/workflows/` | 3 | desktop-tests, build-iso, security-scan |
| **Total** | **399** | ~5.1 MB |

- ✅ Repository skeleton with full directory layout (see `README.md`).
- ✅ Top-level project docs: `README.md`, `LICENSE`, `CONTRIBUTING.md`,
  `SECURITY.md`, `CODEOWNERS`, `.gitignore`.
- ✅ `docs/` with architecture, installation, development, security,
  troubleshooting, release-process, design-system, and hardware-support.
- ✅ `distro/archiso/` profile (`profiledef.sh`, `packages.x86_64`,
  `pacman.conf`, bootloader entries, airootfs customization script).
- ✅ `distro/services/` systemd unit files for Orion-session boot.
- ✅ `distro/defaults/` default config files (pacman, NetworkManager, PipeWire,
  WirePlumber, polkit, mkinitcpio, sddm, KWin, locale, dracut/mkinitcpio).
- ✅ `distro/branding/` name files, boot splash script (Plymouth).
- ✅ Branding assets: Orion logo (SVG + rendered PNG), four default wallpapers,
  boot splash, generated via `cairosvg`/`matplotlib`.
- ✅ Build / dev / test scripts under `scripts/` (reproducible on Arch host).

### Branded desktop (Phase 2)

- ✅ `desktop/orion-framework/` — shared Qt6 library: theme manager, design
  tokens, common QML components (`OrionButton`, `OrionCard`, `OrionListRow`,
  `OrionColor`, …), CMake build, unit tests.
- ✅ `desktop/shell/` — Orion Shell (KWin integration script + Orion session
  definition + shell QML root).
- ✅ `desktop/panel/` — taskbar: pinning, running apps via KWin, system tray,
  clock/calendar, quick-settings launcher, multi-monitor.
- ✅ `desktop/start-menu/` — search, pinned apps, all apps (from
  `applications.menu`), recent files, power controls.
- ✅ `desktop/settings/` — unified settings app across 7 categories.
- ✅ `desktop/file-manager/` — Explorer-like file manager with tabs, breadcrumb,
  list/icon views, copy/move/rename/delete, trash, mounts.
- ✅ `desktop/welcome-center/` — first-run experience.
- ✅ `desktop/software-center/` — PackageKit-based graphical package manager.
- ✅ `desktop/notifications/`, `desktop/quick-settings/`,
  `desktop/system-monitor/`, `desktop/update-manager/`,
  `desktop/screenshot-tool/`, `desktop/search/`, `desktop/lockscreen/`.

### Installer (Phase 3)

- ✅ `installer/` Calamares configuration (`settings.conf`, brand.desc,
  modules.conf, show.qml).
- ✅ Partitioning workflow, user setup, bootloader configuration.

### Themes (Phase 4)

- ✅ `themes/orion-dark`, `orion-light`, `orion-midnight`, `orion-aurora`,
  `orion-high-contrast` (JSON design tokens + GTK/Kvantum/SDDM references).

### Packaging, scripts, tests, CI

- ✅ `packaging/` PKGBUILD templates for every Orion component + repo helper.
- ✅ `scripts/` ISO build, env setup, QEMU test, dev-run, render-branding.
- ✅ `tests/` pytest unit tests for `orion-framework`, security scan, VM
  boot-test driver, integration smoke.
- ✅ `.github/workflows/` build-iso, desktop-tests, security-scan.

---

## What is NOT implemented (yet)

The following are explicitly **not** done and should not be claimed as complete:

1. **No ISO has been built or booted.** The sandbox has no `pacman`/`archiso`.
   The `scripts/build-iso.sh` is written correctly and will produce an ISO on a
   real Arch Linux host, but it has not been executed here.
2. **No virtual-machine test has been run.** The sandbox has no QEMU.
3. **No Qt6 application has been compiled locally.** The sandbox has no
   `cmake`/`ninja`/`qmake6`. Each desktop component includes a `CMakeLists.txt`
   and would build on an Arch host with `qt6-base`, `qt6-declarative`,
   `qt6-wayland`, `extra-cmake-modules`, and `cmake`/`ninja` installed.
4. **Custom Orion components for Plasma/KWin shell scripting are written as
   QML**, but they have not been visually verified against a running KWin
   session. They use the documented KWin shell API (`org.kde.kwin.*`,
   `org.kde.plasma.*`) but should be tested once a real KWin Wayland session is
   available.
5. **Orion Software Center uses PackageKit** as a privileged interface rather
   than executing pacman directly. This is the safe-by-default design; the
   `orion-software-center.service` polkit policy is included.
6. **AUR integration is opt-in and not enabled by default.** The Software
   Center presents AUR as an advanced source with explicit warnings.
7. **Secure Boot** is documented in `docs/security.md` but not pre-configured;
   pre-signed bootloader binaries require a signing key Orion does not yet own.
8. **Btrfs snapshot integration** uses the documented `snapper` configuration
   pattern; integration into the installer is documented but not yet
   automated end-to-end.

---

## Definition of Done — current assessment against §25

| Criterion | Status |
|---|---|
| Reproducible build process exists | ✅ `scripts/build-iso.sh` |
| ISO boots in a supported VM | ❌ Not executed in this sandbox |
| Installer can complete fresh install | ⚠️ Calamares config written, not executed |
| Installed system boots Orion desktop | ❌ Not executed |
| Taskbar/Start/Window mgmt/Settings work | ⚠️ Source written, not visually verified |
| Networking and audio work in test env | ❌ Not tested |
| File manager performs normal ops | ⚠️ Source written, not visually verified |
| Software install/remove via PackageKit | ⚠️ Code written, not executed |
| System updates work | ❌ Not tested |
| Admin authorization is secure | ✅ Polkit policies written |
| No known critical defects | ⚠️ No runtime testing yet |
| Install + recovery docs exist | ✅ `docs/installation.md`, `docs/troubleshooting.md` |
| Release includes checksums + limitations | ⚠️ Script ready, no artifact yet |

**Conclusion:** Phase 1 source is complete and reviewable. Phases 2–8 source is
written and structurally complete. Runtime verification is pending a real Arch
Linux build/test host.

---

## Next milestone

1. Acquire or provision a real Arch Linux build host (bare metal, VM, or
   container with `pacman` available via `arch-install-scripts`).
2. Run `scripts/setup-build-env.sh` to install `archiso`, `calamares`,
   `qt6-base`, `qt6-declarative`, `qt6-wayland`, `cmake`, `ninja`, `qemu`,
   `ovmf`.
3. Run `scripts/build-iso.sh`. Iterate on the Archiso profile until the ISO
   builds cleanly.
4. Run `scripts/test-iso-qemu.sh distro/archiso/out/orion-os-*.iso` and verify
   boot + installer + desktop bring-up under QEMU.
5. Capture SHA256 checksums, fill in `docs/release-process.md` per release.
6. Begin Phase 7 (performance + hardware compatibility) testing on real
   hardware.
