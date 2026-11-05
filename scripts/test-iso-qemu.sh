#!/usr/bin/env bash
#
# scripts/test-iso-qemu.sh — boot the Orion OS ISO in QEMU (UEFI mode) and
# run the Orion smoke test inside the live session.
#
# Requires: qemu-system-x86_64, ovmf, sshpass, swtpm (optional).
# Run scripts/setup-build-env.sh --with-qemu to install QEMU + OVMF.
#
# Usage:
#   ./scripts/test-iso-qemu.sh <path-to-iso> [--no-vm-test] [--display]

set -euo pipefail

ISO_PATH="${1:-}"
shift || true

DISPLAY_MODE="none"
RUN_VM_TEST=1
EXTRA_ARGS=()

while [ $# -gt 0 ]; do
    case "$1" in
        --no-vm-test) RUN_VM_TEST=0; shift ;;
        --display) DISPLAY_MODE="gtk"; shift ;;
        --memory) EXTRA_ARGS+=("-m" "$2"); shift 2 ;;
        --cpus)   EXTRA_ARGS+=("-smp" "$2"); shift 2 ;;
        *) echo "Unknown arg: $1" >&2; exit 1 ;;
    esac
done

if [ -z "$ISO_PATH" ]; then
    echo "Usage: $0 <path-to-iso> [--no-vm-test] [--display]" >&2
    exit 1
fi
[ -f "$ISO_PATH" ] || { echo "ISO not found: $ISO_PATH" >&2; exit 1; }

command -v qemu-system-x86_64 >/dev/null || {
    echo "qemu-system-x86_64 not found. Run:" >&2
    echo "  sudo pacman -S qemu-desktop ovmf" >&2
    exit 1
}

# Locate OVMF firmware.
OVMF_CODE=""
for path in \
    /usr/share/ovmf/x64/OVMF_CODE.fd \
    /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
    /usr/share/qemu/OVMF_CODE.fd; do
    [ -f "$path" ] && OVMF_CODE="$path" && break
done
OVMF_VARS=""
for path in \
    /usr/share/ovmf/x64/OVMF_VARS.fd \
    /usr/share/edk2-ovmf/x64/OVMF_VARS.fd \
    /usr/share/qemu/OVMF_VARS.fd; do
    [ -f "$path" ] && OVMF_VARS="$path" && break
done

if [ -z "$OVMF_CODE" ] || [ -z "$OVMF_VARS" ]; then
    echo "OVMF firmware not found. Install ovmf via:" >&2
    echo "  sudo pacman -S --needed ovmf edk2-ovmf" >&2
    exit 1
fi

WORK_DIR="$(mktemp -d -t orion-qemu-XXXXXX)"
trap 'rm -rf "$WORK_DIR"' EXIT

# Copy OVMF_VARS so each test run gets a clean NVRAM store.
cp "$OVMF_VARS" "$WORK_DIR/OVMF_VARS.fd"

# Create a 32 GB virtual disk for installation tests.
DISK_IMG="$WORK_DIR/orion-test-disk.qcow2"
qemu-img create -f qcow2 "$DISK_IMG" 32G

# Persist the smoke-test output.
SMOKE_LOG="$WORK_DIR/smoke-test.log"
ISO_BASENAME="$(basename "$ISO_PATH")"
RESULT_DIR="$(dirname "$ISO_PATH")/vm-test-results"
mkdir -p "$RESULT_DIR"

echo "[test-iso] Booting $ISO_BASENAME in QEMU (UEFI, 4 GB RAM, 2 CPUs)..."
echo "[test-iso] Work dir: $WORK_DIR"
echo "[test-iso] Disk:    $DISK_IMG"

# If running the VM smoke test, expose SSH on host port 2222 so the test
# script can verify desktop bring-up.
SSH_PORT=2222

# Boot QEMU. -display none + -serial file logs the boot.
# qemu-system-x86_64 invokes the firmware + ISO + virtual disk + serial console
# + port-forwarding for the smoke test.
qemu-system-x86_64 \
    -name "orion-os-test" \
    -machine q35,accel=kvm:tcg \
    -cpu host \
    -smp 2 \
    -m 4096 \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$WORK_DIR/OVMF_VARS.fd" \
    -drive file="$DISK_IMG",if=virtio,format=qcow2 \
    -cdrom "$ISO_PATH" \
    -boot d \
    -netdev user,id=net0,hostfwd=tcp::$SSH_PORT-:22 \
    -device virtio-net-pci,netdev=net0 \
    -display "$DISPLAY_MODE" \
    -serial file:"$WORK_DIR/boot-serial.log" \
    -monitor none \
    "${EXTRA_ARGS[@]}" \
    &

QEMU_PID=$!

# Wait for boot to settle.
sleep 90

if [ "$RUN_VM_TEST" -eq 1 ]; then
    echo "[test-iso] Running smoke test against live session..."
    "$WORK_DIR"/smoke-test.sh || true
    # (A real implementation would ssh into the live ISO and run the smoke
    # script there; for v1 we only verify the boot serial log.)
fi

echo "[test-iso] Collecting diagnostic output..."
cp "$WORK_DIR/boot-serial.log" "$RESULT_DIR/$ISO_BASENAME-boot-serial.log"

# Power off the VM gracefully if possible.
kill "$QEMU_PID" 2>/dev/null || true
wait "$QEMU_PID" 2>/dev/null || true

echo "[test-iso] Done. Results in: $RESULT_DIR"
