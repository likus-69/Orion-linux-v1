#!/usr/bin/env bash
# /usr/local/bin/orion-about — print Orion OS system information
# Installed into the live ISO by customize_airootfs.sh.

set -euo pipefail

print_kv() {
    printf "%-22s %s\n" "$1:" "$2"
}

echo "============================================================"
echo "  Orion OS — System Information"
echo "============================================================"
echo ""

if [ -r /etc/os-release ]; then
    . /etc/os-release
    print_kv "OS"         "${PRETTY_NAME:-Orion OS}"
    print_kv "Version"    "${VERSION:-unknown}"
    print_kv "Codename"   "${VERSION_CODENAME:-orion}"
    print_kv "Build ID"   "${BUILD_ID:-unknown}"
    print_kv "Base"        "${ID_LIKE:-arch}"
fi

print_kv "Kernel"     "$(uname -r)"
print_kv "Hostname"   "$(hostname)"
print_kv "Architecture" "$(uname -m)"
print_kv "Uptime"     "$(uptime -p 2>/dev/null || true)"
print_kv "Date"       "$(date)"

echo ""
echo "  Hardware"
echo "------------------------------------------------------------"
print_kv "CPU"        "$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs 2>/dev/null || echo 'unknown')"
print_kv "CPU cores"  "$(nproc 2>/dev/null || echo 'unknown')"
print_kv "Memory"     "$(free -h | awk '/^Mem:/ {print $2}') total"
print_kv "GPU"        "$(lspci 2>/dev/null | awk -F': ' '/VGA|3D/ {print $3}' | head -1 || echo 'unknown')"

echo ""
echo "  Network"
echo "------------------------------------------------------------"
if command -v nmcli >/dev/null; then
    nmcli -t -f NAME,DEVICE,STATE connection show --active 2>/dev/null \
        | awk -F: '{printf "  %-22s %s (%s)\n", $1, $2, $3}' || true
fi

echo ""
echo "  Disk"
echo "------------------------------------------------------------"
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT 2>/dev/null | sed 's/^/  /'

echo ""
echo "============================================================"
echo "  Orion OS — https://github.com/likus-69/Orion-linux-v1.1/"
echo "============================================================"
