# Orion OS — System Architecture

This document describes the layered architecture of Orion OS, the rationale
for each major technical choice, and the integration boundaries between
components. It is the canonical reference for "why does Orion OS look the way
it does?".

## 1. Layered model

```
┌──────────────────────────────────────────────────────────────────────┐
│                      User-facing Orion applications                   │
│  Settings • File Manager • Software Center • Welcome • Notifications │
│  Quick Settings • System Monitor • Update Manager • Screenshot • Search│
└───────────────────────────────┬──────────────────────────────────────┘
                                │  Qt6/QML + orion-framework
┌───────────────────────────────┴──────────────────────────────────────┐
│                       Orion Desktop (Shell)                          │
│   Panel • Start Menu • Lock Screen • Window mgmt (via KWin API)      │
└───────────────────────────────┬──────────────────────────────────────┘
                                │  Wayland protocol + KWin D-Bus
┌───────────────────────────────┴──────────────────────────────────────┐
│                     Wayland compositor (KWin)                        │
│   Plasma shell integration, decoration, input, multi-monitor          │
└───────────────────────────────┬──────────────────────────────────────┘
                                │  D-Bus + systemd user services
┌───────────────────────────────┴──────────────────────────────────────┐
│                       System services layer                          │
│  systemd • NetworkManager • PipeWire • WirePlumber • polkit           │
│  PackageKit • logind • udev • rtkit • accountsservice                │
└───────────────────────────────┬──────────────────────────────────────┘
                                │  glibc + pacman
┌───────────────────────────────┴──────────────────────────────────────┐
│                        Arch Linux base                               │
│   Linux kernel • systemd init • pacman • coreutils • util-linux      │
└───────────────────────────────┬──────────────────────────────────────┘
                                │  UEFI firmware + bootloader
┌───────────────────────────────┴──────────────────────────────────────┐
│              Bootloader (systemd-boot or GRUB) • initramfs            │
└──────────────────────────────────────────────────────────────────────┘
```

## 2. Foundation choices and rationale

### 2.1 Base distribution: Arch Linux

**Decision:** Build on Arch Linux, not Debian, Fedora, or an independent
distribution.

**Rationale:** Arch's rolling-release model, transparent packaging, `PKGBUILD`
build recipes, and the Arch User Repository (AUR) provide the cleanest surface
on which to layer a custom desktop distribution. Arch's bias toward upstream
configuration minimizes fork risk: Orion-specific changes are layered on top of
a vanilla base, not buried in patches. `archiso` provides the canonical image
builder used by the upstream `archlinux.iso` and is actively maintained.

**Trade-offs:** Rolling release means occasional breakage on `pacman -Syu`.
Orion OS mitigates this with tested release snapshots, `snapper` Btrfs
snapshots, and a documented update-deferral workflow (see
`docs/release-process.md`). Security updates are prompt but require the user to
actually run them; Orion Update Manager provides reminders and a one-click
update path.

### 2.2 Init system: systemd

**Decision:** Use systemd without alternatives.

**Rationale:** Every Orion desktop component relies on D-Bus and systemd user
services. `systemd-logind` provides session, seat, and power management.
`systemd-resolved` and `systemd-networkd` are available but **not** enabled by
default (NetworkManager is preferred for desktop use). systemd is the only init
system the upstream Arch packages actually test against; replacing it would
multiply maintenance cost for no benefit.

### 2.3 Display server: Wayland (X11 as fallback)

**Decision:** Wayland primary, XWayland for legacy X11 applications.

**Rationale:** Wayland is the default for Plasma/KDE, GNOME, and most modern
desktops. X11 is still needed for legacy applications and games; `xorg-xwayland`
is installed by default. The Orion components themselves use Qt 6's Wayland
integration and never speak X11 directly.

### 2.4 Compositor: KDE KWin

**Decision:** Use KWin as the initial compositor, rather than writing a custom
Wayland compositor.

**Rationale:** KWin is the most mature, accessible Wayland compositor with
first-class desktop-shell support, multi-monitor handling, and a documented
scripting interface (KWin scripts + the `org.kde.kwin.*` D-Bus API). Writing a
custom compositor would consume years of engineering and still be inferior to
KWin for desktop use. Orion's identity is established through **shell
components** (panel, start menu, settings, file manager) layered on top of
KWin, not through replacing KWin itself.

**Migration path:** The architecture intentionally isolates Orion components
behind D-Bus interfaces and well-documented QML contracts, so a future
"OrionCompositor" can replace KWin without rewriting every Orion application.

### 2.5 UI framework: Qt 6 / QML

**Decision:** Qt 6 with QML for all Orion-branded desktop applications.

**Rationale:** Qt 6 is the only toolkit that (a) integrates natively with KWin,
(b) supports both native C++ business logic and declarative UI, (c) provides a
strong accessibility story via `Qt Accessibility`, and (d) is actively
maintained upstream by KDE, the Qt Company, and the broader community. Using a
single toolkit for all Orion apps keeps visual consistency, accessibility
behavior, and theming coherent. Introducing GTK or Electron would fragment the
design system and accessibility story.

### 2.6 Audio: PipeWire + WirePlumber

**Decision:** PipeWire as the audio server, WirePlumber as the session manager.

**Rationale:** PipeWire is the modern Linux audio/video server, supersedes
PulseAudio for audio and provides a Jack-compatible interface for pro audio.
WirePlumber is its default session manager. Both are upstream defaults on Arch
and provide a unified API that Orion's Quick Settings and Settings app can
target.

### 2.7 Network: NetworkManager

**Decision:** NetworkManager (not systemd-networkd, not netctl).

**Rationale:** NetworkManager has the best desktop integration, the broadest
hardware support, and a stable D-Bus API that Orion Settings and Quick Settings
can drive. VPN plugins are widely available.

### 2.8 Privilege escalation: polkit + sudo

**Decision:** polkit for desktop authorization, `sudo` for command-line
authorization. No `pkexec` for long-running services.

**Rationale:** polkit provides rules-based authorization with a per-action
prompt UI, which is the right model for desktop operations (mount a disk,
install a package, change the timezone). `sudo` remains the right model for
command-line administrative work. Orion never runs a desktop component as root.

### 2.9 Package management: pacman + PackageKit

**Decision:** pacman for the underlying database and CLI; PackageKit as the
privileged interface for GUI applications; `archlinux-keyring` and an Orion
keyring for signing.

**Rationale:** PackageKit abstracts the package manager behind a D-Bus
interface, allowing the Orion Software Center to install, remove, and update
packages without shelling out to pacman as root. PackageKit runs as a system
service with its own polkit policies; the GUI never escalates privileges on its
own. The Orion repository is signed with an Orion-controlled key and verified
by `pacman-key` at install/update time.

### 2.10 Installer: Calamares (customized)

**Decision:** Calamares with Orion branding, partitioning, user-setup, and
post-install modules.

**Rationale:** Calamares is the installer used by many Arch derivatives
(Manjaro, KaOS, Garuda) and by independent distributions (Lubuntu, Kubuntu
flavors). It is mature, actively maintained, and supports custom branding and
partitioning workflows. Building a custom installer would be a large cost with
no benefit over Calamares for the v1 release.

### 2.11 Filesystem: Btrfs default, ext4 available

**Decision:** Default to Btrfs on the root partition; offer ext4 during
installation; support LUKS full-disk encryption for both.

**Rationale:** Btrfs enables snapshots (via `snapper`), transparent
compression, and easy rollback for the rolling-release model. ext4 remains
the safest choice for users with specific compatibility needs. LUKS encryption
is offered but not forced.

### 2.12 Bootloader: systemd-boot (UEFI) / GRUB (legacy BIOS)

**Decision:** systemd-boot on UEFI systems (the default for new hardware); GRUB
on legacy BIOS systems where practical.

**Rationale:** systemd-boot is simpler, faster, and the upstream Arch default
for UEFI. GRUB remains necessary for legacy BIOS and some niche configurations.
The installer chooses based on the boot mode detected at install time.

## 3. Process and privilege model

| Component | Runs as | Authority |
|---|---|---|
| Orion Shell | user | Owns the Wayland session |
| Orion Panel, Start Menu, etc. | user | D-Bus calls to KWin, logind, NetworkManager |
| Orion Software Center GUI | user | D-Bus to `packagekitd` (system service) |
| `packagekitd` | root (system service) | polkit-controlled package operations |
| Orion Settings GUI | user | D-Bus to `timedated`, `hostnamed`, `networkd`, `accountsservice` |
| Orion Update Manager | user | D-Bus to `packagekitd` |
| NetworkManager | root (system service) | polkit for connection changes |
| PipeWire (system instance) | root (system service) | Limited; per-user session owns audio routing |
| WirePlumber (user instance) | user | Audio session management |
| polkit daemon | root (system service) | Authorization decisions only |

## 4. Inter-process communication

- **D-Bus (system bus):** for system services (NetworkManager, PackageKit,
  logind, timedated, hostnamed, `org.kde.kwin.*` where relevant).
- **D-Bus (session bus):** for Orion desktop components to talk to each other
  (`org.orion.Panel`, `org.orion.StartMenu`, `org.orion.Notifications`, …).
- **Wayland protocols:** for the shell ↔ compositor relationship.
- **systemd user services:** each Orion desktop component that runs in the
  background (Panel, Notifications, Update Manager, Quick Settings) is a systemd
  user unit so it is restartable, journalable, and ordered with the session.

## 5. Configuration storage

| Class | Location | Notes |
|---|---|---|
| Distribution defaults | `/usr/share/orion/defaults/` | Read-only; copied on first run if missing |
| Per-user Orion settings | `~/.config/orion/` | JSON; never binary |
| Per-user state (panel pins, recents) | `~/.local/state/orion/` | JSON |
| Cache (thumbnails, search index) | `~/.cache/orion/` | Disposable |
| System-wide Orion settings (admin) | `/etc/orion/` | Optional overrides; documented in `docs/administration.md` |

## 6. Build pipeline (high level)

1. `scripts/setup-build-env.sh` installs build deps on an Arch host.
2. `scripts/build-iso.sh` invokes `mkarchiso` with `distro/archiso/`.
3. `mkarchiso` reads `profiledef.sh`, `packages.x86_64`, `pacman.conf`,
   applies `airootfs` customizations, installs Orion packages from a local
   repo (built from `packaging/`), builds the bootable ISO.
4. `scripts/test-iso-qemu.sh` boots the ISO in QEMU and runs the
   installation smoke test.
5. `scripts/release.sh` (planned) tags the release, signs the ISO, and
   publishes checksums.

## 7. Future migration paths

- **Independent compositor:** The Orion components never assume KWin-specific
  D-Bus interfaces without a fallback. A future `orion-compositor` (Rust +
  Smithay, or C++ + wlroots) can replace KWin once it reaches feature parity.
- **Independent installer:** If Calamares drifts away from Orion's needs, the
  configuration in `installer/` is sufficiently isolated to allow replacement.
- **Non-x86_64 architectures:** The Archiso profile targets `x86_64`. ARM64 is
  a planned future target once the kernel and firmware packages stabilize.
