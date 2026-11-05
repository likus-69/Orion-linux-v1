# orion-panel — Orion OS bottom taskbar

The Orion Panel is the Windows-11-inspired bottom taskbar of Orion OS. It
runs as a `systemd --user` service (`distro/services/orion-panel.service`)
and renders itself as a Wayland layer-shell surface docked at the bottom of
the primary output.

## Features

- Start button emitting a D-Bus signal to toggle the Orion Start Menu.
- Pinned apps read from `~/.config/orion/panel.json` → `pinned_apps`.
- Running apps queried from KWin via `org.kde.KWin` on the session bus.
- System tray cluster: network / audio / battery / clock + a Quick Settings
  launcher.
- Centered **or** left-aligned task list (read from `panel.layout`).
- 48 px tall by default, configurable from 36 to 56 px via `panel.height`.
- All colours / radii / spacing / motion come from `org.orion.framework.Theme`.
  No hardcoded values.
- Honours `Theme.reduceTransparency`: opaque background when true.
- Honours `Theme.reduceMotion`: animations short-circuited when true (the
  clock keeps ticking — its timer is independent).

## Build

> **The sandbox has no Qt6, no `cmake`, no Arch toolchain.** This component
> has **not** been compiled in this repo. Compilation requires a real Arch
> Linux host with Qt 6.6+, `layer-shell-qt`, and `orion-framework` installed.

```bash
cd /home/z/my-project/orion-os/desktop/panel
cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j"$(nproc)"
sudo cmake --install build
```

The CMake project:

- `find_package(OrionFramework 0.1 REQUIRED)` — pulls in `Orion::Theme`,
  `Orion::Settings`, `Orion::Log`, and the `org.orion.framework` QML module.
- `find_package(LayerShellQt QUIET)` — optional. When found, the binary
  is built with `-DORION_HAVE_LAYER_SHELL=1` and the panel anchors itself
  to the bottom Wayland output. When absent the panel still builds as a
  plain frameless window positioned at the bottom of the screen.
- Installs the binary to `${CMAKE_INSTALL_LIBDIR}/orion/orion-panel`
  (i.e. `/usr/lib/orion/orion-panel` on Arch) — matches the path hard-coded
  in `distro/services/orion-panel.service`.
- Installs QML files to `/usr/share/orion/panel/qml/` for live editing.
- Installs the `.desktop` entry to `/usr/share/applications/`.

## Architecture

```
                +-------------+   D-Bus (session)
   panelKWin <--| KWinClient  |<------ org.kde.KWin  (/KWin)
   (context   +-+-------------+   signals windowAdded/Removed/Changed
    property) |
            +-+-------------+   reads  ~/.config/orion/panel.json
   panelPinned|  PinnedApps  |   reads  /usr/share/applications/*.desktop
              +-------------+

   panelSettings (Orion::Settings, context property) -- reads
   ~/.config/orion/panel.json keys: panel.height, panel.layout,
   panel.pinned_apps.

   Main.qml  -----------------+
     StartButton.qml          |   all colors/sizes/motion bound to
     TaskbarItem.qml          |   org.orion.framework.Theme
     SystemTray.qml           |
     Clock.qml               +
```

### C++ helpers

| Class          | Header                | Q_PROPERTY / Q_INVOKABLE                                              |
|----------------|------------------------|------------------------------------------------------------------------|
| `KWinClient`   | `src/kwinclient.h`     | `windows: QVariantList`, `available: bool`, `activateWindow(uuid)`, `closeWindow(uuid)` |
| `PinnedApps`   | `src/pinnedapps.h`     | `pinnedApps: QVariantList`, `launch(desktopFileId)`, `reload()`         |
| `Orion::Settings` | (from `orion-framework`) | `get(key, def)`, `set(key, value)`, `reload()` |
| `PanelBus`     | (inline in `src/main.cpp`) | `Q_INVOKABLE toggleStartMenu()`, `Q_INVOKABLE openQuickSettings()` |

Both `KWinClient` and `PinnedApps` are exposed to QML as context properties
`panelKWin` and `panelPinned` (set in `src/main.cpp`). They are *also*
annotated `QML_ELEMENT`/`QML_SINGLETON` so a future `qt_add_qml_module()`
call can register them as `import org.orion.panel 1.0`. An `Orion::Settings`
instance (component `"panel"`) is exposed as the `panelSettings`
context property so QML can call `panelSettings.get("height", 48)` —
the framework's `Settings` class has a required-arg constructor and so
cannot be instantiated directly from QML. A small `PanelBus` QObject
exposed as `panelBus` provides `toggleStartMenu()` and
`openQuickSettings()` Q_INVOKABLE wrappers around session-bus signal
emission, so QML doesn't need to import `Qt.DBus`.

### QML files

| File             | Purpose                                                            |
|------------------|--------------------------------------------------------------------|
| `qml/Main.qml`        | Root `ApplicationWindow`. Sets geometry from settings, draws background, lays out three sections. |
| `qml/StartButton.qml` | Orion-logo button. Emits `startMenuTriggered()` on click. Pulsing accent ring on hover (gated by `Theme.reduceMotion`). |
| `qml/TaskbarItem.qml` | A single pinned-or-running entry. 24×24 icon, tooltip, running indicator dot, right-click context menu (Pin/Unpin/Close). |
| `qml/SystemTray.qml`  | Network + Audio + Battery + Clock cluster. All click handlers dispatch `org.orion.QuickSettings.Open`. |
| `qml/Clock.qml`       | `HH:MM` text. 1-second `Timer` (independent of `Theme.motion*`). Calendar popover on click. |

## D-Bus interface contract

### Emitted by the panel

| Bus      | Service              | Path                    | Interface             | Member     | Args  | Trigger                                  |
|----------|----------------------|-------------------------|-----------------------|------------|-------|------------------------------------------|
| session  | `org.orion.StartMenu`| `/org/orion/StartMenu`  | `org.orion.StartMenu` | `Toggle`  | (none)| Start button clicked.                   |

### Consumed by the panel

| Bus      | Service                | Path                | Interface           | Members                                                 |
|----------|------------------------|---------------------|---------------------|---------------------------------------------------------|
| session  | `org.kde.KWin`         | `/KWin`             | `org.kde.KWin`      | signals `windowAdded/Removed/Changed(QString uuid)`; methods `getWindowInfo(uuid) → QVariantMap`, `setActiveWindow(uuid)`, `closeWindow(uuid)` |
| system   | `org.freedesktop.NetworkManager` | `/org/freedesktop/NetworkManager` | `org.freedesktop.NetworkManager` | (planned — see Known Limitations) |
| system   | `org.freedesktop.UPower` | `/org/freedesktop/UPower` | `org.freedesktop.UPower` | (planned — see Known Limitations) |
| session  | `org.orion.QuickSettings` | `/org/orion/QuickSettings` | `org.orion.QuickSettings` | `Open()` method (planned) |

## Settings

Settings live in `~/.config/orion/panel.json` (see `orion-framework`
`Settings` class). Recognized keys:

| Key              | Type     | Default     | Description                                            |
|------------------|----------|-------------|--------------------------------------------------------|
| `layout`         | string   | `"centered"` | `"centered"` or `"left"` task-list alignment.        |
| `height`         | int      | `48`        | Panel height in px. Clamped to `[36, 56]`.             |
| `pinned_apps`    | string[] | (fallback)  | Array of `.desktop` file IDs.                          |

> **Schema note:** the system-wide skeleton
> `distro/defaults/etc-skell/orion-defaults.json` ships `pinned_apps` under
> the `panel` group (good) but `panel_layout` / `panel_height` under the
> `personalization` group. This component reads them from the `panel`
> group instead — when migrating to per-component settings files, set
> `panel.layout` and `panel.height` in `~/.config/orion/panel.json`. The
> panel safely falls back to `"centered"` and `48` if absent.

## Known Limitations

1. **Layer-shell-qt optional.** Without it the panel runs as a plain
   frameless window positioned at the bottom of the screen. Visually
   equivalent on a single-output system but does not claim an exclusive
   zone, so maximized windows will overlap it.

2. **KWin D-Bus is the canonical window-list source but the upstream
   `org.kde.KWin` interface does not expose a single "list all windows"
   method.** The panel populates its window list incrementally from the
   `windowAdded(QString uuid)` signal plus a 1-second `getWindowInfo(uuid)`
   re-fetch. Any window that was already open **before** the panel started
   will not appear in the list until it next sends a `windowChanged`
   signal (e.g. on focus change). A future `Orion::KWinForeignToplevel`
   helper using the `wlr-foreign-toplevel-management-v1` Wayland protocol
   will eliminate this caveat.

3. **No raw D-Bus binding in stock Qt6 QML.** The system-tray indicators
   (NetworkManager, UPower, PipeWire/PulseAudio) ship with sensible default
   state values (`networkState="unknown"`, `audioMuted=false`,
   `audioVolume=50`, `batteryPercent=0.65`, …). Wiring live state requires
   a small C++ `SystemTrayModel` class — out of scope for this task because
   the spec restricts C++ files to `kwinclient` and `pinnedapps`. The
   visual component is fully functional; only the data plumbing is
   pending. The Quick-Settings **click handler** does dispatch a real
   session-bus signal (`org.orion.QuickSettings.Open`) via the `PanelBus`
   helper inside `main.cpp`, so clicking the tray still opens the
   quick-settings popover when that service is running.

4. **The `gtk-launch` dependency.** Launching a pinned app shells out to
   `gtk-launch <id>` (universally available on an Arch system with GTK
   installed). If GTK is absent the launch fails silently; users without
   GTK should install `glib2` which provides `gio launch` as a fallback.

5. **Multi-monitor v1: primary-output only.** A single panel instance
   spans `Screen.width`. Multi-output support is documented in the spec as
   acceptable for v1 and will land with a per-output loader in v2.

6. **Clock font size.** `Clock.qml` uses a 14-px body font. If the panel
   is configured to its minimum 36-px height the text is still readable but
   tight — verified visually by static review only.

## License

GPL-3.0-or-later. See `LICENSE` at the repository root.
