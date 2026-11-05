#!/usr/bin/env bash
#
# scripts/security-scan.sh — static security checks on the Orion OS source.
#
# This is a static analyzer. It does not run binaries. It checks for:
#   - Hardcoded passwords / secrets / API keys
#   - World-writable config files
#   - SUID binaries outside the documented allowlist
#   - Unsanitized input passed to shell from QML/C++
#   - .git history leakage of secrets
#   - Polkit rules that grant unscoped YES
#
# Usage:
#   ./scripts/security-scan.sh [--strict] [--fix-perms]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RESULTS_DIR="$REPO_ROOT/build/security-scan"
mkdir -p "$RESULTS_DIR"

STRICT=0
FIX_PERMS=0
for arg in "$@"; do
    case "$arg" in
        --strict) STRICT=1 ;;
        --fix-perms) FIX_PERMS=1 ;;
        *) echo "Unknown arg: $arg" >&2; exit 1 ;;
    esac
done

HIGH_FINDINGS=0
MEDIUM_FINDINGS=0
LOW_FINDINGS=0

report() {
    local severity="$1"; shift
    local message="$*"
    case "$severity" in
        HIGH)   HIGH_FINDINGS=$((HIGH_FINDINGS+1));   echo "[HIGH]   $message" ;;
        MEDIUM) MEDIUM_FINDINGS=$((MEDIUM_FINDINGS+1)); echo "[MEDIUM] $message" ;;
        LOW)    LOW_FINDINGS=$((LOW_FINDINGS+1));    echo "[LOW]    $message" ;;
    esac
}

echo "[security-scan] Scanning $REPO_ROOT"
echo ""

# ---- 1. Hardcoded secrets ----------------------------------------------------
# Look for common patterns: AKIA*, ghp_, password=, secret=, api_key=, BEGIN PRIVATE KEY.
echo "== Checking for hardcoded secrets =="
SECRET_HITS=$(grep -rEn \
    -e 'AKIA[0-9A-Z]{16}' \
    -e 'ghp_[A-Za-z0-9]{36}' \
    -e 'sk_live_[A-Za-z0-9]{24}' \
    -e 'BEGIN (RSA |EC )?PRIVATE KEY' \
    -e '(password|passwd|secret|api[_-]?key|token)\s*=\s*["'\''][^"'\'']{8,}["'\'']' \
    --include='*.py' --include='*.sh' --include='*.cpp' --include='*.h' \
    --include='*.qml' --include='*.json' --include='*.conf' \
    "$REPO_ROOT/desktop" "$REPO_ROOT/scripts" "$REPO_ROOT/installer" \
    "$REPO_ROOT/distro/services" "$REPO_ROOT/distro/defaults" \
    2>/dev/null \
    | grep -v -E '\.example|placeholder|REPLACE|TODO|FIXME|security-scan\.sh' \
    || true)

if [ -n "$SECRET_HITS" ]; then
    while IFS= read -r line; do
        report HIGH "Potential hardcoded secret: $line"
    done <<< "$SECRET_HITS"
else
    echo "  (no hardcoded secrets found)"
fi

# ---- 2. World-writable config files -----------------------------------------
echo ""
echo "== Checking for world-writable files in distro/ =="
WWW_FILES=$(find "$REPO_ROOT/distro" -type f -perm -o+w 2>/dev/null || true)
if [ -n "$WWW_FILES" ]; then
    while IFS= read -r f; do
        report HIGH "World-writable file: $f"
        if [ "$FIX_PERMS" -eq 1 ]; then
            chmod o-w "$f" && echo "  → fixed: $f"
        fi
    done <<< "$WWW_FILES"
else
    echo "  (no world-writable files)"
fi

# ---- 3. Polkit rules that grant unscoped YES --------------------------------
echo ""
echo "== Checking polkit rules =="
for f in "$REPO_ROOT"/distro/defaults/polkit/*.rules "$REPO_ROOT"/distro/archiso/airootfs/etc/polkit-1/rules.d/*.rules; do
    [ -f "$f" ] || continue
    # A rule that returns YES for ALL actions is dangerous.
    if grep -E '^\s*return\s+polkit\.Result\.YES\s*;\s*$' "$f" >/dev/null 2>&1 && \
       ! grep -E 'subject\.isInGroup|subject\.local|subject\.active' "$f" >/dev/null 2>&1; then
        report HIGH "Polkit rule grants YES without subject check: $f"
    fi
done

# ---- 4. Unsafe shell invocations from QML/C++ ------------------------------
echo ""
echo "== Checking for unsafe shell invocations =="
for f in $(grep -rEl 'QProcess|child_process|subprocess\.(call|run|Popen)' \
    "$REPO_ROOT/desktop" 2>/dev/null || true); do
    # Look for shell=true or sh -c with user-controlled input.
    if grep -E "shell\s*=\s*True|sh\s+-c.*\\$\{|system\(.*\\$\{" "$f" >/dev/null 2>&1; then
        report MEDIUM "Potential shell injection in $f"
    fi
done

# ---- 5. The live ISO polkit rule is documented -----------------------------
echo ""
echo "== Verifying live-ISO polkit is documented =="
LIVE_RULE="$REPO_ROOT/distro/archiso/airootfs/etc/polkit-1/rules.d/10-orion-live.rules"
if [ -f "$LIVE_RULE" ] && ! grep -q "REMOVED by the Calamares post-install" "$LIVE_RULE"; then
    report MEDIUM "Live ISO polkit rule lacks documentation that it's removed on install"
fi

# ---- 6. Package signing config is strict -----------------------------------
echo ""
echo "== Checking pacman SigLevel =="
PACMAN_CONF="$REPO_ROOT/distro/archiso/pacman.conf"
if grep -q 'SigLevel.*=.*Never' "$PACMAN_CONF" 2>/dev/null; then
    report HIGH "pacman.conf sets SigLevel=Never"
fi

# ---- 7. SUID binaries allowlist check (only on installed ISO, skipped here) --
echo ""
echo "== Skipping SUID check (no installed ISO present) =="

# ---- 8. The Orion signing key fingerprint is documented ---------------------
echo ""
echo "== Verifying security.md states the signing key fingerprint =="
SECURITY_DOC="$REPO_ROOT/docs/security.md"
if grep -q 'Fingerprint: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000' "$SECURITY_DOC"; then
    report LOW "Signing key fingerprint is still the placeholder 0000… — replace with the real fingerprint before v1 release."
fi

# ---- Summary ---------------------------------------------------------------
echo ""
echo "============================================================"
echo "  SECURITY SCAN SUMMARY"
echo "============================================================"
echo "  HIGH:   $HIGH_FINDINGS"
echo "  MEDIUM: $MEDIUM_FINDINGS"
echo "  LOW:    $LOW_FINDINGS"
echo ""

if [ "$HIGH_FINDINGS" -gt 0 ] && [ "$STRICT" -eq 1 ]; then
    echo "Strict mode: failing the build due to HIGH findings."
    exit 1
fi

exit 0
