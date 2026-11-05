#!/usr/bin/env bash
#
# scripts/build-iso.sh — build the Orion OS installation ISO via mkarchiso.
#
# This script is the canonical ISO build. Run on an Arch Linux host after
# scripts/setup-build-env.sh.
#
# Usage:
#   ./scripts/build-iso.sh [--no-sign] [--work-dir <path>] [--out-dir <path>]
#
# Output:
#   distro/archiso/out/orion-os-<version>-x86_64.iso
#   distro/archiso/out/orion-os-<version>-x86_64.iso.sha256
#   distro/archiso/out/orion-os-<version>-x86_64.iso.sha512
#   distro/archiso/out/build-info.json
#
# Reference:
#   https://wiki.archlinux.org/title/Archiso
#   https://man.archlinux.org/man/mkarchiso.1

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ARCHISO_DIR="$REPO_ROOT/distro/archiso"

WORK_DIR="$ARCHISO_DIR/work"
OUT_DIR="$ARCHISO_DIR/out"
SIGN=1

while [ $# -gt 0 ]; do
    case "$1" in
        --no-sign) SIGN=0; shift ;;
        --work-dir) WORK_DIR="$2"; shift 2 ;;
        --out-dir)  OUT_DIR="$2";  shift 2 ;;
        *) echo "Unknown arg: $1" >&2; exit 1 ;;
    esac
done

mkdir -p "$WORK_DIR" "$OUT_DIR"

# ---- Pre-flight checks -----------------------------------------------------
log() { echo "[build-iso] $*"; }
die() { echo "[build-iso] ERROR: $*" >&2; exit 1; }

[ -f "$ARCHISO_DIR/profiledef.sh" ] || die "profiledef.sh missing"
[ -f "$ARCHISO_DIR/packages.x86_64" ] || die "packages.x86_64 missing"
[ -f "$ARCHISO_DIR/pacman.conf" ] || die "pacman.conf missing"
[ -x "$ARCHISO_DIR/airootfs/root/customize_airootfs.sh" ] \
    || die "customize_airootfs.sh missing or not executable"

command -v mkarchiso >/dev/null 2>&1 \
    || die "mkarchiso not found. Run scripts/setup-build-env.sh first."

# Detect the Orion version from profiledef.sh (or fall back to a date stamp).
# shellcheck disable=SC1090
. "$ARCHISO_DIR/profiledef.sh"
ISO_VERSION="${iso_version:-$(date +%Y.%m.%d)}"
ISO_NAME="${iso_name:-orion-os}"
ISO_BASENAME="${ISO_NAME}-${ISO_VERSION}-x86_64"

log "Building Orion OS ISO: $ISO_BASENAME"

# ---- Build the local Orion package repository ------------------------------
# The Orion desktop components are built from packaging/orion-*/PKGBUILD
# templates and assembled into a local repo at distro/repositories/x86_64/.
# mkarchiso reads this repo via the file:/// URL in pacman.conf.
REPO_DIR="$REPO_ROOT/distro/repositories/x86_64"
mkdir -p "$REPO_DIR"

# Stage the repo into the ISO build's pacman cache. mkarchiso mounts the
# local repo at /repo/orion/x86_64/ via its profile; we copy the staged
# packages there.
REPO_STAGE="$ARCHISO_DIR/repo/orion/x86_64"
mkdir -p "$REPO_STAGE"
if [ -n "$(ls -A "$REPO_DIR" 2>/dev/null)" ]; then
    cp -v "$REPO_DIR"/*.pkg.tar.zst "$REPO_STAGE/" || true
fi

# (Re)build the repo database.
if [ -n "$(ls -A "$REPO_STAGE"/*.pkg.tar.zst 2>/dev/null)" ]; then
    log "Refreshing Orion repo database..."
    (cd "$REPO_STAGE" && repo-add orion.db.tar.gz *.pkg.tar.zst) || \
        die "repo-add failed. Are the Orion packages built?"
fi

# If no Orion packages are present, warn but proceed (mkarchiso will fail
# later on the orion-* packages listed in packages.x86_64).
if [ -z "$(ls -A "$REPO_STAGE"/*.pkg.tar.zst 2>/dev/null)" ]; then
    log "WARN: No Orion packages found in $REPO_DIR"
    log "       Run scripts/build-desktop.sh and packaging/make-orion-packages.sh"
    log "       first to populate the repo, or this build will fail."
fi

# ---- Build the ISO via mkarchiso ------------------------------------------
log "Running mkarchiso (this takes 20-60 minutes on typical hardware)..."
BUILD_START="$(date +%s)"

mkarchiso -v \
    -w "$WORK_DIR" \
    -o "$OUT_DIR" \
    "$ARCHISO_DIR" 2>&1 | tee "$OUT_DIR/build.log"

BUILD_END="$(date +%s)"
BUILD_SECS=$((BUILD_END - BUILD_START))
log "mkarchiso completed in ${BUILD_SECS}s"

# ---- Verify the ISO exists -------------------------------------------------
ISO_PATH="$OUT_DIR/${ISO_BASENAME}.iso"
[ -f "$ISO_PATH" ] || die "ISO file not found at $ISO_PATH"

ISO_SIZE_BYTES="$(stat -c %s "$ISO_PATH")"
ISO_SIZE_GB="$((ISO_SIZE_BYTES / 1024 / 1024 / 1024)).$((ISO_SIZE_BYTES / 1024 / 1024 % 1024 / 100))"
log "ISO size: ${ISO_SIZE_GB} GB"

# ---- Compute checksums ----------------------------------------------------
log "Computing SHA256 and SHA512 checksums..."
cd "$OUT_DIR"
sha256sum "${ISO_BASENAME}.iso" > "${ISO_BASENAME}.iso.sha256"
sha512sum "${ISO_BASENAME}.iso" > "${ISO_BASENAME}.iso.sha512"

# ---- Sign the ISO if a signing key is configured --------------------------
if [ "$SIGN" -eq 1 ]; then
    SIGNING_KEY="${ORION_SIGNING_KEY:-}"
    if [ -n "$SIGNING_KEY" ] && command -v gpg >/dev/null; then
        log "Signing ISO with key $SIGNING_KEY..."
        gpg --armor --detach-sign --local-user "$SIGNING_KEY" \
            "${ISO_BASENAME}.iso" || log "  (signing failed; check gpg key)"
    else
        log "Skipping ISO signing (set ORION_SIGNING_KEY env var to enable)."
    fi
fi

# ---- Write build-info.json -------------------------------------------------
log "Writing build-info.json..."
cat > "$OUT_DIR/build-info.json" <<EOF
{
  "name": "$ISO_NAME",
  "version": "$ISO_VERSION",
  "architecture": "x86_64",
  "iso_path": "${ISO_BASENAME}.iso",
  "iso_size_bytes": $ISO_SIZE_BYTES,
  "build_host": "$(hostname)",
  "build_user": "$(whoami)",
  "build_start_epoch": $BUILD_START,
  "build_end_epoch": $BUILD_END,
  "build_duration_seconds": $BUILD_SECS,
  "kernel": "$(uname -r)",
  "pacman_version": "$(pacman --version 2>/dev/null | head -1 || echo 'unknown')",
  "archiso_version": "$(mkarchiso --version 2>&1 | head -1 || echo 'unknown')",
  "signed": $([ -f "${ISO_BASENAME}.iso.asc" ] && echo true || echo false),
  "build_timestamp_utc": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

log ""
log "============================================================"
log "  ISO BUILD COMPLETE"
log "============================================================"
log "  ISO:       $OUT_DIR/${ISO_BASENAME}.iso"
log "  SHA256:    $OUT_DIR/${ISO_BASENAME}.iso.sha256"
log "  SHA512:    $OUT_DIR/${ISO_BASENAME}.iso.sha512"
log "  Build log: $OUT_DIR/build.log"
log "  Info:      $OUT_DIR/build-info.json"
log ""
log "To boot-test in QEMU:"
log "  ./scripts/test-iso-qemu.sh $OUT_DIR/${ISO_BASENAME}.iso"
log ""
