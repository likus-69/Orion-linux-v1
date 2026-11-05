#!/usr/bin/env bash
#
# customize_airootfs.sh — runs inside the chroot during `mkarchiso` build.
# This script customizes the live ISO's root filesystem after packages have
# been installed but before the squashfs image is created.
#
# Reference: https://wiki.archlinux.org/title/Archiso#Profile-wide_customization
#
# Conventions:
#   - The script runs as root inside the chroot. The chroot's root is the
#     future ISO's root.
#   - We must not start systemd services here (the chroot has no running
#     init). We use `systemctl enable` only, never `--now`.
#   - We must not write to /dev, /proc, /sys — those are not mounted in the
#     build chroot.

set -euo pipefail

echo ":: Orion OS: customize_airootfs.sh starting"

# ---- Locale + timezone -----------------------------------------------------
echo ":: Configuring locale and timezone"
sed -i 's/^#\s*\(en_US.UTF-8\)/\1/; s/^#\s*\(en_GB.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Default timezone for the live ISO. The installer changes this on the
# installed system based on the user's choice.
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Locale for the live ISO. The installer changes this based on user choice.
cat > /etc/locale.conf <<'EOF'
LANG=en_US.UTF-8
LC_TIME=en_GB.UTF-8
EOF

cat > /etc/vconsole.conf <<'EOF'
KEYMAP=us
FONT=eurlatb
EOF

# ---- Hostname + hosts ------------------------------------------------------
echo ":: Configuring hostname and hosts"
echo "orion-os" > /etc/hostname
cat > /etc/hosts <<'EOF'
127.0.0.1   localhost
::1         localhost ip6-localhost ip6-loopback
127.0.1.1   orion-os.localdomain orion-os
EOF

# ---- os-release (Orion identity) -------------------------------------------
echo ":: Writing /etc/os-release"
BUILD_ID="$(date +%Y%m%d)"
cat > /etc/os-release <<EOF
NAME="Orion OS"
ID=orion-os
ID_LIKE=arch
PRETTY_NAME="Orion OS"
VERSION="v2026.10"
VERSION_ID="2026.10"
VERSION_CODENAME=orion
ANSI_COLOR="38;2;45;127;249"
HOME_URL="https://github.com/likus-69/Orion-linux-v1.1/"
DOCUMENTATION_URL="https://github.com/likus-69/Orion-linux-v1.1/tree/main/docs/"
SUPPORT_URL="https://github.com/likus-69/Orion-linux-v1.1/issues/"
BUG_REPORT_URL="https://github.com/likus-69/Orion-linux-v1.1/issues/"
LOGO=orion-os
BUILD_ID="$BUILD_ID"
EOF

# Also create /usr/lib/os-release as a fallback for tools that look there.
cp /etc/os-release /usr/lib/os-release

# ---- Live user account -----------------------------------------------------
# The live ISO logs in as user "orion" without a password. This is only on
# the live ISO, NOT on the installed system (the installer creates a real
# user with a real password).
echo ":: Creating live user 'orion'"
if ! id orion >/dev/null 2>&1; then
    useradd -m -G wheel,network,audio,video,input,storage,lp,rfkill -s /bin/bash orion
    passwd -d orion
    # Lock root on the live ISO — sudo via 'wheel' is the only auth path.
    passwd -l root
fi

# Allow wheel to sudo without a password on the live ISO only.
cat > /etc/sudoers.d/10-orion-live <<'EOF'
# Live ISO: allow wheel to sudo without a password.
# This file is REMOVED by the Calamares post-install module on the installed
# system, where a real password is required.
Defaults:%wheel !authenticate
%wheel ALL=(ALL) ALL
EOF
chmod 0440 /etc/sudoers.d/10-orion-live

# ---- Autologin (live ISO only) --------------------------------------------
echo ":: Configuring SDDM autologin"
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/10-autologin.conf <<'EOF'
[Autologin]
User=orion
Session=orion
EOF

# Enable the SDDM service on boot of the live ISO.
systemctl enable sddm.service

# ---- NetworkManager (live ISO) --------------------------------------------
echo ":: Enabling NetworkManager"
systemctl enable NetworkManager.service
systemctl enable NetworkManager-wait-online.service

# Disable sshd, cups, avahi — not needed on the live ISO.
systemctl disable sshd.service 2>/dev/null || true
systemctl disable cups.service 2>/dev/null || true
systemctl disable avahi-daemon.service 2>/dev/null || true

# ---- Polkit policy for the live ISO ---------------------------------------
# The live ISO allows the orion user to install packages without prompting,
# because there is no password to enter anyway. The installed system uses
# a stricter policy (see distro/defaults/polkit/).
echo ":: Installing live ISO polkit policy"
cat > /etc/polkit-1/rules.d/10-orion-live.rules <<'EOF'
// Live-ISO polkit policy: allow wheel members to do package operations
// without authentication prompts (because the live user has no password).
// This rule is REMOVED by the Calamares post-install module on the installed
// system, where standard polkit rules apply.
polkit.addRule(function(action, subject) {
    if (subject.isInGroup("wheel")) {
        if (action.id == "org.freedesktop.packagekit.package-install" ||
            action.id == "org.freedesktop.packagekit.package-remove" ||
            action.id == "org.freedesktop.packagekit.system-update" ||
            action.id.indexOf("org.orion.") === 0) {
            return polkit.Result.YES;
        }
    }
});
EOF

# ---- Enable Orion desktop services ----------------------------------------
# These are user services; enabling them creates the symlink that the user
# session picks up on first login. They run as the orion user.
echo ":: Enabling Orion user services"
mkdir -p /etc/systemd/user/default.target.wants
for svc in orion-panel orion-start-menu orion-notifications orion-update-manager orion-quick-settings orion-search; do
    if [ -f "/usr/lib/systemd/user/${svc}.service" ]; then
        ln -sf "/usr/lib/systemd/user/${svc}.service" \
            "/etc/systemd/user/default.target.wants/${svc}.service"
    fi
done

# ---- Branding: copy default wallpaper, set SDDM theme ---------------------
echo ":: Applying Orion branding"
mkdir -p /usr/share/wallpapers/Orion/contents/images
if [ -f /usr/share/orion/wallpapers/orion-dark.png ]; then
    ln -sf /usr/share/orion/wallpapers/orion-dark.png \
        /usr/share/wallpapers/Orion/contents/images/default.png
fi

# ---- Plymouth (boot splash) ------------------------------------------------
echo ":: Configuring Plymouth"
mkdir -p /etc/plymouth
cat > /etc/plymouth/plymouthd.conf <<'EOF'
[Daemon]
Theme=orion
ShowDelay=2
DeviceTimeout=8
EOF
plymouth-set-default-theme orion 2>/dev/null || true

# Add plymouth to the mkinitcpio HOOKS so the boot splash shows during boot.
if [ -f /etc/mkinitcpio.conf ]; then
    sed -i 's/^HOOKS=(.*/HOOKS=(base udev plymouth autodetect microcode modconf kms block filesystems keyboard fsck)/' /etc/mkinitcpio.conf
fi

# ---- Mirrorlist (reflector) ------------------------------------------------
# Pre-populate a basic mirrorlist in case reflector can't fetch one at boot.
echo ":: Populating mirrorlist"
cat > /etc/pacman.d/mirrorlist <<'EOF'
# Generated by Orion OS at ISO build time.
# Run `sudo reflector --latest 50 --protocol https --sort rate --save /etc/pacman.d/mirrorlist`
# at boot to refresh.
Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch
Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch
EOF

# ---- Live ISO helper scripts ----------------------------------------------
# These ship in the ISO and are used by the live session.
echo ":: Installing live-ISO helper scripts"
for f in orion-live-setup orion-live-autologin orion-hardware-scan orion-about orion-installer; do
    src="/root/${f}.sh"
    dst="/usr/local/bin/${f}"
    [ -f "$src" ] && install -Dm755 "$src" "$dst"
done

# ---- Final cleanup ---------------------------------------------------------
echo ":: Final cleanup"
rm -rf /etc/pacman.d/gnupg 2>/dev/null || true
pacman -Scc --noconfirm 2>/dev/null || true
rm -f /root/.bash_history /home/orion/.bash_history

echo ":: Orion OS: customize_airootfs.sh complete"
