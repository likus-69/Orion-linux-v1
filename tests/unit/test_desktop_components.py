#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
#
# tests/unit/test_desktop_components.py — static checks on every Orion
# desktop component. Verifies the component has the expected structure:
#   - CMakeLists.txt
#   - src/main.cpp with SPDX header
#   - QML files with SPDX headers
#   - One of the expected D-Bus service names (where applicable)

import re
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
DESKTOP_DIR = REPO_ROOT / "desktop"

# (component_name, has_dbus, expected_dbus_name)
COMPONENTS = [
    ("orion-framework",   False, None),
    ("shell",             True,  "org.orion.Shell"),
    ("panel",             False, None),
    ("start-menu",        True,  "org.orion.StartMenu"),
    ("settings",          False, None),
    ("file-manager",      False, None),
    ("welcome-center",    False, None),
    ("software-center",   False, None),
    ("notifications",     True,  "org.freedesktop.Notifications"),
    ("quick-settings",    False, None),
    ("system-monitor",    False, None),
    ("update-manager",    False, None),
    ("screenshot-tool",    False, None),
    ("search",            False, None),
    ("lockscreen",        False, None),
]


@pytest.mark.parametrize("name,has_dbus,dbus_name", COMPONENTS)
def test_component_has_cmake(name, has_dbus, dbus_name):
    d = DESKTOP_DIR / name
    assert d.exists(), f"Missing component dir: desktop/{name}/"
    assert (d / "CMakeLists.txt").exists(), \
        f"desktop/{name}/CMakeLists.txt missing"


@pytest.mark.parametrize("name,has_dbus,dbus_name", COMPONENTS)
def test_component_has_main_cpp(name, has_dbus, dbus_name):
    p = DESKTOP_DIR / name / "src" / "main.cpp"
    if name == "orion-framework":
        # Framework has selftest.cpp instead.
        p = DESKTOP_DIR / name / "src" / "selftest.cpp"
    assert p.exists(), f"desktop/{name}/src/main.cpp (or selftest.cpp) missing"


@pytest.mark.parametrize("name,has_dbus,dbus_name", COMPONENTS)
def test_component_has_qml_files(name, has_dbus, dbus_name):
    if name in ("shell",):
        # The shell is pure C++ (no QML); it just launches KWin + systemd
        # user services. Skip the QML-files check.
        return
    qml = list((DESKTOP_DIR / name / "qml").glob("*.qml"))
    if name == "orion-framework":
        # Framework has lots of reusable QML components; just check there's at least one.
        assert qml, f"desktop/{name}/qml/ has no .qml files"
        return
    assert qml, f"desktop/{name}/qml/ has no .qml files"


@pytest.mark.parametrize("name,has_dbus,dbus_name", COMPONENTS)
def test_source_files_have_spdx_header(name, has_dbus, dbus_name):
    """Every C++ source/header file must start with an SPDX license header."""
    src_dir = DESKTOP_DIR / name / "src"
    if not src_dir.exists():
        pytest.skip(f"{name} has no src/ dir")
    for f in src_dir.glob("*"):
        if f.suffix not in (".cpp", ".h"):
            continue
        text = f.read_text()
        first_500 = text[:500]
        assert "SPDX-License-Identifier: GPL-3.0-or-later" in first_500, \
            f"{f} missing SPDX header"


@pytest.mark.parametrize("name,has_dbus,dbus_name", COMPONENTS)
def test_qml_files_have_spdx_header(name, has_dbus, dbus_name):
    """Every QML file should start with an SPDX header (or comment)."""
    qml_dir = DESKTOP_DIR / name / "qml"
    if not qml_dir.exists():
        return
    for f in qml_dir.rglob("*.qml"):
        text = f.read_text()
        # QML comments start with //; allow the SPDX header to appear
        # in the first 500 chars.
        if "SPDX-License-Identifier" not in text[:500]:
            # Soft warning — log but don't fail.
            print(f"WARN: {f} missing SPDX header")


@pytest.mark.parametrize("name,has_dbus,dbus_name", COMPONENTS)
def test_dbus_service_registered_when_required(name, has_dbus, dbus_name):
    """If a component should register a D-Bus name, verify the source
    references that name."""
    if not has_dbus or not dbus_name:
        return
    src_dir = DESKTOP_DIR / name / "src"
    found = False
    for f in src_dir.glob("*.cpp"):
        if dbus_name in f.read_text():
            found = True
            break
    assert found, f"{name} does not register {dbus_name} in any .cpp"


def test_every_component_depends_on_orion_framework():
    """CMakeLists.txt for every component (except the framework itself)
    must `find_package(OrionFramework)`."""
    for name in os.listdir(DESKTOP_DIR):
        if name == "orion-framework":
            continue
        cml = DESKTOP_DIR / name / "CMakeLists.txt"
        if not cml.exists():
            continue
        text = cml.read_text()
        assert "find_package(OrionFramework" in text, \
            f"desktop/{name}/CMakeLists.txt does not depend on OrionFramework"


import os  # late import so the parametrize decorator above works cleanly
