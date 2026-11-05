#!/usr/bin/env bash
#
# scripts/setup-build-env.sh — install and verify build dependencies on an
# Arch Linux host. Run this before scripts/build-iso.sh or scripts/build-desktop.sh.
#
# This script is idempotent: re-running it only installs what's missing.
#
# Reference: docs/installation.md
#
# Usage:
#   sudo ./scripts/setup-build-env.sh
#         [--with-qemu]   install QEMU + OVMF for ISO boot testing
#         [--with-tests]  install Python test deps (pytest, etc.)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="/tmp/orion-setup-env-$(date +%s).log"

WITH_QEMU=0
WITH_TESTS=0
for arg in "$@"; do
    case "$arg" in
        --with-qemu) WITH_QEMU=1 ;;
        --with-tests) WITH_TESTS=1 ;;
        *) echo "Unknown arg: $arg" >&2; exit 1 ;;
    fi
done

log() { echo "[setup-env] $*" | tee -a "$LOG_FILE"; }
die() { echo "[setup-env] ERROR: $*" >&2; exit 1; }

# ---- Verify we're on Arch Linux --------------------------------------------
if ! command -v pacman >/dev/null 2>&1; then
    die "pacman not found. This script must run on an Arch Linux host.
         The current host is $(grep ^PRETTY_NAME /etc/os-release 2>/dev/null || echo 'unknown').
         See docs/installation.md for setup instructions on non-Arch hosts."
fi

# ---- Verify root or sudo ---------------------------------------------------
if [ "$(id -u)" -ne 0 ]; then
    if ! command -v sudo >/dev/null; then
        die "Need root or sudo. Run with: sudo $0 $*"
    fi
    SUDO="sudo"
else
    SUDO=""
fi

# ---- Core dependencies -----------------------------------------------------
PKGS=(
    base-devel
    git
    archiso
    calamares
    calamares-branding-orion
    qt6-base
    qt6-declarative
    qt6-wayland
    qt6-tools
    qt6-shadertools
    qt6-svg
    extra-cmake-modules
    cmake
    ninja
    python
    python-pytest
    python-cairosvg
    python-dbus
    python-gobject
    networkmanager
    pacman-contrib
    reflector
    archlinux-keyring
    appstream
    appstream-qt
    polkit
    packagekit
    ninja
    bash-completion
    shellcheck
    clang
    clang-format
    clang-tidy
    pkgconf
    hicolor-icon-theme
)

if [ "$WITH_QEMU" -eq 1 ]; then
    PKGS+=(qemu-desktop ovmf seabios)
fi

if [ "$WITH_TESTS" -eq 1 ]; then
    PKGS+=(python-pytest-cov python-pytest-xdist python-mock)
fi

log "Installing ${#PKGS[@]} packages via pacman..."
$SUDO pacman -S --needed --noconfirm "${PKGS[@]}" 2>&1 | tee -a "$LOG_FILE"

# ---- Verify versions ------------------------------------------------------
log "Verifying installed versions..."
verify() {
    local cmd="$1"
    local expected_min="$2"
    local actual
    actual="$(command -v "$cmd" >/dev/null 2>&1 && "$cmd" --version 2>&1 | head -1 || echo 'NOT INSTALLED')"
    log "  $cmd -> $actual"
}

verify mkarchiso "71"
verify cmake "3.28"
verify ninja "1.11"
verify qmake6 "6.6"
verify python3 "3.11"

if ! command -v mkarchiso >/dev/null 2>&1; then
    die "mkarchiso is missing despite the archiso package installation.
         Check pacman output above."
fi

# ---- Initialize the local Orion package repository -------------------------
REPO_DIR="$REPO_ROOT/distro/repositories/x86_64"
log "Initializing local Orion repository at $REPO_DIR"
mkdir -p "$REPO_DIR"

# The repository database is empty until scripts/build-iso.sh populates it.
# We don't sign it here; signing is a release-engineering step (see
# docs/release-process.md).

# Generate or verify pacman config points at the local repo.
if ! grep -q '\[orion\]' "$REPO_ROOT/distro/archiso/pacman.conf"; then
    die "pacman.conf does not have an [orion] repo stanza. This should not happen;
         check distro/archiso/pacman.conf."
fi

# ---- Create the work/ and out/ directories used by mkarchiso --------------
mkdir -p "$REPO_ROOT/distro/archiso/work" "$REPO_ROOT/distro/archiso/out"

# ---- Verify Qt6 wayland plugin (needed for desktop builds) ----------------
QT_PLUGIN_PATH="$(qmake6 -query QT_INSTALL_PLUGINS 2>/dev/null || true)"
if [ -n "$QT_PLUGIN_PATH" ] && [ ! -d "$QT_PLUGIN_PATH/platforms" ]; then
    log "WARN: Qt6 platform plugins directory not found at $QT_PLUGIN_PATH.
         Qt6 Wayland build may be incomplete."
fi

# ---- Initialize pacman keyring (idempotent) --------------------------------
if [ "$(id -u)" -eq 0 ]; then
    log "Initializing pacman keyring (idempotent)..."
    pacman-key --init 2>&1 | tee -a "$LOG_FILE" || log "  (keyring already initialized)"
    pacman-key --populate archlinux 2>&1 | tee -a "$LOG_FILE" || true
else
    log "Skipping pacman-key init (need root). Run 'sudo pacman-key --init' separately if needed."
fi

log ""
log "Setup complete. Next steps:"
log "  1. ./scripts/build-desktop.sh      # build all Orion desktop components"
log "  2. ./scripts/build-iso.sh          # build the Orion OS ISO"
if [ "$WITH_QEMU" -eq 1 ]; then
    log "  3. ./scripts/test-iso-qemu.sh <iso-path>   # boot-test the ISO"
fi
log ""
log "Log: $LOG_FILE"
