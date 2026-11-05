# /etc/profile.d/orion-live.sh
# Sourced by bash for every interactive login on the live ISO. Runs the
# live setup script on first login.

# Only run for the live user 'orion'.
if [ "$(id -un 2>/dev/null)" = "orion" ] && [ -x /usr/local/bin/orion-live-setup ]; then
    /usr/local/bin/orion-live-setup >/dev/null 2>&1 || true
fi

# Set Orion-specific environment variables.
export ORION_DESKTOP=1
export XDG_CURRENT_DESKTOP=orion
export XDG_SESSION_DESKTOP=orion
export XDG_CONFIG_DIRS="/etc/xdg:/usr/share/orion/xdg"

# Make 'orion-installer' and 'orion-about' easy to find.
export PATH="/usr/local/bin:$PATH"

# Colored prompt with Orion branding.
PS1='\[\e[38;2;45;127;249m\]orion\[\e[0m\] \[\e[38;5;245m\]\w\[\e[0m\] \$ '
