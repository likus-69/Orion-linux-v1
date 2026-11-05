# Orion OS — Release Process

This document defines the procedure for cutting a signed, tested Orion OS
release ISO. It is the canonical reference for release engineers.

## 1. Release numbering

Orion OS uses **semver** with a distribution twist:

```
v<YEAR>.<MONTH>.<PATCH>
```

- `<YEAR>` and `<MONTH>` identify the release snapshot (rolling release).
- `<PATCH>` increments within a snapshot for critical fixes.

Example: `v2026.10.0` is the first release cut from the 2026-10 snapshot;
`v2026.10.1` is the first hotfix.

Pre-releases use a `-rc.N` suffix: `v2026.10.0-rc.1`.

## 2. Release engineer checklist

The release engineer (a member of `@orion-os/release-engineering`) follows this
checklist before tagging a release. **Every item must be checked.** No
shortcuts.

### 2.1 Source preparation

- [ ] `main` branch is green on CI: build-iso, desktop-tests, security-scan
  all pass.
- [ ] `STATUS.md` updated to reflect what is implemented in this release.
- [ ] `docs/changelog.md` (or release notes draft) lists user-visible changes
  since the previous release.
- [ ] All `TODO` and `FIXME` comments in code are either resolved or filed as
  issues and tagged for the next release.

### 2.2 Build environment

- [ ] Build host is Arch Linux, fully up to date (`pacman -Syu`).
- [ ] `scripts/setup-build-env.sh` runs cleanly.
- [ ] No local modifications to `distro/archiso/` beyond what is committed.
- [ ] Build host is not a long-running CI runner; for signed releases, the
  build host is a controlled workstation.

### 2.3 ISO build

- [ ] `./scripts/build-iso.sh` completes without error.
- [ ] The output ISO exists at `distro/archiso/out/orion-os-<version>-x86_64.iso`.
- [ ] The ISO is at most 4 GB (single-layer DVD size).
- [ ] `out/build-info.json` records the build host, kernel version, package
  versions, and build time.
- [ ] SHA256 and SHA512 checksums are generated.

### 2.4 Testing

- [ ] **Boot test:** ISO boots in QEMU (UEFI mode) using
  `./scripts/test-iso-qemu.sh`.
- [ ] **Boot test:** ISO boots in QEMU (legacy BIOS mode) — manually
  configured if BIOS support is in scope for the release.
- [ ] **Install test:** Calamares completes a full installation on the virtual
  disk.
- [ ] **Post-install boot:** Installed system boots into Orion desktop.
- [ ] **Network test:** Ethernet and Wi-Fi (using a USB passthrough or the
  QEMU user-mode network) work.
- [ ] **Audio test:** Speaker test tone plays and is captured.
- [ ] **Software Center test:** A small package installs and removes cleanly.
- [ ] **Update test:** `sudo pacman -Syu` on the installed system succeeds.
- [ ] **Encrypted install test:** LUKS install + boot + unlock succeeds.
- [ ] **Hardware test (if in scope):** Tested on at least one real Intel/AMD
  laptop and one real Intel/AMD desktop, per the matrix in §4.

### 2.5 Security verification

- [ ] `./scripts/security-scan.sh` reports zero high-severity findings on the
  ISO's filesystem.
- [ ] `find / -perm -4000 -type f` output matches the documented allowlist.
- [ ] `ss -tlnp` on a fresh install shows no remote listeners.
- [ ] `pacman-key --list-keys` includes the Orion signing key with the
  published fingerprint.
- [ ] No private keys, tokens, or passwords found in the ISO's filesystem
  (verified by the security scan).

### 2.6 Signing

- [ ] ISO signed with the Orion release signing key:
  ```bash
  gpg --armor --detach-sign \
      --local-user likus-69+release@users.noreply.github.com \
      distro/archiso/out/orion-os-<version>-x86_64.iso
  ```
  Produces `orion-os-<version>-x86_64.iso.asc`.
- [ ] SHA256SUMS and SHA512SUMS signed with the same key.
- [ ] Signing was performed on an air-gapped host or with a hardware-backed
  key; the private key never touched a network-connected host.

### 2.7 Publication

- [ ] ISO, checksums, and signature uploaded to the project's mirror.
- [ ] Mirror is reachable over HTTPS.
- [ ] Release page on the project site lists the version, release notes, known
  issues, system requirements, and SHA256SUMS.
- [ ] Torrent / magnet link (if used) seeded.
- [ ] Announcement posted to the project's blog / mailing list / chat.

### 2.8 Post-release

- [ ] `STATUS.md` updated with the new release version.
- [ ] `docs/changelog.md` finalized.
- [ ] Git tag created: `git tag -s v<version> -m "Orion OS v<version>"`.
- [ ] Tag pushed: `git push --tags`.
- [ ] Next release branch opened if needed.
- [ ] Lessons-learned retro scheduled within 1 week.

## 3. Hotfix releases

Hotfix releases (`v<YEAR>.<MONTH>.<PATCH+1>`) follow a shortened checklist:

- [ ] The fix is committed to `main` and backported to the active release
  branch.
- [ ] Build + QEMU boot + smoke tests pass.
- [ ] Security scan passes.
- [ ] ISO signed.
- [ ] Release notes clearly call out what was fixed and why.
- [ ] Users on the previous release are notified via the Update Manager.

Hotfix releases do **not** require a full hardware test matrix, but the release
notes must state this explicitly.

## 4. Hardware test matrix

For non-hotfix releases, the following hardware (or equivalent VM
configurations) must be tested:

| Class | Example | Required |
|---|---|---|
| Modern Intel laptop (iGPU) | ThinkPad X1 Carbon Gen 9+ | Required |
| Modern AMD laptop (iGPU) | Framework 13 AMD | Required |
| Modern Intel desktop (iGPU) | NUC 11+ | Required |
| Modern AMD desktop (iGPU) | Mini PC with Ryzen | Required |
| NVIDIA discrete GPU | A laptop or desktop with GTX/RTX | Required |
| Multi-monitor setup | 2+ displays | Required |
| HiDPI display | 4K @ 150% scaling | Required |
| Bluetooth audio | A2DP device | Required |
| Wi-Fi (Intel) | AX200/AX210 | Required |
| Wi-Fi (Realtek) | RTL8822CE | Required if known regressions |
| Printer (CUPS) | A common USB/network printer | Required |
| Older hardware (≥5 years) | At least one | Recommended |

Results are recorded in `docs/hardware-test-results/<version>.md`.

## 5. Snapshot + rollback strategy

Orion OS supports Btrfs snapshots via `snapper`. The default configuration:

- A `@/.snapshots` subvolume on the root filesystem.
- `snapper` takes a snapshot before every `pacman -Syu` (via a pacman hook).
- Snapshots are listed in the bootloader; the user can boot into a previous
  snapshot if an update breaks the system.

**Snapshots are not backups.** They live on the same disk as the live
filesystem; disk failure loses both. The Welcome Center recommends
**independent backups** (to an external disk or remote storage).

The Update Manager shows the most recent snapshots and offers a "Roll back to
this snapshot" action that (a) marks the chosen snapshot as the default boot
entry and (b) reboots into it. After verifying the rollback works, the user
can promote the snapshot to the live filesystem.

## 6. ISO verification instructions for users

Users verify a downloaded ISO with:

```bash
# Verify the checksum
sha256sum -c orion-os-<version>-x86_64.iso.sha256

# Verify the signature (requires the Orion signing key in your keyring)
gpg --verify orion-os-<version>-x86_64.iso.asc orion-os-<version>-x86_64.iso
```

If the signature is valid, GPG prints `Good signature from "Orion OS Release
Signing Key <likus-69+release@users.noreply.github.com>"`. The fingerprint must match the
fingerprint published in `docs/security.md` and on the project's HTTPS site.

## 7. Mirroring and bandwidth

The project does not run its own CDN. Mirrors are community-operated. The
release page lists mirrors with their location and HTTPS availability. Users
are encouraged to verify the signature even when downloading from a mirror —
the signature is the trust anchor, not the mirror's HTTPS certificate.

## 8. End-of-life policy

Because Orion OS is rolling, individual releases do not go "end of life" in
the traditional sense. However:

- The last 3 release snapshots remain available for download.
- Older snapshots are moved to an archive mirror.
- Critical security fixes are backported to the last 3 snapshots.
- Users are encouraged to stay on the latest snapshot.

A point-release series (`v2026.10.x`) is supported with security fixes for 6
months after the next snapshot is released.
