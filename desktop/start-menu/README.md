# Orion Start Menu

The Orion Start Menu is the application launcher for the Orion desktop.
Opened by clicking the Start button on the Panel (via `org.orion.StartMenu.Toggle`
D-Bus signal) or by pressing the Super key.

## Layout

Windows 11-inspired: search at top, pinned app grid in the middle,
"Recommended" section (recent files + most-launched apps), an "All apps"
toggle that switches to an alphabetical list, and a footer with the user
profile and a power button.

## Build

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j$(nproc)
sudo cmake --install build
```

## D-Bus interface

Service: `org.orion.StartMenu`
Path: `/orion/StartMenu`

| Method | Signature | Description |
|---|---|---|
| `Toggle` | → | Show/hide the start menu |
| `Open` | → | Show the start menu |
| `Close` | → | Hide the start menu |
| `Search` | s → | Set the search query |

## App discovery

Scans XDG `applications/` directories (`/usr/share/applications`,
`/usr/local/share/applications`, `~/.local/share/applications`). Respects
`Type=Application`, `NoDisplay=true`. Parses `Name`, `GenericName`, `Icon`,
`Exec`, `Categories`, `Keywords`.

## Recent files

Reads `~/.local/share/recently-used.xbel` (the XDG recent-files format).
Shows up to 12 entries.

## Recommended apps

Reads `~/.local/state/orion/launch-counts.json` and shows the top 6
most-launched apps. Falls back to the 6 default pinned apps if no launch
counts exist.

## Known limitations

- The component has NOT been compiled in the sandbox (no Qt6 / cmake).
- The recommended-apps algorithm is intentionally simple (pure launch count);
  a future revision will add recency weighting.
- The user avatar is a placeholder circle with the first letter of the
  username. accountsservice integration for real avatars is documented but
  not implemented in v1.
- The "All apps" view does not yet show the alphabetical group headers
  (sticky letter dividers). To be added in v1.1.

## License

GPL-3.0-or-later. See `LICENSE` at the repository root.
