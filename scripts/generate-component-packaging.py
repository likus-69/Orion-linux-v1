#!/usr/bin/env python3
"""
Generate the remaining PKGBUILD templates and short README files for Orion
desktop components. Run from the repository root:

    python3 scripts/generate-component-packaging.py
"""

from pathlib import Path
from textwrap import dedent

REPO_ROOT = Path(__file__).resolve().parent.parent
PACKAGING_DIR = REPO_ROOT / "packaging"
DESKTOP_DIR = REPO_ROOT / "desktop"

# (component-name, binary-name, description, depends list)
COMPONENTS = [
    ("orion-panel",
     "orion-panel",
     "Orion OS Panel (taskbar) — bottom taskbar with pinned/running apps, system tray",
     ["qt6-base", "qt6-declarative", "qt6-wayland", "qt6-shadertools",
      "layer-shell-qt", "orion-framework", "kwin", "glib2"]),
    ("orion-start-menu",
     "orion-start-menu",
     "Orion OS Start Menu / launcher",
     ["qt6-base", "qt6-declarative", "qt6-wayland", "orion-framework",
      "glib2", "accountsservice"]),
    ("orion-settings",
     "orion-settings",
     "Orion OS unified settings application (7 categories)",
     ["qt6-base", "qt6-declarative", "qt6-wayland", "orion-framework",
      "accountsservice", "networkmanager", "udisks2", "xdg-utils",
      "bluez", "cups", "ufw", "util-linux", "pacman", "wlr-randr"]),
    ("orion-file-manager",
     "orion-file-manager",
     "Orion OS file manager (Explorer-style, tabbed)",
     ["qt6-base", "qt6-declarative", "qt6-wayland", "orion-framework",
      "udisks2", "glib2", "xdg-utils"]),
    ("orion-welcome-center",
     "orion-welcome-center",
     "Orion OS first-run welcome experience (multi-step wizard)",
     ["qt6-base", "qt6-declarative", "qt6-wayland", "orion-framework",
      "networkmanager", "packagekit"]),
    ("orion-software-center",
     "orion-software-center",
     "Orion OS graphical software center (PackageKit-backed)",
     ["qt6-base", "qt6-declarative", "qt6-wayland", "orion-framework",
      "packagekit", "appstream-qt", "polkit", "flatpak"]),
    ("orion-notifications",
     "orion-notifications",
     "Orion OS notification daemon (org.freedesktop.Notifications implementation)",
     ["qt6-base", "qt6-declarative", "qt6-wayland", "orion-framework"]),
    ("orion-quick-settings",
     "orion-quick-settings",
     "Orion OS Quick Settings panel (Wi-Fi/audio/power/battery toggles)",
     ["qt6-base", "qt6-declarative", "qt6-wayland", "orion-framework",
      "networkmanager", "bluez", "pipewire", "wireplumber", "upower",
      "power-profiles-daemon"]),
    ("orion-system-monitor",
     "orion-system-monitor",
     "Orion OS system monitor (CPU/mem/net + process list)",
     ["qt6-base", "qt6-declarative", "qt6-wayland", "orion-framework"]),
    ("orion-update-manager",
     "orion-update-manager",
     "Orion OS Update Manager (PackageKit-backed, runs as user systemd unit)",
     ["qt6-base", "qt6-declarative", "qt6-wayland", "orion-framework",
      "packagekit", "polkit"]),
    ("orion-screenshot-tool",
     "orion-screenshot-tool",
     "Orion OS screenshot utility (full screen / active window / region)",
     ["qt6-base", "qt6-declarative", "qt6-wayland", "orion-framework"]),
    ("orion-search",
     "orion-search",
     "Orion OS desktop search indexer (apps, files, settings)",
     ["qt6-base", "qt6-declarative", "qt6-wayland", "orion-framework"]),
    ("orion-lockscreen",
     "orion-lockscreen",
     "Orion OS lock screen (PAM-authenticated)",
     ["qt6-base", "qt6-declarative", "qt6-wayland", "orion-framework",
      "pam", "pamtester"]),
]

def pkgbuild(name: str, binary: str, desc: str, deps: list[str]) -> str:
    depends = " ".join(f"'{d}'" for d in deps)
    # The desktop directory matches the package name WITHOUT the 'orion-' prefix,
    # except for 'orion-framework' itself which keeps the prefix.
    desktop_dir = name if name == "orion-framework" else name.removeprefix("orion-")
    return dedent(f"""\
        # SPDX-License-Identifier: GPL-3.0-or-later
        # Maintainer: Orion OS Project <likus-69+release@users.noreply.github.com>

        pkgname={name}
        pkgver=0.1.0
        pkgrel=1
        pkgdesc="{desc}"
        arch=('x86_64')
        url="https://github.com/likus-69/Orion-linux-v1.1/"
        license=('GPL-3.0-or-later')
        depends=({depends})
        makedepends=('cmake' 'ninja' 'extra-cmake-modules' 'qt6-tools')
        source=("git+https://github.com/likus-69/Orion-linux-v1.1.git")
        sha256sums=('SKIP')

        build() {{
            cd "$srcdir/Orion-linux-v1.1/desktop/{desktop_dir}"
            cmake -B build -G Ninja \\
                -DCMAKE_BUILD_TYPE=Release \\
                -DCMAKE_INSTALL_PREFIX=/usr
            cmake --build build -j"$(nproc)"
        }}

        package() {{
            cd "$srcdir/Orion-linux-v1.1/desktop/{desktop_dir}"
            DESTDIR="$pkgdir" cmake --install build
        }}
        """)

def readme(name: str, binary: str, desc: str) -> str:
    return dedent(f"""\
        # {name.replace('-', ' ').title()}

        {desc}.

        Part of Orion OS. Depends on `orion-framework` and Qt 6 / QML.

        ## Build

        ```bash
        cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=/usr
        cmake --build build -j$(nproc)
        sudo cmake --install build
        ```

        The binary installs to `/usr/lib/orion/{binary}`.

        ## Known limitations

        - **NOT compiled in the sandbox** (no Qt6 / cmake available).
          Build on a real Arch Linux host with `orion-framework` installed.
        - See `STATUS.md` at the repository root for the current
          implementation state.

        ## License

        GPL-3.0-or-later. See `LICENSE` at the repository root.
        """)

def main() -> int:
    written = 0
    for name, binary, desc, deps in COMPONENTS:
        pkgdir = PACKAGING_DIR / name
        pkgdir.mkdir(parents=True, exist_ok=True)
        (pkgdir / "PKGBUILD").write_text(pkgbuild(name, binary, desc, deps))
        written += 1

        # README for components that don't already have one.
        # Desktop dirs use the short name (panel, settings, etc.); packaging
        # uses the orion- prefix.
        short_name = name.removeprefix("orion-")
        readme_path = DESKTOP_DIR / short_name / "README.md"
        # Don't overwrite existing READMEs (panel/start-menu/settings/etc.
        # already have detailed READMEs).
        if not readme_path.exists():
            readme_path.write_text(readme(name, binary, desc))
            written += 1
    print(f"Wrote {written} files (PKGBUILDs + READMEs).")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
