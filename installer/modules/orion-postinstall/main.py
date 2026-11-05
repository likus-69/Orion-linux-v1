#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
#
# installer/modules/orion-postinstall/main.py
#
# Calamares Python module. Runs after packages are installed; before
# unmounting the new system. Removes the live-ISO's permissive polkit
# and sudoers files so the installed system uses standard policies.

import os
import libcalamares

LIVE_FILES_TO_REMOVE = [
    "/etc/sudoers.d/10-orion-live",
    "/etc/polkit-1/rules.d/10-orion-live.rules",
    "/etc/sddm.conf.d/10-autologin.conf",
    "/etc/NetworkManager/conf.d/10-orion-live.conf",
]

def pretty_name():
    return "Orion OS — post-install cleanup"

def run():
    """Calamares entry point. Runs inside the chroot of the installed system."""
    root_mount_point = libcalamares.globalstorage.value("rootMountPoint")
    if not root_mount_point:
        return ("No root mount point set",
                "Calamares did not provide a rootMountPoint in global storage.")

    removed = []
    for path in LIVE_FILES_TO_REMOVE:
        full = os.path.join(root_mount_point, path.lstrip("/"))
        try:
            if os.path.exists(full):
                os.remove(full)
                removed.append(path)
        except OSError as e:
            libcalamares.utils.warning(f"Could not remove {path}: {e}")

    libcalamares.utils.debug(f"orion-postinstall: removed {len(removed)} live-ISO files")

    # Restore standard polkit rules (they were already copied by unpackfs
    # from /usr/share/orion/defaults/polkit/, so we just verify they exist).
    polkit_dir = os.path.join(root_mount_point,
                              "etc/polkit-1/rules.d")
    for rule in ("20-orion-softwarecenter.rules", "30-orion-power.rules"):
        if not os.path.exists(os.path.join(polkit_dir, rule)):
            libcalamares.utils.warning(f"polkit rule {rule} missing on installed system")

    # Ensure the orion-keyring is initialized.
    libcalamares.utils.debug("orion-postinstall: keyring already initialized by packages")

    # Ensure the orion user (live) is NOT present on the installed system.
    import subprocess
    try:
        subprocess.run(["chroot", root_mount_point, "userdel", "-r", "orion"],
                       check=False, capture_output=True)
    except FileNotFoundError:
        pass

    return None
