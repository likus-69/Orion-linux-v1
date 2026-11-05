#!/usr/bin/env bash
# /usr/local/bin/orion-live-autologin
#
# Called by SDDM's autologin on the live ISO. Sets up the user's environment
# before the desktop session starts.

set -euo pipefail

LIVE_USER="orion"
SESSION="orion"

if [ "$(id -un)" != "$LIVE_USER" ]; then
    exit 0
fi

# Initialize the orion user's XDG directories on first login.
mkdir -p \
    "$HOME/.config" \
    "$HOME/.local/share" \
    "$HOME/.local/state" \
    "$HOME/.cache" 2>/dev/null || true

# Run the live setup script once.
/usr/local/bin/orion-live-setup || true

# Export environment for the Orion desktop session.
export XDG_CURRENT_DESKTOP=orion
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=orion
export DESKTOP_SESSION=orion
export QT_QPA_PLATFORMTHEME=orion
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=0
export SDL_VIDEODRIVER=wayland
export MOZ_ENABLE_WAYLAND=1
export MOZ_DBUS_REMOTE=1
export _JAVA_AWT_WM_NONREPARENTING=1

exec "$@"
