# Orion OS — Troubleshooting

This document covers the most common issues users encounter with Orion OS, and
how to resolve them. If your issue is not listed, file a bug report (see
[`CONTRIBUTING.md`](../CONTRIBUTING.md)).

## 1. Boot problems

### 1.1 Black screen on boot (live ISO)

**Symptoms:** After selecting "Orion OS" in the bootloader, the screen goes
black and stays black.

**Diagnosis:**

- Try the "Orion OS (safe graphics)" entry in the bootloader menu. This boots
  with `nomodeset` which uses basic framebuffer graphics.
- Press `e` in the bootloader menu to edit the kernel command line; add
  `nomodeset` and press `Ctrl-X` to boot.

**Common causes:**

- NVIDIA GPU without the `nvidia` driver loaded. The live ISO uses `nouveau`
  by default; install the proprietary driver post-install if needed.
- Old Intel/AMD GPU not supported by the current kernel's modesetting driver.
- Display connected to a USB-C dock that the kernel doesn't recognize early.

### 1.2 Boot loop after installation

**Symptoms:** The installed system reboots repeatedly before reaching the login
screen.

**Diagnosis:**

- Boot the live ISO, mount the installed root partition, and inspect
  `/var/log/journal/` (via `journalctl --root=/mnt`).
- Verify `/etc/fstab` references the correct partitions (`lsblk -f`).
- Verify the kernel and initramfs exist in `/boot`.

### 1.3 "operating system not found" after install

**Cause:** The bootloader was installed to the wrong disk, or the UEFI boot
entry was not created.

**Fix:**

1. Boot the live ISO.
2. Identify the EFI System Partition: `lsblk -f` (look for `vfat` partition,
   typically 512 MB).
3. Mount it: `sudo mount /dev/sdXN /mnt/efi`.
4. Reinstall systemd-boot: `sudo bootctl install --esp-path=/mnt/efi`.
5. Reboot and select Orion OS in the firmware boot menu.

## 2. Display problems

### 2.1 Display scaling is wrong

**Symptoms:** Text is too small/large on a HiDPI display.

**Fix:** Start Menu → Settings → System → Display → Scaling. Choose 100%,
125%, 150%, or 200%. For fractional scaling on Wayland, enable
"Experimental fractional scaling" (this uses the `KWIN_DRM_USE_BUFFER_AGE=1`
mechanism; document known issues if any).

### 2.2 Multi-monitor layout is wrong

**Symptoms:** External monitor doesn't appear; monitors are mirrored when they
shouldn't be; arrangement is wrong.

**Fix:** Start Menu → Settings → System → Display. Drag monitors to match the
physical arrangement. If a monitor doesn't appear, click **Detect**; if it
still doesn't appear, the GPU driver may not support it.

### 2.3 Screen tearing

**Symptoms:** Horizontal tearing during video playback or scrolling.

**Fix:**

- Settings → Personalization → Animations: ensure "Use compositor" is on.
- If you have an NVIDIA GPU, ensure `nvidia-drm.modeset=1` is in the kernel
  command line (`/etc/default/grub` for GRUB; `loader/entries/*.conf` for
  systemd-boot).
- For Intel/AMD on Wayland, tearing should not occur with the default
  settings.

## 3. Audio problems

### 3.1 No audio

**Diagnosis:**

1. Settings → System → Sound → Output. Verify the correct device is selected.
2. Open a terminal and run `pw-top`. The `PIPEWIRE` daemon should be running
   and showing your output device.
3. Run `wpctl status` to see the WirePlumber state.
4. Run `pactl list cards` to verify PipeWire's PulseAudio compatibility layer
   sees your hardware.

**Common fixes:**

- If the device is muted at the ALSA level: `alsamixer`, press `F6` to select
  your card, and unmute (`M` toggles).
- If `wireplumber` is not running: `systemctl --user enable --now
  wireplumber.service`.

### 3.2 Audio crackles / dropouts

**Cause:** Real-time audio priority is not configured, or the kernel is the
default kernel without `rtkit` working.

**Fix:**

- Verify `rtkit-daemon.service` is running: `systemctl status rtkit-daemon`.
- Verify the user is in the `realtime` group: `id $USER`. If not, run `sudo
  usermod -aG realtime $USER` and log out / back in.

### 3.3 Bluetooth audio doesn't connect

**Fix:**

- Settings → Devices → Bluetooth → ensure it is on.
- Pair the device.
- If the device pairs but doesn't appear as an audio output, install
  `pulseaudio-bluetooth`-equivalent: `sudo pacman -S pipewire-pulse` (already
  installed by default; verify).

## 4. Network problems

### 4.1 Wi-Fi not detected

**Diagnosis:**

1. `nmcli device status` — should list `wlan0` or similar.
2. `lspci -nnk | grep -iA3 net` — confirm the wireless card is detected and
   has a kernel driver in use.
3. `rfkill list` — verify the wireless isn't soft- or hard-blocked.

**Common causes:**

- The kernel doesn't ship the firmware for your card. Install the
  `linux-firmware` package (already in the ISO; might be missing on a custom
  kernel).
- The card is hard-blocked (physical switch on the laptop).
- The card requires the `broadcom-wl-dkms` driver (Broadcom cards).

### 4.2 Ethernet doesn't get an IP

**Fix:**

- `nmcli device connect eth0` — bring up the interface.
- Verify DHCP: `dhclient -v eth0` (if NetworkManager fails).
- Check the cable, the switch port, the link light.

### 4.3 VPN doesn't connect

**Fix:**

- NetworkManager supports OpenVPN, WireGuard, and others via plugins. Install
  the plugin: `sudo pacman -S networkmanager-openvpn` (or `-wireguard`,
  `-strongswan`).
- Restart NetworkManager: `sudo systemctl restart NetworkManager`.
- Re-add the VPN in Settings → Network → VPN.

## 5. Installation problems

### 5.1 Installer freezes on "Partitioning"

**Cause:** The disk is busy, or has a stale partition table.

**Fix:**

- Close any file managers that may have the disk mounted.
- Run `lsblk -f` and `findmnt` to confirm the disk is not mounted.
- Run `sudo wipefs -a /dev/sdX` to wipe stale signatures. **This destroys
  data — verify the device name first.**

### 5.2 Installer fails to install bootloader

**Cause:** The EFI System Partition is missing or too small, or the system is
in legacy BIOS mode without GRUB being selected.

**Fix:**

- Verify boot mode: `ls /sys/firmware/efi` exists → UEFI mode.
- In the installer's partitioning step, ensure there is an EFI System
  Partition of at least 512 MB, FAT32, with the `boot`/`esp` flag.
- On legacy BIOS systems, ensure a BIOS boot partition (1 MB, no filesystem,
  `bios_grub` flag) exists if using GPT.

### 5.3 Installer partitioning destroys the wrong disk

**Prevention:** The installer shows the disk's model name, size, and any
existing partitions before any destructive action. **Read this screen
carefully.** The installer prompts for explicit confirmation before any
destructive operation; type the disk's path verbatim to confirm.

If this happens by accident: stop. Do not write anything to the disk. Boot
from a recovery ISO and use `testdisk` or `photorec` to attempt recovery.
Orion OS does not provide a guaranteed recovery path for accidentally wiped
disks — backups are your responsibility.

## 6. LUKS / encryption recovery

### 6.1 Forgot LUKS passphrase

**Reality:** There is no recovery mechanism. LUKS is designed this way. If you
genuinely forgot the passphrase, the data is gone. If you remember it later,
the data is fine.

**Prevention:** Add a second LUKS passphrase slot to a key file stored
offline:

```bash
sudo cryptsetup luksAddKey /dev/sdXN /root/luks-recovery.key
# Store /root/luks-recovery.key offline (USB stick in a safe).
```

### 6.2 LUKS header is corrupted

**Cause:** Disk corruption, accidental `dd` to the start of the partition.

**Recovery:** If you have a LUKS header backup:

```bash
sudo cryptsetup luksHeaderRestore /dev/sdXN --header-backup-file luks-header.bin
```

**To make a header backup before disaster:**

```bash
sudo cryptsetup luksHeaderBackup /dev/sdXN --header-backup-file luks-header.bin
# Store offline. DO NOT lose this — it allows offline brute-force.
```

## 7. NVIDIA / GPU problems

### 7.1 Black screen with NVIDIA after `pacman -Syu`

**Cause:** Kernel was updated but `nvidia-dkms` did not rebuild against the
new kernel (usually because `dkms` package or `linux-headers` is missing).

**Fix:**

```bash
sudo pacman -S linux-headers dkms
sudo dkms autoinstall
sudo mkinitcpio -P
```

### 7.2 Nouveau driver crashes

**Fix:** Switch to the proprietary driver:

```bash
sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils
sudo systemctl reboot
```

### 7.3 Game runs slower than expected

**Diagnosis:**

- Verify Vulkan is available: `vulkaninfo | head -20`.
- Verify the correct driver is loaded: `glxinfo | grep "OpenGL renderer"`.
- For NVIDIA, ensure `nvidia-drm.modeset=1` is in the kernel command line.
- For Steam games, install `steam` and `proton-ge` (from AUR if desired).

## 8. Software Center problems

### 8.1 "Cannot contact PackageKit"

**Cause:** The `packagekit` system service is not running.

**Fix:**

```bash
sudo systemctl enable --now packagekit
```

### 8.2 AUR installation fails

**Cause:** AUR build scripts are community-maintained and may fail at build
time. Orion OS does not preinstall an AUR helper.

**Fix:** Read the build output. If the package is broken, contact the AUR
maintainer. If you need a specific package, consider installing it manually:

```bash
git clone https://aur.archlinux.org/<package>.git
cd <package>
makepkg -si
```

### 8.3 "Database is locked"

**Cause:** A previous `pacman` operation crashed or was interrupted.

**Fix:**

```bash
sudo rm /var/lib/pacman/db.lck
sudo pacman -Syu
```

**Do not** delete the lock if `pacman` is running.

## 9. Performance problems

### 9.1 Slow boot

**Diagnosis:** `systemd-analyze blame` shows the slowest units. `systemd-analyze
critical-chain` shows the dependency chain.

**Common fixes:**

- Disable `NetworkManager-wait-online.service` if you don't need to wait for
  network before login: `sudo systemctl disable NetworkManager-wait-online`.
- Disable `fwupd.service` if you don't use firmware updates.
- Disable the Welcome Center autostart if you've dismissed it: Settings →
  Personalization → Autostart.

### 9.2 High idle memory usage

**Diagnosis:** `ps aux --sort=-%mem | head -20` shows the top consumers.

**Common causes:**

- Baloo (file indexer) — disable in Settings → Personalization → Search.
- The Welcome Center running in the background after dismissal — kill it.
- A misbehaving Flatpak app — kill it.

## 10. Recovery mode

### 10.1 Booting into single-user mode

In the bootloader menu, press `e` to edit the boot entry, append
`systemd.unit=rescue.target` to the kernel command line, and press `Ctrl-X`.
This boots to a root shell without networking or graphical interface.

### 10.2 Chrooting from a live ISO to repair an installed system

```bash
# Boot the Orion OS live ISO, then:
sudo mount /dev/sdXN /mnt          # root partition
sudo mount /dev/sdYM /mnt/efi      # EFI System Partition (if UEFI)
sudo arch-chroot /mnt
# Now you're in the installed system; run pacman, mkinitcpio, etc.
exit
sudo umount -R /mnt
sudo reboot
```

For an encrypted root:

```bash
sudo cryptsetup open /dev/sdXN cryptroot
sudo mount /dev/mapper/cryptroot /mnt
# ...continue as above
```

## 11. Reporting bugs

If your issue is not in this document:

1. Reproduce it on the latest ISO.
2. Collect diagnostic info:
   ```bash
   orion-about > /tmp/orion-about.txt
   journalctl -b > /tmp/journal.txt
   dmesg > /tmp/dmesg.txt
   ```
3. Open an issue with a clear title, the steps to reproduce, the expected and
   actual behavior, and the diagnostic files attached (after redacting any
   private information).
