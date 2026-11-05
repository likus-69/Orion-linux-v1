#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
#
# tests/unit/test_branding.py — verify the branding assets render correctly
# and that every required asset file exists.

from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
BRANDING_DIR = REPO_ROOT / "distro" / "branding"
WALLPAPERS_DIR = REPO_ROOT / "wallpapers"
SYSINUX_DIR = REPO_ROOT / "distro" / "archiso" / "bootfiles" / "syslinux"
ISO_WALLPAPERS_DIR = REPO_ROOT / "distro" / "archiso" / "airootfs" / "usr" / "share" / "orion" / "wallpapers"

REQUIRED_BRANDING_FILES = [
    "orion-logo.svg", "orion-logo.png",
    "orion-logo-light.svg", "orion-logo-light.png",
    "orion-icon.svg", "orion-icon.png",
    "orion-boot-splash.svg", "orion-boot-splash.png",
]

REQUIRED_WALLPAPER_FILES = [
    "orion-dark.svg", "orion-dark.png",
    "orion-light.svg", "orion-light.png",
    "orion-midnight.svg", "orion-midnight.png",
    "orion-aurora.svg", "orion-aurora.png",
]

PNG_MAGIC = b"\x89PNG\r\n\x1a\n"


@pytest.mark.parametrize("filename", REQUIRED_BRANDING_FILES)
def test_branding_file_exists(filename):
    assert (BRANDING_DIR / filename).exists(), f"Missing branding asset: {filename}"


@pytest.mark.parametrize("filename", REQUIRED_WALLPAPER_FILES)
def test_wallpaper_file_exists(filename):
    assert (WALLPAPERS_DIR / filename).exists(), f"Missing wallpaper: {filename}"


@pytest.mark.parametrize("filename", REQUIRED_BRANDING_FILES)
def test_png_has_valid_magic_bytes(filename):
    path = BRANDING_DIR / filename
    if not path.exists() or not filename.endswith(".png"):
        pytest.skip("not a png or missing")
    with path.open("rb") as f:
        magic = f.read(len(PNG_MAGIC))
    assert magic == PNG_MAGIC, f"{filename} is not a valid PNG"


@pytest.mark.parametrize("filename", [f for f in REQUIRED_BRANDING_FILES if f.endswith(".svg")])
def test_branding_svg_is_well_formed(filename):
    path = BRANDING_DIR / filename
    text = path.read_text()
    assert text.startswith("<?xml") or text.startswith("<svg"), \
        f"{filename} is not a valid SVG"
    assert text.rstrip().endswith("</svg>"), f"{filename} does not close <svg> tag"


@pytest.mark.parametrize("filename", [f for f in REQUIRED_WALLPAPER_FILES if f.endswith(".svg")])
def test_wallpaper_svg_is_well_formed(filename):
    path = WALLPAPERS_DIR / filename
    text = path.read_text()
    assert text.startswith("<?xml") or text.startswith("<svg"), \
        f"{filename} is not a valid SVG"
    assert text.rstrip().endswith("</svg>"), f"{filename} does not close <svg> tag"


def test_syslinux_splash_exists():
    assert (SYSINUX_DIR / "splash.png").exists(), "syslinux splash missing"


def test_iso_wallpapers_installed():
    """The 4 wallpaper PNGs must be copied into the ISO's usr/share/orion/wallpapers/."""
    for name in ["orion-dark.png", "orion-light.png",
                 "orion-midnight.png", "orion-aurora.png"]:
        assert (ISO_WALLPAPERS_DIR / name).exists(), \
            f"Wallpaper {name} not installed into ISO tree"
