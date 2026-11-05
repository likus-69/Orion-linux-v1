#!/usr/bin/env bash
# /usr/local/bin/orion-hardware-scan
#
# Detects known-hardware that requires out-of-tree drivers (NVIDIA, Broadcom
# Wi-Fi) and prints a JSON object describing what was detected. The Orion
# Welcome Center consumes this to suggest driver installation.

set -euo pipefail

declare -A NVIDIA_GPUS=()
declare -A BROADCOM_WIFI=()

# Scan PCI devices
if command -v lspci >/dev/null; then
    while IFS= read -r line; do
        # Match VGA / 3D controllers
        if [[ "$line" =~ (VGA|3D|Display) ]]; then
            if [[ "$line" =~ NVIDIA ]]; then
                pci_id="$(echo "$line" | awk '{print $1}')"
                NVIDIA_GPUS["$pci_id"]="$line"
            fi
        fi
        # Match Network controllers
        if [[ "$line" =~ Network ]]; then
            if [[ "$line" =~ Broadcom ]]; then
                pci_id="$(echo "$line" | awk '{print $1}')"
                BROADCOM_WIFI["$pci_id"]="$line"
            fi
        fi
    done < <(lspci -nn)
fi

# Build JSON output
{
    echo "{"
    echo "  \"timestamp\": \"$(date -Iseconds)\","
    echo "  \"kernel\": \"$(uname -r)\","
    echo "  \"nvidia_gpus\": ["
    first=1
    for pci_id in "${!NVIDIA_GPUS[@]}"; do
        if [ $first -eq 1 ]; then first=0; else echo ","; fi
        printf '    {"pci_id": "%s", "description": "%s"}' \
            "$pci_id" "${NVIDIA_GPUS[$pci_id]#* }"
    done
    echo ""
    echo "  ],"
    echo "  \"broadcom_wifi\": ["
    first=1
    for pci_id in "${!BROADCOM_WIFI[@]}"; do
        if [ $first -eq 1 ]; then first=0; else echo ","; fi
        printf '    {"pci_id": "%s", "description": "%s"}' \
            "$pci_id" "${BROADCOM_WIFI[$pci_id]#* }"
    done
    echo ""
    echo "  ],"
    echo "  \"suggested_packages\": ["
    suggestions=""
    if [ ${#NVIDIA_GPUS[@]} -gt 0 ]; then
        suggestions="\"nvidia-dkms\", \"nvidia-utils\", \"lib32-nvidia-utils\""
    fi
    if [ ${#BROADCOM_WIFI[@]} -gt 0 ]; then
        if [ -n "$suggestions" ]; then suggestions="$suggestions, "; fi
        suggestions="$suggestions\"broadcom-wl-dkms\""
    fi
    echo "    $suggestions"
    echo "  ]"
    echo "}"
}
