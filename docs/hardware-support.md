# Orion OS — Hardware Support

This document describes the hardware Orion OS targets, the drivers shipped by
default, the detection / guidance workflow, and the explicit non-promises.

## 1. Target hardware

Orion OS targets ordinary **x86_64 desktop computers and laptops** produced in
the last ~10 years. Specifically:

- **CPU:** Intel x86_64 (Sandy Bridge or newer) or AMD x86_64 (Bulldozer or
  newer). 64-bit only; no 32-bit ISO is produced.
- **RAM:** 4 GB minimum; 8 GB recommended; 16 GB+ for development workloads.
- **Disk:** 32 GB minimum for the base install; 64 GB+ recommended for daily
  use.
- **Firmware:** UEFI preferred (systemd-boot). Legacy BIOS supported via GRUB
  where practical.
- **GPU:** See §3.

ARM64 (aarch64) is a **planned future target**, not supported in v1.

## 2. Default driver set

The ISO and the installed system ship the following kernel and driver
packages:

| Package | Purpose |
|---|---|
| `linux` | The upstream Arch kernel (LTS via `linux-lts` is offered at install) |
| `linux-firmware` | Upstream firmware blob set |
| `linux-firmware-marvell`, `-amd`, `-intel`, `-qlogic`, `-bnx2x` | Vendor firmware subsets (already in `linux-firmware`; listed for clarity) |
| `intel-media-driver` | Intel iGPU video decode/encode |
| `mesa` | Open-source OpenGL/Vulkan for Intel/AMD |
| `vulkan-intel`, `vulkan-radeon`, `vulkan-nouveau` | Vulkan drivers per vendor |
| `lib32-mesa`, `lib32-vulkan-*` | 32-bit libs for Steam / Wine / Proton |
| `nvidia-dkms` (optional, post-install) | Proprietary NVIDIA driver — installed via Software Center if NVIDIA detected |
| `broadcom-wl-dkms` (optional, post-install) | Broadcom Wi-Fi driver |
| `sof-firmware` | Sound Open Firmware for modern laptops |
| `pipewire-audio` | PipeWire audio server |

Out-of-tree drivers are **not** preinstalled. The Welcome Center's "Hardware
Check" page detects NVIDIA/Broadcom hardware and offers to install the
appropriate driver via the Software Center.

## 3. GPU support

### 3.1 Intel integrated

- Supported out of the box via `mesa` (OpenGL) and `vulkan-intel` (Vulkan).
- Gen 8 (Broadwell) and newer are well-supported.
- Gen 7 (Ivy Bridge) and older may have limited Vulkan support but OpenGL
  works.
- Display scaling on HiDPI panels works via KWin.

### 3.2 AMD integrated and discrete

- Supported out of the box via `mesa` (OpenGL) and `vulkan-radeon` (Vulkan).
- GCN 1.0 (Southern Islands) and newer are supported.
- Pre-GCN hardware is **not** supported; use a legacy distribution.

### 3.3 NVIDIA discrete

- The live ISO uses `nouveau` (open-source).
- On the installed system, the Welcome Center offers to install `nvidia-dkms`
  if NVIDIA hardware is detected.
- After `nvidia-dkms` installation, the kernel command line must include
  `nvidia-drm.modeset=1` for flicker-free boot and Wayland support. The
  installer's NVIDIA post-install hook does this automatically.
- Older NVIDIA cards (Kepler / Fermi) are no longer supported by the latest
  `nvidia-dkms`; users with these cards should stay on `nouveau` or install
  the legacy `nvidia-470xx-dkms` from AUR (advanced).

### 3.4 Other GPUs

- Matrox, VIA, S3: not supported. Use VESA fallback (`nomodeset`).

## 4. Wi-Fi

| Vendor | Driver | Status |
|---|---|---|
| Intel (iwlwifi) | In kernel | Works out of the box |
| Atheros (ath9k, ath10k, ath11k) | In kernel | Works out of the box |
| Realtek (rtl8822ce, rtl8821ce, rtl8188eu) | In kernel or `rtl8821cu-dkms` | Works for most cards; some need AUR |
| Broadcom (`broadcom-wl-dkms`) | Out of tree | Welcome Center offers installation |
| Mediatek (mt7921, mt7922) | In kernel | Works out of the box |

For cards requiring `broadcom-wl-dkms`, the user must have the
`linux-headers` package installed (the installer adds it for the running
kernel). The Welcome Center detects Broadcom hardware and walks the user
through installation.

## 5. Bluetooth

- `bluez`, `bluez-utils`, `pipewire-pulse` (for Bluetooth audio via PipeWire)
  are installed by default.
- Bluetooth is **enabled** by default (the protocol is harmless until paired).
- Settings → Devices → Bluetooth exposes pairing and device management.
- Audio devices use the `pipewire-pulse` Bluetooth modules; A2DP and HFP
  profiles are supported.

## 6. Audio

- `pipewire` (system and user instances) + `wireplumber` are the default audio
  stack.
- `sof-firmware` is installed for Sound Open Firmware devices (modern Intel
  laptops).
- USB audio devices are supported out of the box.
- HDMI audio is supported (via the GPU driver).
- Pro audio (JACK clients) is supported via PipeWire's JACK interface —
  install `pipewire-jack` and `jack_capture` if needed.

## 7. Printers

- `cups`, `cups-filters`, `cups-pk-helper`, `system-config-printer` are
  installed by default.
- The `cups` service is **disabled** by default to avoid opening network
  ports. The first time the user opens Settings → Devices → Printers, Orion
  enables `cups.service` (locally bound) on demand.
- Network printers (IPP, IPP Everywhere, AirPrint) are auto-discovered via
  Avahi (also enabled on demand for printer discovery).
- Vendor drivers (HP, Brother, Epson) are available via the Software Center.

## 8. Cameras and peripherals

- UVC (USB Video Class) webcams work out of the box.
- MIPI cameras on some laptops require `ipu6` drivers — these are not
  preinstalled; users with such cameras can install `intel-ipu6` from AUR.
- Wacom tablets work via the `wacom` kernel driver and `xf86-input-wacom`
  (X11) / native Wayland input (Wayland).
- Game controllers (Xbox, DualShock, DualSense, Switch Pro) work via
  `hid-nintendo` (kernel) and `steam` (for Steam-paired controllers).

## 9. Multi-monitor

- KWin's multi-monitor support is used.
- Mixed-DPI configurations (e.g. 4K laptop + 1080p external) are supported on
  Wayland.
- Hot-plugging monitors triggers Settings → System → Display to update the
  layout.

## 10. Power management

- Laptops use `power-profiles-daemon` for power profiles (Performance,
  Balanced, Power Saver).
- Suspend-to-RAM works on most modern hardware; resume on buggy hardware may
  require `mem_sleep_default=deep` in the kernel command line.
- Hibernation is supported when a swap partition or swapfile larger than RAM
  exists; the installer offers to create one.
- TLP is **not** installed by default (it conflicts with
  `power-profiles-daemon`). Advanced users can install it via the Software
  Center and disable `power-profiles-daemon`.

## 11. Hardware that is NOT supported

Orion OS does not claim universal hardware compatibility. Explicitly:

- Pre-UEFI (legacy BIOS only) hardware made before ~2012: best-effort, not
  tested.
- ARM SBCs (Raspberry Pi, Pinebook, etc.): not supported in v1.
- Apple Silicon Macs: not supported (would require Asahi Linux kernel and
  drivers; future target).
- Phones and tablets: not supported.
- Hardware requiring closed-source, vendor-supplied drivers that violate the
  GPL: not bundled.

## 12. Driver detection workflow

The Orion Welcome Center's "Hardware Check" page runs a hardware scan on
launch:

1. Reads `lspci -nn` and `lsusb -v`.
2. Compares against a known-driver-needs table
   (`/usr/share/orion/hardware/drivers.json`).
3. For each match, presents an "Install driver for X" button.
4. The button installs the driver via the Software Center (PackageKit).
5. After installation, the user is prompted to reboot.

The detection is conservative: if a card is unknown, no driver is suggested.
The user is informed that the hardware may work with the default driver or
may need manual configuration; a link to `docs/hardware-support.md` is shown.

## 13. Testing matrix

See `docs/release-process.md` §4 for the per-release hardware test matrix.
Test results are recorded in `docs/hardware-test-results/<version>.md`. The
matrix is intentionally small — Orion OS does not have the resources to test
against every laptop model in existence.

## 14. Reporting hardware issues

If your hardware does not work as expected:

1. Collect diagnostic info:
   ```bash
   orion-about > /tmp/orion-about.txt
   lspci -nn > /tmp/lspci.txt
   lsusb -v > /tmp/lsusb.txt
   journalctl -b > /tmp/journal.txt
   dmesg > /tmp/dmesg.txt
   ```
2. Search the project's existing issues for your hardware's PCI IDs.
3. Open an issue with the diagnostic files attached (after redacting any
   private information — MAC addresses, serial numbers).
4. State the expected behavior and the actual behavior.

Orion OS maintainers cannot fix every hardware issue; many will need to be
reported upstream (kernel, mesa, NetworkManager, etc.). The maintainers help
triage and route these reports.
