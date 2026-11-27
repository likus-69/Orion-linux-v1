#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
#
# tests/security/test_polkit_rules.py — regression tests for the polkit
# policy shipped on the installed system.
#
# Background: 20-orion-softwarecenter.rules once returned polkit.Result.YES
# for wheel users on package install/remove/update and disk formatting, i.e.
# no authentication at all. These tests keep that from coming back.

import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
POLKIT_DIR = REPO_ROOT / "distro" / "defaults" / "polkit"
SOFTWARE_RULES = POLKIT_DIR / "20-orion-softwarecenter.rules"

# Actions that must always require authentication, for every user.
PRIVILEGED_ACTIONS = [
    "org.freedesktop.packagekit.package-install",
    "org.freedesktop.packagekit.package-remove",
    "org.freedesktop.packagekit.system-update",
    "org.freedesktop.packagekit.package-repair",
    "org.orion.softwarecenter.install",
    "org.orion.softwarecenter.remove",
    "org.orion.softwarecenter.updates",
    "org.orion.softwarecenter.aur",
    "org.freedesktop.udisks2.modify-device-system",
    "org.freedesktop.udisks2.format-device",
]


def _strip_comments(text: str) -> str:
    return re.sub(r"//[^\n]*", "", text)


def _case_block(code: str, action_id: str) -> str:
    """Return the code that runs for `action_id` (from its case label up to
    the next `break;`/`return ...;` that ends the group)."""
    start = code.index(f'case "{action_id}"')
    # Skip over fall-through case labels, then take the first return.
    m = re.compile(r"return\s+[^;]+;").search(code, start)
    assert m, f"no return statement found for {action_id}"
    return code[start:m.end()]


def test_software_rules_exist():
    assert SOFTWARE_RULES.exists()


def test_helpers_never_return_unconditional_yes():
    code = _strip_comments(SOFTWARE_RULES.read_text())
    for helper in ("allow_keep", "allow_once"):
        body = re.search(
            rf"function\s+{helper}\s*\(\)\s*\{{(.*?)\n\s*\}}", code, re.S
        )
        assert body, f"{helper}() not found"
        assert "polkit.Result.YES" not in body.group(1), (
            f"{helper}() returns polkit.Result.YES — that means no "
            "authentication for wheel users"
        )


def test_privileged_actions_use_auth_helpers():
    code = _strip_comments(SOFTWARE_RULES.read_text())
    for action in PRIVILEGED_ACTIONS:
        assert f'case "{action}"' in code, f"{action} not covered by rules"
        block = _case_block(code, action)
        assert "polkit.Result.YES" not in block, (
            f"{action} must not return polkit.Result.YES"
        )
        assert re.search(r"allow_(keep|once)\(\)", block), (
            f"{action} must go through allow_keep()/allow_once()"
        )


def test_aur_requires_fresh_auth_every_time():
    code = _strip_comments(SOFTWARE_RULES.read_text())
    block = _case_block(code, "org.orion.softwarecenter.aur")
    assert "allow_once()" in block, "AUR builds must not use a cached grant"


def test_wheel_gets_auth_self_not_yes():
    code = _strip_comments(SOFTWARE_RULES.read_text())
    assert "polkit.Result.AUTH_SELF_KEEP" in code
    assert "polkit.Result.AUTH_SELF" in code
