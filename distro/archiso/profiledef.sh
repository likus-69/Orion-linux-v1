#!/usr/bin/env bash
#
# Orion OS — Archiso profile definition
#
# Read by mkarchiso. Defines the profile name, the ISO label, the publisher,
# the application (ISO title), the boot modes supported, and the file
# structure of the resulting ISO image.
#
# Reference: https://wiki.archlinux.org/title/Archiso

# shellcheck disable=SC2034

iso_name="orion-os"
iso_label="ORIONOS_$(date +%Y%m)"
iso_publisher="Orion OS Project <https://github.com/likus-69/Orion-linux-v1.1>"
iso_application="Orion OS Live/Install Media"
iso_version="$(date +%Y.%m.%d)"
install_dir="orion"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-x64.systemd-boot.esp'
           'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ['/etc/shadow']='0400'
  ['/etc/gshadow']='0400'
  ['/usr/local/bin/orion-live-autologin']='0755'
  ['/usr/local/bin/orion-hardware-scan']='0755'
  ['/usr/local/bin/orion-about']='0755'
  ['/usr/local/bin/orion-installer']='0755'
  ['/root/.automated_script.sh']='0755'
  ['/root/orion-live-setup.sh']='0755'
  ['/etc/polkit-1/rules.d/10-orion-live.rules']='0644'
)
