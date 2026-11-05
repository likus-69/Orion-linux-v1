# Orion OS — Installation

This document covers two scenarios:

1. **Building and installing Orion OS from this repository** (developer /
   release-engineering flow).
2. **Installing Orion OS from a prebuilt ISO** (end-user flow, once ISOs are
   published).

## 1. Build environment requirements

You need a real **Arch Linux** host (bare metal, a VM, or a sufficiently
privileged container — Debian/Ubuntu is *not* sufficient because Orion OS
depends on `pacman` and `archiso`).

Minimum:

- Arch Linux x86_64, fully up to date (`pacman -Syu`).
- 8 GB RAM (16 GB recommended; ISO build peaks at ~6 GB).
- 20 GB free disk for the build cache.
- Internet access for `pacman`.

Install build dependencies:

```bash
sudo pacman -S --needed base-devel git archiso calamares \
    qt6-base qt6-declarative qt6-wayland qt6-tools qt6-shadertools \
    extra-cmake-modules cmake ninja python python-pytest python-cairosvg \
    qemu-desktop ovmf texinfo
```

Verify versions:

```bash
mkarchiso --version
archiso --version || true
cmake --version | head -1
qmake6 --version | head -1
```

Run the automated env check:

```bash
./scripts/setup-build-env.sh
```

This script verifies versions, initializes the local Orion package repository
under `distro/repositories/x86_64/`, and creates the `work/` directory used by
`mkarchiso`.

## 2. Building the Orion OS ISO

From the repository root:

```bash
./scripts/build-iso.sh
```

This script:

1. Validates the Archiso profile (`distro/archiso/profiledef.sh`).
2. Builds every Orion component from `packaging/` into the local repo at
   `distro/repositories/x86_64/`.
3. Invokes `mkarchiso -v -w work/ -o out/ distro/archiso/`.
4. Computes SHA256 + SHA512 checksums of the resulting ISO.
5. Writes build metadata to `out/build-info.json` (build host, kernel
   version, package versions, build time).

Output:

```
distro/archiso/out/orion-os-<version>-x86_64.iso
distro/archiso/out/orion-os-<version>-x86_64.iso.sha256
distro/archiso/out/orion-os-<version>-x86_64.iso.sha512
distro/archiso/out/build-info.json
```

A typical build takes 25–60 minutes depending on hardware and network speed.

## 3. Testing the ISO in QEMU

```bash
./scripts/test-iso-qemu.sh distro/archiso/out/orion-os-<version>-x86_64.iso
```

This boots the ISO under `qemu-system-x86_64` with UEFI firmware (`OVMF`),
4 GB RAM, and a 32 GB virtual disk. The script then runs the Orion smoke test
inside the live session (network check, audio check, panel check, file
manager check) and reports results.

To stop QEMU, type `Ctrl-A X` or close the QEMU window.

## 4. Burning to a USB stick

On a Linux host:

```bash
# Replace /dev/sdX with the correct device. Verify with lsblk first!
lsblk
sudo dd if=distro/archiso/out/orion-os-<version>-x86_64.iso \
    of=/dev/sdX bs=4M conv=fsync oflag=direct status=progress
sync
```

**Warning:** `dd` to the wrong device will destroy data. Run `lsblk` before and
after plugging in the USB stick to confirm the device name.

## 5. Installing on real hardware

1. Boot from the USB stick. Select "Orion OS (live)" from the bootloader menu.
2. After the live desktop appears, click the "Install Orion OS" icon on the
   desktop, or run `orion-installer` from the Start Menu.
3. Follow the Calamares wizard:
   - **Welcome** → Choose language.
   - **Location** → Set timezone.
   - **Keyboard** → Choose layout.
   - **Partitions** → Guided (erase disk) or Manual.
     - Choose Btrfs (default) or ext4.
     - Optionally enable LUKS full-disk encryption.
     - Optionally enable Btrfs + snapper snapshots.
   - **Users** → Create the user account and computer name. The first user
     is automatically added to the `wheel` group for `sudo`.
   - **Summary** → Review; click **Install** to proceed.
4. The installer runs for ~5–15 minutes. On completion, click **Restart Now**.
5. Remove the USB stick when prompted. The system boots into Orion OS.

## 6. Post-installation

On first login, the Orion Welcome Center launches automatically. It guides the
user through:

- Network setup.
- Audio/display check.
- Software installation (Software Center introduction).
- Update configuration.
- Privacy and security settings.

The Welcome Center can be dismissed; it can be re-opened from
**Start → Settings → Welcome**.

## 7. Dual-boot with Windows

Orion OS supports dual-boot configurations where:

- Windows is installed first (recommended).
- A free partition or unallocated space exists for Orion OS.
- The user selects "Manual" partitioning in the installer.
- The installer installs systemd-boot (UEFI systems) alongside the existing
  Windows Boot Manager without overwriting it.

Orion OS does not modify the Windows Boot Manager. After installation, the
Orion bootloader entry appears alongside the Windows entry in the UEFI boot
menu. On some firmware, you may need to select Orion OS as the default boot
entry from the firmware settings.

## 8. Troubleshooting

See [`troubleshooting.md`](troubleshooting.md) for common issues:
- Black screen on boot.
- No Wi-Fi detected.
- Black screen after login.
- Installer fails to partition.
- NVIDIA driver issues.
- Audio not working.
- Encrypted disk recovery.

## 9. Uninstalling Orion OS

To remove Orion OS and reclaim the disk:

1. Boot from another OS installer (Windows installer, Ubuntu live USB, etc.).
2. Delete the Orion OS partitions (root, EFI, swap if dedicated).
3. Repair the bootloader of the remaining OS (e.g. `bcdboot` for Windows,
   `grub-install` for Linux).
4. Remove the Orion OS UEFI boot entry from the firmware if it remains.

If you used LUKS encryption, the deleted partitions are unrecoverable without
the LUKS passphrase — this is intentional.

## 10. Build host is not Arch — what now?

If your build host is Debian, Ubuntu, Fedora, etc., you have two options:

1. **Install Arch in a virtual machine** (recommended). Use any virtualization
   software (VirtualBox, VMware, KVM). Install Arch by following the official
   Arch installation guide, then proceed with the steps above.
2. **Use an Arch container** with `pacman` available (e.g. `archlinux`
   Docker image with bind-mounted `/dev`, `--privileged`). This is fragile;
   option 1 is more reliable.

The sandbox in which this repository was authored is a **Debian host without
pacman**, so option 1 (an Arch VM) is the supported path for the v1 build.
