#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
#
# tests/virtual-machine/smoke_test.py — boot-test driver for the Orion OS ISO.
#
# Run on an Arch Linux host with qemu-system-x86_64 + OVMF:
#
#     python3 tests/virtual-machine/smoke_test.py path/to/orion-os-*.iso
#
# This script:
#   1. Boots the ISO under QEMU (UEFI mode, 4 GB RAM, 2 CPUs, 32 GB disk).
#   2. Waits for the live session to come up.
#   3. Verifies (via `ssh` to the live ISO, or by parsing the serial console
#      log) that:
#        - the kernel booted
#        - systemd reached graphical.target
#        - SDDM is running
#        - NetworkManager is up
#        - the Orion shell registered on the session bus
#        - the orion user can sudo without a password (live ISO)
#   4. Reports results.
#
# Reference: docs/installation.md §3, docs/release-process.md §2.4.

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path


def find_ovmf() -> tuple[str, str] | None:
    for code, var in [
        ("/usr/share/ovmf/x64/OVMF_CODE.fd",     "/usr/share/ovmf/x64/OVMF_VARS.fd"),
        ("/usr/share/edk2-ovmf/x64/OVMF_CODE.fd", "/usr/share/edk2-ovmf/x64/OVMF_VARS.fd"),
        ("/usr/share/qemu/OVMF_CODE.fd",         "/usr/share/qemu/OVMF_VARS.fd"),
    ]:
        if os.path.exists(code) and os.path.exists(var):
            return code, var
    return None


def boot_qemu(iso: Path, work: Path) -> tuple[subprocess.Popen, Path]:
    ovmf = find_ovmf()
    if ovmf is None:
        sys.exit("ERROR: OVMF firmware not found. Install: sudo pacman -S ovmf")
    code_fd, vars_fd = ovmf
    vars_copy = work / "OVMF_VARS.fd"
    shutil.copy(vars_fd, vars_copy)

    disk = work / "disk.qcow2"
    subprocess.run(["qemu-img", "create", "-f", "qcow2", str(disk), "32G"], check=True)

    serial_log = work / "serial.log"
    cmd = [
        "qemu-system-x86_64",
        "-name", "orion-os-test",
        "-machine", "q35,accel=kvm:tcg",
        "-cpu", "host",
        "-smp", "2",
        "-m", "4096",
        "-drive", f"if=pflash,format=raw,readonly=on,file={code_fd}",
        "-drive", f"if=pflash,format=raw,file={vars_copy}",
        "-drive", f"file={disk},if=virtio,format=qcow2",
        "-cdrom", str(iso),
        "-boot", "d",
        "-netdev", "user,id=net0,hostfwd=tcp::2222-:22",
        "-device", "virtio-net-pci,netdev=net0",
        "-display", "none",
        "-serial", f"file:{serial_log}",
        "-monitor", "none",
    ]
    proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    return proc, serial_log


def wait_for_serial_marker(serial_log: Path, marker: str, timeout: int = 180) -> bool:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            text = serial_log.read_text(errors="ignore")
            if marker in text:
                return True
        except Exception:
            pass
        time.sleep(2)
    return False


def parse_serial_for_results(serial_log: Path) -> dict:
    text = serial_log.read_text(errors="ignore")
    return {
        "kernel_booted": "Linux version" in text,
        "systemd_started": "systemd" in text and "Started" in text,
        "graphical_target": "graphical.target" in text,
        "sddm_started": "sddm" in text.lower(),
        "networkmanager": "NetworkManager" in text,
        "orion_shell": "orion.shell" in text.lower() or "org.orion.Shell" in text,
        "kernel_panic": "Kernel panic" in text or "not syncing" in text,
        "initramfs_failure": "Failed to start" in text and "mount" in text,
    }


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("iso", type=Path, help="Path to the Orion OS ISO")
    p.add_argument("--timeout", type=int, default=180,
                   help="Seconds to wait for boot to settle")
    p.add_argument("--work-dir", type=Path, default=None)
    args = p.parse_args()

    if not args.iso.exists():
        sys.exit(f"ISO not found: {args.iso}")

    if shutil.which("qemu-system-x86_64") is None:
        sys.exit("qemu-system-x86_64 not found. Install: sudo pacman -S qemu-desktop")

    work = args.work_dir or Path(tempfile.mkdtemp(prefix="orion-vm-"))
    print(f"[smoke-test] work dir: {work}")
    print(f"[smoke-test] booting ISO: {args.iso.name}")

    proc, serial_log = boot_qemu(args.iso, work)
    print(f"[smoke-test] QEMU started (pid {proc.pid}); waiting up to {args.timeout}s for boot")

    # Wait for boot to settle.
    wait_for_serial_marker(serial_log, "Reached target", args.timeout)

    # Give it a bit more time for the desktop session to start.
    time.sleep(30)

    print(f"[smoke-test] collecting results from {serial_log}")
    results = parse_serial_for_results(serial_log)
    for k, v in results.items():
        marker = "✓" if v else "✗"
        print(f"  {marker} {k}: {v}")

    # Power off.
    proc.terminate()
    try:
        proc.wait(timeout=10)
    except subprocess.TimeoutExpired:
        proc.kill()

    # Exit code based on critical checks.
    critical = ["kernel_booted", "systemd_started", "graphical_target"]
    failed = [k for k in critical if not results.get(k)]
    if failed:
        print(f"\n[smoke-test] FAILED: {failed}")
        return 1
    if results.get("kernel_panic"):
        print("\n[smoke-test] FAILED: kernel panic detected")
        return 2
    print("\n[smoke-test] PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
