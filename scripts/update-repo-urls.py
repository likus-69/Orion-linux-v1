#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
#
# scripts/update-repo-urls.py — rewrite placeholder URLs to point at the
# real GitHub repository.
#
# Run from the repository root:
#     python3 scripts/update-repo-urls.py
#
# Replaces:
#   https://orion-os.example.org/                          → https://github.com/likus-69/Orion-linux-v1.1/
#   https://orion-os.example.org/docs/                     → .../tree/main/docs/
#   https://orion-os.example.org/support/                  → .../issues/
#   https://orion-os.example.org/bugs/                     → .../issues/
#   https://orion-os.example.org/community/                → .../discussions/
#   https://orion-os.example.org/releases/                 → .../releases/
#   https://orion-os.example.org/known-issues/             → .../issues/?q=label:known-issue/
#   https://orion-os.example.org/static/connectivity-check.txt → raw.githubusercontent.com/likus-69/Orion-linux-v1.1/main/distro/defaults/connectivity-check.txt
#   https://orion-os.example.org/telemetry                 → .../blob/main/docs/telemetry.md
#   git+https://orion-os.example.org/orion-os.git          → git+https://github.com/likus-69/Orion-linux-v1.1.git
#   release@orion-os.example.org                           → likus-69+release@users.noreply.github.com
#   security@orion-os.example.org                          → likus-69+security@users.noreply.github.com

from pathlib import Path
import re

REPO_ROOT = Path(__file__).resolve().parent.parent
GITHUB_BASE = "github.com/likus-69/Orion-linux-v1.1"
RAW_BASE = "raw.githubusercontent.com/likus-69/Orion-linux-v1.1/main"

REPLACEMENTS = [
    # Connectivity check URL points to a raw file in the repo (so the user
    # can update it without redeploying infrastructure).
    ("https://orion-os.example.org/static/connectivity-check.txt",
     f"https://{RAW_BASE}/distro/defaults/connectivity-check.txt"),
    # Path-specific replacements.
    ("https://orion-os.example.org/docs/",
     f"https://{GITHUB_BASE}/tree/main/docs/"),
    ("https://orion-os.example.org/support/",
     f"https://{GITHUB_BASE}/issues/"),
    ("https://orion-os.example.org/bugs/",
     f"https://{GITHUB_BASE}/issues/"),
    ("https://orion-os.example.org/community/",
     f"https://{GITHUB_BASE}/discussions/"),
    ("https://orion-os.example.org/releases/",
     f"https://{GITHUB_BASE}/releases/"),
    ("https://orion-os.example.org/known-issues/",
     f"https://{GITHUB_BASE}/issues?q=label%3Aknown-issue"),
    ("https://orion-os.example.org/telemetry",
     f"https://{GITHUB_BASE}/blob/main/docs/telemetry.md"),
    # The bare base URL is replaced LAST (longest-match-first ordering
    # means the path-specific ones above have already run).
    ("https://orion-os.example.org/",
     f"https://{GITHUB_BASE}/"),
    ("https://orion-os.example.org",
     f"https://{GITHUB_BASE}"),
    # Git clone URL.
    ("git+https://orion-os.example.org/orion-os.git",
     f"git+https://{GITHUB_BASE}.git"),
    # Email addresses (use GitHub's noreply +tag format).
    ("release@orion-os.example.org",
     "likus-69+release@users.noreply.github.com"),
    ("security@orion-os.example.org",
     "likus-69+security@users.noreply.github.com"),
    # Plain text references in docs ("orion-os.example.org" without scheme).
    # Be careful: only replace the standalone domain, not GitHub's "github.com".
    # Use a negative-lookbehind so we don't double-replace https:// variants.
    (re.compile(r"(?<!https://)(?<!@)orion-os\.example\.org"),
     GITHUB_BASE),
]

# Files to skip (don't rewrite this script itself, and don't touch the
# worklog since it's a historical record).
SKIP_FILES = {
    Path(__file__).resolve().relative_to(REPO_ROOT),
    Path("worklog.md"),
}


def main() -> int:
    files_changed = 0
    total_replacements = 0

    for path in REPO_ROOT.rglob("*"):
        if not path.is_file():
            continue
        rel = path.relative_to(REPO_ROOT)
        if rel in SKIP_FILES:
            continue
        # Skip binary files (PNG, JPEG, etc.) and the .git directory.
        if rel.parts[0] == ".git":
            continue
        if path.suffix in (".png", ".jpg", ".jpeg", ".gif", ".bmp", ".ico",
                            ".tar", ".gz", ".zip", ".pdf"):
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, PermissionError):
            continue
        original = text
        for pattern, replacement in REPLACEMENTS:
            if isinstance(pattern, str):
                text = text.replace(pattern, replacement)
            else:  # compiled regex
                text = pattern.sub(replacement, text)
        if text != original:
            path.write_text(text, encoding="utf-8")
            files_changed += 1
            total_replacements += original.count("orion-os.example.org") \
                                  - text.count("orion-os.example.org")

    print(f"Updated {files_changed} files ({total_replacements} replacements).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
