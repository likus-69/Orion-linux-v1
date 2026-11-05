# Orion OS — Security Model

This document describes Orion OS's security architecture: the trust model, the
privilege boundaries, the threat model, and the security defaults enforced at
install time. It is the canonical reference for "what is Orion OS protecting
against, and how?".

## 1. Trust model

| Principal | Trusted to | Not trusted to |
|---|---|---|
| End user (logged-in user account) | Make changes to their own session; install packages via Software Center (with auth); configure personalization | Modify system files without auth; read other users' files; escalate to root |
| Administrator (member of `wheel` group) | Use `sudo` to install packages, modify system services, change system config | Bypass Secure Boot; modify signed package metadata; install unsigned packages by default |
| Orion project (release engineer) | Sign Orion package repository metadata; publish ISOs with checksums | Embed secrets in artifacts; bypass package verification; ship proprietary code without license |
| Upstream Arch packagers | Sign packages in the official repositories with their personal keys | Sign Orion packages; access the Orion signing key |
| Local network peer | None | None — Orion enables no network services by default |
| Application installed by user | Run as the user; access user-owned files; access the network via the user's profile | Read other users' files; access the microphone/camera without a Flatpak portal; modify system services |

## 2. Privilege boundaries

```
┌─────────────────────────────────────────────────────────────┐
│  User session (Wayland compositor, Orion Shell, apps)      │  unprivileged
├─────────────────────────────────────────────────────────────┤
│  systemd --user, PipeWire (user), WirePlumber, polkit-agent │  unprivileged
├─────────────────────────────────────────────────────────────┤
│  D-Bus session bus                                          │  unprivileged
└───────────────────────┬─────────────────────────────────────┘
                        │   polkit requests cross the line here
┌───────────────────────┴─────────────────────────────────────┐
│  D-Bus system bus, polkitd                                  │  privileged
├─────────────────────────────────────────────────────────────┤
│  systemd, NetworkManager, PackageKit, logind, accountsservice│  privileged
├─────────────────────────────────────────────────────────────┤
│  Linux kernel, initramfs, LUKS, UEFI firmware               │  privileged
└─────────────────────────────────────────────────────────────┘
```

The single most important boundary is the user/root line. Every Orion desktop
component runs as the user. Privileged operations cross the line via **polkit**
or **sudo**, never via `pkexec` of an arbitrary binary and never by the GUI
process running as root.

## 3. Threat model

### In scope

1. **Local unprivileged attacker.** A user with shell access to a non-admin
   account should not be able to read another user's files, escalate to root,
   or persist across reboots.
2. **Network attacker on the local network.** Orion OS enables **no** listening
   network services by default. SSH is off. Avahi is off unless explicitly
   enabled. A network attacker cannot reach Orion processes.
3. **Malicious application.** A user-installed application (from AUR, a third
   party, or even the official repos) should be confined to the user's session.
   Flatpak is offered as the preferred confinement model for graphical apps;
   non-Flatpak apps are confined only by file permissions.
4. **Malicious package.** A package with a forged signature must not install.
   `pacman-key` verifies both the Arch keyring and the Orion keyring. The Orion
   signing key fingerprint is published in this document.
5. **Boot-time attacker with physical access.** LUKS full-disk encryption
   protects data at rest. Secure Boot (where configured) protects the boot
   chain. Recovery from a lost LUKS passphrase is documented and intentionally
   **not** easy — there is no backdoor.

### Out of scope (explicitly)

1. **A root-compromised host.** Once root is compromised, all bets are off;
   this document does not protect against post-root-compromise persistence.
2. **State-level adversaries** with hardware implant capability. Orion OS is
   not hardened for that threat; consider Qubes OS for that profile.
3. **Coercion of the user.** Orion OS does not provide plausible deniability.
4. **Firmware-level compromise** (Intel ME, AMD PSP). Orion OS cannot mitigate
   these.

## 4. Security defaults

These defaults are applied by the Archiso profile and by the Calamares
post-install module. They are documented in
[`distro/defaults/`](../distro/defaults/) and verifiable via
`scripts/security-scan.sh`.

### Accounts

- The default user is in the `wheel` group; `sudo` requires a password.
- The `root` account is **locked** by default (`passwd -l root`). Use `sudo`.
- No guest account. No auto-login (unless explicitly chosen in the installer).

### Network services

- **No** network listeners by default. Verify with:
  ```bash
  ss -tlnp
  # Should be empty or limited to 127.0.0.1
  ```
- `sshd` is **not** installed in the live ISO or by the installer. Users who
  want SSH install it explicitly: `sudo pacman -S openssh && sudo systemctl
  enable --now sshd`.
- Avahi (mDNS) is installed but **disabled** by default.
- CUPS (printing) is installed but **disabled** by default; the Orion Settings
  "Printers" page enables it on first interaction.

### Filesystem

- `/home`, `/root`, `/etc`, `/var` are `0755` for directories and `0644` for
  files by default. Per-user files in `~/.config`, `~/.local`, `~/.cache`
  follow XDG defaults.
- `/boot` is `0755`; kernel images are `0644`.
- `/tmp` is `tmpfs` (memory) and `1777` (sticky world-writable).
- The default umask is `022`.
- SUID binaries are limited to the standard upstream set; `find / -perm -4000`
  should produce a short, well-known list.

### Polkit

- `org.orion.softwarecenter.install` — auth_admin_keep (15 minutes) for
  `wheel` members.
- `org.orion.softwarecenter.remove` — auth_admin_keep (15 minutes) for
  `wheel` members.
- `org.orion.softwarecenter.updates` — auth_admin_keep (15 minutes) for
  `wheel` members.
- `org.orion.softwarecenter.aur` — auth_admin (single prompt, not cached)
  for `wheel` members. AUR packages are explicitly opt-in.
- `org.orion.settings.timezone` — auth_admin_keep for `wheel` members.
- `org.orion.settings.hostname` — auth_admin_keep for `wheel` members.
- `org.orion.settings.locale` — auth_admin_keep for `wheel` members.

### Package signing

- `pacman-key` is initialized at first boot with the `archlinux-keyring`
  package and the `orion-keyring` package.
- `SigLevel` in `/etc/pacman.conf` requires `Required DatabaseOptional` for the
  Arch repositories and `Required` for the Orion repository.
- The Orion signing key fingerprint (planned; placeholder until first
  release):
  ```
  Orion OS Release Signing Key <likus-69+release@users.noreply.github.com>
  Fingerprint: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
  ```
  (The actual fingerprint is published with the first signed release; this
  document is updated at that time. Until then, the Orion repository is built
  locally on the build host and is not signed for distribution.)

### Disk encryption

- LUKS2 is the supported full-disk encryption format.
- The installer offers LUKS at partitioning time. The user must enter the
  passphrase; Orion never generates one automatically.
- The LUKS header is on the same partition as the encrypted data (standard LUKS
  configuration). Header backup is documented in `docs/troubleshooting.md`.

### Boot chain

- UEFI mode is preferred. The installer installs systemd-boot to the EFI
  System Partition.
- `kernel_lockdown` is enabled where the kernel supports it.
- `module.sig_enforce` is **not** enabled by default; doing so would break
  out-of-tree drivers (NVIDIA). Users who want a fully enforced boot chain
  can opt in via kernel command-line parameters; the trade-off is documented.
- Secure Boot is **documented** in §6 below; pre-signed bootloader binaries
  are a future release-engineering goal.

### Audit and logging

- `systemd-journald` is on; persistent journal storage is enabled
  (`/var/log/journal/`).
- The default retention is 30 days or 500 MB, whichever comes first.
- `auditd` is **not** enabled by default to avoid log-noise overhead; advanced
  users can install it via the Software Center.
- Failed `sudo` attempts are logged to `/var/log/auth.log` via
  `systemd-journal`.

### Secrets

- **No** private keys, tokens, or passwords are stored in this repository or
  in the ISO.
- The Orion package signing key lives on an air-gapped or hardware-backed
  key storage device controlled by the release engineer. The key is **never**
  on a network-connected host, and **never** in CI.
- CI uses repository-scoped secrets (e.g. GitHub Actions secrets) only for
  publishing artifacts, never for package signing.

## 5. Telemetry

**Orion OS collects no telemetry by default.** There is no opt-out toggle
because there is no opt-in toggle either. The Welcome Center explains this
explicitly on first run.

If a future release introduces optional telemetry, it will be:

- **Off** by default.
- **Opt-in** by an explicit toggle in Settings → Privacy.
- **Documented** at https://github.com/likus-69/Orion-linux-v1.1/blob/main/docs/telemetry.md (placeholder).
- **Anonymous** — no machine IDs, no MAC addresses, no IP logging.
- **Auditable** — the data submission code is open source and the collected
  payloads are visible in `~/.local/state/orion/telemetry/` before submission.

## 6. Secure Boot (future work)

Secure Boot configuration is a release-engineering goal, not a current default.
When configured, the chain is:

1. Platform Key (PK) — owned by Orion OS, installed in firmware at install time
   (requires user consent + firmware password reset).
2. Key Exchange Key (KEK) — also owned by Orion OS.
3. Signed bootloader (systemd-boot) — signed with the Orion KEK.
4. Signed kernel + initramfs — signed with the Orion KEK.
5. Kernel module signature enforcement — optional, opt-in.

The Orion PK/KEK is **not** the Microsoft PK/KEK. Users keep Microsoft's PK
alongside Orion's so dual-boot with Windows remains possible. Removing
Microsoft's PK is the user's choice, made in firmware setup, not in Orion OS.

This is **not** the default for v1 because (a) it requires a PKI Orion does
not yet own, (b) it requires per-release signing infrastructure, and (c) it
adds user friction at install time. The architecture supports it; the
operational rollout is tracked as a separate milestone.

## 7. Disclosure PGP key

Vulnerability reports are PGP-encrypted to:

```
Orion OS Security <likus-69+security@users.noreply.github.com>
Fingerprint: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
```

Until a real key is generated and published, plain email is acceptable.

## 8. Hardening checklist before release

Before any ISO is published:

- [ ] `scripts/security-scan.sh` passes (no secrets, no world-writable config
  files, no SUID binaries outside the standard set).
- [ ] `pacman-key --list-keys` includes the Orion signing key with the
  published fingerprint.
- [ ] `ss -tlnp` on a fresh install shows no remote listeners.
- [ ] `find / -perm -4000` output matches the documented allowlist.
- [ ] `polkit` policies reviewed and unchanged from the previous release
  (changelog required for any change).
- [ ] LUKS test install succeeds and the system boots after passphrase entry.
- [ ] No AUR helper is preinstalled.
- [ ] `archlinux-keyring` and `orion-keyring` are current at build time.

## 9. Known limitations

- **App confinement is limited.** Non-Flatpak applications are confined only
  by UNIX file permissions. Users running untrusted code should use Flatpak or
  a virtual machine.
- **No SELinux/AppArmor by default.** Orion OS does not ship SELinux policies
  or AppArmor profiles; this is a future hardening target.
- **Secure Boot is not enforced** in v1. See §6 above.
- **Btrfs snapshots are not a security boundary.** A snapshot does not protect
  against compromise; it provides rollback for broken updates only.
