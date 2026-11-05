#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
#
# tests/unit/test_archiso_profile.py — verify the Archiso profile is well-formed.
# These tests do NOT run mkarchiso; they statically check the profile files
# are present and parse correctly.

import re
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
ARCHISO_DIR = REPO_ROOT / "distro" / "archiso"
AIROOTFS = ARCHISO_DIR / "airootfs"


def test_profiledef_exists():
    assert (ARCHISO_DIR / "profiledef.sh").exists()


def test_profiledef_has_required_fields():
    text = (ARCHISO_DIR / "profiledef.sh").read_text()
    for field in ["iso_name=", "iso_label=", "iso_publisher=",
                  "iso_application=", "iso_version=", "install_dir=",
                  "buildmodes=", "bootmodes=", "arch="]:
        assert field in text, f"profiledef.sh missing {field!r}"


def test_packages_file_exists():
    assert (ARCHISO_DIR / "packages.x86_64").exists()


def test_packages_includes_required():
    pkgs = (ARCHISO_DIR / "packages.x86_64").read_text()
    # Core packages that MUST be in the list.
    required = ["linux", "systemd", "pacman", "networkmanager", "pipewire",
                "wireplumber", "polkit", "packagekit", "kwin", "qt6-base",
                "qt6-declarative", "qt6-wayland", "orion-framework",
                "orion-shell", "orion-panel", "orion-start-menu",
                "orion-settings", "orion-file-manager", "calamares"]
    for pkg in required:
        # Match package name as the start of a line (not as a substring
        # of a comment).
        pattern = rf"^{re.escape(pkg)}\b"
        assert re.search(pattern, pkgs, re.MULTILINE), \
            f"packages.x86_64 missing required package: {pkg}"


def test_pacman_conf_uses_strict_siglevel():
    text = (ARCHISO_DIR / "pacman.conf").read_text()
    assert "[orion]" in text
    assert "SigLevel = Required" in text, \
        "Orion repository must use strict SigLevel"


def test_customize_script_exists_and_executable():
    p = AIROOTFS / "root" / "customize_airootfs.sh"
    assert p.exists(), "customize_airootfs.sh missing"
    assert p.stat().st_mode & 0o100, "customize_airootfs.sh not executable"


def test_customize_script_does_not_call_pacman_sy():
    """The live-ISO customizer must never run `pacman -Sy` (which causes
    partial-upgrade problems). `pacman -Scc` is allowed for cache cleanup."""
    text = (AIROOTFS / "root" / "customize_airootfs.sh").read_text()
    assert "pacman -Sy" not in text, \
        "customize_airootfs.sh calls `pacman -Sy` (partial upgrade — forbidden)"


def test_live_polkit_rule_documented():
    """The live-ISO polkit rule must contain a comment saying it's removed
    by the Calamares post-install module."""
    p = AIROOTFS / "etc" / "polkit-1" / "rules.d" / "10-orion-live.rules"
    if not p.exists():
        pytest.skip("live polkit rule not present")
    text = p.read_text()
    assert "REMOVED" in text.upper(), \
        "live polkit rule lacks the 'removed on install' documentation"


def test_os_release_present():
    # The customize script writes /etc/os-release; verify it does so with
    # the required fields.
    text = (AIROOTFS / "root" / "customize_airootfs.sh").read_text()
    for field in ["NAME=", "ID=orion-os", "ID_LIKE=arch", "PRETTY_NAME=",
                  "VERSION_ID=", "BUILD_ID="]:
        assert field in text, \
            f"customize script does not write {field} to /etc/os-release"


def test_wayland_session_entry_present():
    p = AIROOTFS / "usr" / "share" / "wayland-sessions" / "orion.desktop"
    assert p.exists(), "wayland-sessions/orion.desktop missing"
    text = p.read_text()
    assert "Exec=" in text and "/usr/lib/orion/orion-shell" in text
    assert "DesktopNames=orion" in text


def test_bootloader_configs_present():
    assert (ARCHISO_DIR / "bootfiles" / "syslinux" / "syslinux.cfg").exists()
    assert (ARCHISO_DIR / "efiboot" / "loader" / "loader.conf").exists()
    assert (ARCHISO_DIR / "efiboot" / "loader" / "entries" / "orion.conf").exists()


def test_iso_installation_disk_size_under_4gb_warning():
    """The packages list should not exceed ~2500 lines (a heuristic
    indicating the ISO will fit in a 4.7 GB single-layer DVD)."""
    lines = (ARCHISO_DIR / "packages.x86_64").read_text().splitlines()
    non_comment = [l for l in lines if l.strip() and not l.strip().startswith("#")]
    assert len(non_comment) < 500, \
        f"packages.x86_64 has {len(non_comment)} entries — ISO may exceed 4 GB"
