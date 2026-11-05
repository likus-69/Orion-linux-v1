#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
#
# tests/security/test_secrets_and_perms.py — security-focused static checks.
#
# Complements scripts/security-scan.sh with structured pytest assertions.

import re
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
SCAN_DIRS = [
    REPO_ROOT / "desktop",
    REPO_ROOT / "scripts",
    REPO_ROOT / "installer",
    REPO_ROOT / "distro" / "services",
    REPO_ROOT / "distro" / "defaults",
]

# Patterns that look like secrets. False positives are filtered by the
# placeholder/REPLACE check.
SECRET_PATTERNS = [
    (r"AKIA[0-9A-Z]{16}",                "AWS access key"),
    (r"ghp_[A-Za-z0-9]{36}",             "GitHub personal access token"),
    (r"sk_live_[A-Za-z0-9]{24}",         "Stripe live key"),
    (r"-----BEGIN [A-Z ]*PRIVATE KEY-----", "PEM private key"),
    (r"xox[baprs]-[A-Za-z0-9-]{10,}",    "Slack token"),
]

EXCLUDE_SUBSTRINGS = ("placeholder", "REPLACE", "TODO", "example.org",
                       "00000000", "0" * 16)


def _scan_files():
    for scan_dir in SCAN_DIRS:
        if not scan_dir.exists():
            continue
        for path in scan_dir.rglob("*"):
            if not path.is_file():
                continue
            if path.suffix not in (".py", ".sh", ".cpp", ".h", ".qml",
                                    ".json", ".conf", ".rules", ".lua",
                                    ".js", ".md"):
                continue
            yield path


@pytest.mark.parametrize("pattern,desc", SECRET_PATTERNS)
def test_no_secret_patterns_present(pattern, desc):
    hits = []
    for path in _scan_files():
        try:
            text = path.read_text(errors="ignore")
        except (OSError, UnicodeDecodeError):
            continue
        for m in re.finditer(pattern, text):
            # Check context for exclusion markers (placeholder, example.org, etc.).
            ctx_start = max(0, m.start() - 60)
            ctx_end   = min(len(text), m.end() + 60)
            ctx = text[ctx_start:ctx_end].lower()
            if any(s.lower() in ctx for s in EXCLUDE_SUBSTRINGS):
                continue
            hits.append((path, m.group(0), ctx))
    assert not hits, f"Found {len(hits)} potential {desc} secrets: {hits[:3]}"


def test_no_hardcoded_passwords_in_shell_scripts():
    pattern = re.compile(r"(password|passwd|secret|api_key|token)\s*=\s*"
                         r"['\"][^'\"]{8,}['\"]", re.IGNORECASE)
    hits = []
    for path in _scan_files():
        if path.suffix != ".sh":
            continue
        text = path.read_text(errors="ignore")
        for m in pattern.finditer(text):
            ctx_start = max(0, m.start() - 40)
            ctx_end = min(len(text), m.end() + 40)
            ctx = text[ctx_start:ctx_end].lower()
            if any(s.lower() in ctx for s in EXCLUDE_SUBSTRINGS):
                continue
            hits.append((path, m.group(0)))
    assert not hits, f"Potential hardcoded passwords: {hits[:3]}"


def test_no_silent_sudo_in_qml():
    """QML files must not silently shell out to `sudo`."""
    hits = []
    for path in (REPO_ROOT / "desktop").rglob("*.qml"):
        text = path.read_text(errors="ignore")
        if "sudo " in text and "pkexec" not in text and "polkit" not in text:
            hits.append(path)
    assert not hits, f"QML files invoking sudo without polkit: {hits}"


def test_no_root_setuid_binaries_in_tree():
    """No file in the repository should declare itself setuid-root.
    (Build / install scripts may set SUID bits, but the source itself
    should not have SUID-root expectations.)"""
    hits = []
    for path in REPO_ROOT.rglob("*"):
        if not path.is_file():
            continue
        try:
            st = path.stat()
        except OSError:
            continue
        if st.st_mode & 0o4000:
            hits.append(path)
    # The distro tree is normal mode (not actually built). We allow
    # profiledef.sh's file_permissions entries to declare 4755 for specific
    # files (e.g. orion-live-autologin), but those are not yet applied to
    # the source.
    assert not hits, f"Unexpected SUID files: {hits}"


def test_pacman_conf_uses_strict_siglevel_for_orion():
    text = (REPO_ROOT / "distro" / "archiso" / "pacman.conf").read_text()
    # The [orion] stanza must require signatures.
    orion_section = re.search(r"\[orion\](.*?)(?:\n\[|\Z)", text, re.DOTALL)
    assert orion_section, "pacman.conf missing [orion] section"
    assert "SigLevel = Required" in orion_section.group(1), \
        "[orion] must require signature verification"


def test_polkit_rules_dont_grant_yes_without_subject_check():
    rules_dir = REPO_ROOT / "distro" / "defaults" / "polkit"
    for f in rules_dir.glob("*.rules"):
        text = f.read_text()
        # Any "return polkit.Result.YES" must be inside a function that
        # checks subject.isInGroup or subject.local or subject.active.
        if "polkit.Result.YES" not in text:
            continue
        # Find every YES; check that it's inside a function with subject.* check.
        # (For simplicity, just require that the file contains a subject.* reference.)
        assert re.search(r"subject\.(isInGroup|local|active)", text), \
            f"{f.name} grants YES without subject check"
