# Orion Software Center

Graphical package manager for Orion OS. Built on **PackageKit** — never
shells out to `pacman` as root. The GUI is unprivileged; all privileged
operations go through PackageKit's D-Bus interface and its polkit policy.

## Features

- Browse applications by category (uses AppStream metadata).
- Search packages across all configured repositories.
- View app details with screenshots, dependencies, repository origin.
- Install / remove packages.
- Show update availability and apply updates.
- Clearly labeled package origins: Arch official, Orion OS, Flatpak, AUR.
- AUR is **off by default**. When enabled, every AUR install requires a
  separate polkit prompt (no caching) and a clear warning that AUR packages
  execute arbitrary build scripts.

## Sources

| Source | Default | Trust |
|---|---|---|
| Arch official (core / extra / multilib) | on | Signed by archlinux-keyring |
| Orion OS repository | on | Signed by orion-keyring (fingerprint in `docs/security.md`) |
| Flatpak (Flathub) | on | Sandboxed; Portal-mediated |
| Arch User Repository (AUR) | **off** | Community build scripts; opt-in only |

## Build

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j$(nproc)
sudo cmake --install build
```

## D-Bus usage

Service: `org.freedesktop.PackageKit` (system bus).

The Software Center uses these PackageKit transactions:

| Method | Use |
|---|---|
| `RefreshCache` | Refresh package metadata |
| `GetUpdates` | List available updates |
| `SearchNames` | Search for packages by name |
| `InstallPackages` | Install a list of package IDs |
| `RemovePackages` | Remove a list of package IDs |
| `UpdatePackages` | Update a list of package IDs |

## Known limitations

- **NOT compiled in sandbox** — no Qt6 / cmake available. Build on a real
  Arch Linux host.
- AppStream-Qt integration deferred to v1.1. v1 uses a static catalog
  (sample data) and PackageKit search results.
- Screenshots load from network; an offline mode is not implemented yet.
- Concurrent transactions are explicitly disallowed (PackageKit itself
  prevents them, and we surface the busy state in the UI).
- Dependency list view: not implemented in v1.

## License

GPL-3.0-or-later. See `LICENSE` at the repository root.
