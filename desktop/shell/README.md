# Orion Shell

The Orion Shell is the top-level Wayland session launcher. It is the binary
that SDDM execs when the user picks the "Orion" session at login
(see `/usr/share/wayland-sessions/orion.desktop`).

## Responsibilities

1. Set up the Wayland / XDG environment variables.
2. Launch KWin (the Wayland compositor) as a subprocess if it is not already
   running.
3. Take the `org.orion.Shell` D-Bus name on the session bus. Other Orion
   components use this as a readiness signal.
4. Start the Orion desktop components (panel, start-menu, notifications,
   quick-settings, update-manager, search) via `systemctl --user start
   orion-*.service`. Each component runs under systemd supervision.

## Lifecycle

- Started by SDDM at login.
- Exits when KWin exits (compositor crash, logout, or session termination).
- SDDM restarts the session on exit.

## Build

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j$(nproc)
sudo cmake --install build
```

The binary installs to `/usr/lib/orion/orion-shell`.

## D-Bus interface

Service: `org.orion.Shell`
Path: `/orion/Shell`

| Method | Signature | Description |
|---|---|---|
| `isRunning` | → b | True if the shell is running. Used by component startup checks. |

Other Orion components should wait for `org.orion.Shell` to appear on the
session bus before they consider the session "up".

## Known limitations

- If KWin crashes, the entire session exits. This is intentional — partial
  recovery from a compositor crash is unreliable.
- The shell does not currently support nested compositors (running Orion
  Shell inside another Wayland session). This requires `kwin_wayland
  --nested` which is finicky; not a v1 goal.
- The `XDG_CURRENT_DESKTOP` value is `orion` — third-party applications
  that branch on this value will see "orion". They typically fall back to
  the XDG `DesktopNames` field in the wayland-session .desktop file.

## License

GPL-3.0-or-later. See `LICENSE` at the repository root.
