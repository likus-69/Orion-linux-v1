#!/usr/bin/env bash
# /usr/local/bin/orion-live-setup
#
# Run on first login of the live ISO. Sets up the orion user's home directory
# with Orion defaults, sets the wallpaper, and starts the Welcome Center.
# This is invoked by /etc/profile.d/orion-live.sh on login.

set -euo pipefail

LIVE_USER="orion"
HOME_DIR="/home/${LIVE_USER}"
XDG_DATA_HOME="${HOME_DIR}/.local/share"
XDG_CONFIG_HOME="${HOME_DIR}/.config"
XDG_STATE_HOME="${HOME_DIR}/.local/state"

# Skip if we're not the live user.
if [ "$(id -un)" != "$LIVE_USER" ]; then
    exit 0
fi

# Skip if the user has explicitly dismissed the live setup.
if [ -f "${XDG_STATE_HOME}/orion/live-setup.done" ]; then
    exit 0
fi

mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

# Create the standard XDG user directories (Documents, Downloads, …).
if command -v xdg-user-dirs-update >/dev/null 2>&1; then
    xdg-user-dirs-update --force >/dev/null 2>&1 || true
fi

# Apply the Orion desktop defaults: panel layout, taskbar pinning, accent
# color, theme. The defaults live in /usr/share/orion/defaults/.
if [ -d /usr/share/orion/defaults/home-skeleton ]; then
    cp -r /usr/share/orion/defaults/home-skeleton/. "$HOME_DIR/" 2>/dev/null || true
fi

# Set the wallpaper.
mkdir -p "${XDG_CONFIG_HOME}/orion"
cat > "${XDG_CONFIG_HOME}/orion/desktop.json" <<'EOF'
{
    "wallpaper": "/usr/share/orion/wallpapers/orion-dark.png",
    "theme": "orion-dark",
    "accent": "blue",
    "panel_layout": "centered",
    "panel_height": 48,
    "reduce_animations": false,
    "reduce_transparency": false
}
EOF

# Mark setup as done so we don't run again.
touch "${XDG_STATE_HOME}/orion/live-setup.done"

# Launch the Welcome Center. This is best-effort — if it's not installed, skip
# silently rather than crash the login shell.
if command -v orion-welcome-center >/dev/null 2>&1; then
    nohup orion-welcome-center >/dev/null 2>&1 &
fi
