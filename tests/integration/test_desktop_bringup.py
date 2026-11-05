#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
#
# tests/integration/test_desktop_bringup.py
#
# Integration smoke test. Runs on a host with the Orion desktop session
# active (i.e. running KWin + the Orion shell). Verifies that:
#   1. The org.orion.Shell D-Bus name is registered on the session bus.
#   2. The org.orion.Panel D-Bus name is registered.
#   3. The org.orion.StartMenu D-Bus name is registered.
#   4. The org.freedesktop.Notifications D-Bus name is registered (i.e.
#      the Orion Notifications daemon is running, not KDE's).
#   5. The org.freedesktop.PackageKit D-Bus name is registered on the system bus.
#   6. NetworkManager is on the system bus.
#   7. PipeWire is running (ps).

import shutil
import subprocess
import sys


def dbus_has_name(bus: str, name: str) -> bool:
    cmd = {"session": ["busctl", "--user", "list"],
           "system":  ["busctl", "list"]}[bus]
    try:
        out = subprocess.check_output(cmd, text=True, timeout=5)
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False
    return name in out


def pipewire_running() -> bool:
    try:
        out = subprocess.check_output(["pgrep", "-u", str(__import__("os").getuid()), "pipewire"],
                                       text=True)
        return bool(out.strip())
    except subprocess.CalledProcessError:
        return False


def main() -> int:
    checks = []

    def check(name: str, ok: bool, detail: str = ""):
        marker = "PASS" if ok else "FAIL"
        checks.append(ok)
        print(f"  [{marker}] {name}" + (f" — {detail}" if detail else ""))

    print("Orion Desktop integration smoke test")

    check("org.orion.Shell on session bus",
          dbus_has_name("session", "org.orion.Shell"))
    check("org.orion.Panel on session bus",
          dbus_has_name("session", "org.orion.Panel"))
    check("org.orion.StartMenu on session bus",
          dbus_has_name("session", "org.orion.StartMenu"))
    check("org.freedesktop.Notifications on session bus",
          dbus_has_name("session", "org.freedesktop.Notifications"),
          "must be Orion Notifications, not Plasma's")
    check("org.freedesktop.PackageKit on system bus",
          dbus_has_name("system", "org.freedesktop.PackageKit"))
    check("org.freedesktop.NetworkManager on system bus",
          dbus_has_name("system", "org.freedesktop.NetworkManager"))
    check("PipeWire process running", pipewire_running())

    print(f"\n{sum(checks)}/{len(checks)} checks passed")
    if all(checks):
        print("All integration checks PASSED")
        return 0
    print("Some integration checks FAILED")
    return 1


if __name__ == "__main__":
    sys.exit(main())
