#!/usr/bin/env bash
# /usr/local/bin/orion-installer
#
# Launches the Calamares installer with the Orion configuration. The desktop
# icon, the Start Menu entry, and the Welcome Center's "Install" button all
# exec this script.

set -euo pipefail

# Ensure we're not running as root — Calamares elevates via pkexec internally.
if [ "$(id -u)" -eq 0 ]; then
    echo "orion-installer: refusing to run as root. Run as the live user 'orion'." >&2
    exit 1
fi

# Verify we're on the live ISO.
if [ ! -f /run/archiso/airootfs.sfs ]; then
    echo "orion-installer: this script is intended for the live ISO." >&2
    echo "  If you have already installed Orion OS, run 'orion-software-center'" >&2
    echo "  to install additional packages." >&2
    exit 1
fi

# Sanity: ensure calamares binary is present.
if ! command -v calamares >/dev/null; then
    echo "orion-installer: calamares not found in PATH. Reinstall 'calamares'." >&2
    exit 1
fi

# Set up environment for the installer.
export ORION_INSTALLER=1
export CALAMARES_CONFIG_DIR=/etc/calamares
export QT_QPA_PLATFORMTHEME=orion

# Run Calamares with the Orion branding.
exec pkexec calamares -d -c "$CALAMARES_CONFIG_DIR"
