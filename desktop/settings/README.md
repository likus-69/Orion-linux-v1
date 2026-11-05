# Orion Settings

A Windows-Settings-style unified control panel for the Orion OS desktop.
Built with Qt6/QML on top of the `org.orion.framework` module. Covers seven
top-level categories: **Personalization**, **System**, **Devices**,
**Network**, **Accounts**, **Privacy & Security**, and **Applications**.

The Settings app runs as a normal user. It **never escalates privileges
itself** — every privileged operation goes through a system D-Bus service
(`hostname1`, `timedate1`, `locale1`, `accounts`, `udisks2`,
`NetworkManager`, `org.freedesktop.systemd1`, `org.bluez`, …) which
triggers a polkit prompt when required. If launched as root, the app
refuses to start.

> This component has **NOT been compiled** in the development sandbox.
> The sandbox is Debian without Qt6, without cmake, and without the
> `orion-framework` package installed. Compilation requires a real
> Arch Linux host with Qt 6.6+ and the `orion-framework` package.

## Features

### 1. Personalization

- **Themes** — 5 themes selectable from cards that show a mini-preview
  in the theme's actual surface/accent colors:
  `orion-dark`, `orion-light`, `orion-midnight`, `orion-aurora`,
  `orion-high-contrast`.
- **Accent color** — 7 swatches (blue, cyan, violet, magenta, amber,
  emerald, crimson). Mirrored from `data/tokens.json`.
- **Wallpaper** — grid of thumbnails from
  `~/.local/share/orion/wallpapers` and `/usr/share/orion/wallpapers`,
  plus a "Browse…" button that opens a file dialog. The choice is pushed
  to `org.freedesktop.portal.Wallpaper` and `org.orion.Shell`.
- **Fonts** — selector populated from `fc-list : family`.
- **Lock screen** — idle-timeout picker (0/30s/1m/2m/5m/10m/15m/30m).
- **Desktop layout** — panel position (top/bottom/left/right) +
  taskbar auto-hide toggle. Pushed to `org.orion.Panel`.
- **Animations & transparency** — three toggles:
  `reduceMotion`, `reduceTransparency`, `animationsEnabled`. These
  write to the Orion Settings JSON and the framework's `Theme` singleton
  picks them up automatically (it reads the same JSON entry).

### 2. System

- **System info card** — populated from `/etc/os-release` plus
  `org.freedesktop.hostname1` (Hostname, Chassis, HardwareVendor,
  HardwareModel), `/proc/cpuinfo` (model + core count),
  `/proc/meminfo` (total + available bytes).
- **Display** — scaling picker (50 %–200 %) and a resolution dropdown
  populated from `wlr-randr` (Wayland). Resolution application also
  uses `wlr-randr`.
- **Sound** — master volume slider (placeholder UI; per-app mixing
  lives in the system tray).
- **Notifications** — level picker (Do not disturb / Normal /
  Critical only), pushed to `org.orion.Notifications`.
- **Power** — profile picker (power-saver / balanced / performance),
  pushed to `net.hadess.PowerProfiles` (power-profiles-daemon).
- **Storage** — disk-usage bars per mounted volume, sourced from
  `QStorageInfo::mountedVolumes()`. Bar color turns amber/red above
  75 %/90 % fill.
- **Default apps** — link to Applications page.
- **Language and region** — locale text field; `SetLocale` on
  `org.freedesktop.locale1` (polkit). Requires typed confirmation.
- **Date and time** — timezone combo (from
  `controller.availableTimezones()`) plus NTP toggle
  (`org.freedesktop.timedate1.SetNTP`). Hostname change with typed
  confirmation (`SetStaticHostname` + `SetPrettyHostname`).

### 3. Devices

- **Keyboard** — layout combo populated from `localectl list-keymaps`;
  applies via `org.freedesktop.locale1.SetVConsoleKeyboard` +
  `SetX11Keyboard`.
- **Mouse / touchpad** — sensitivity slider (4 levels), tap-to-click,
  natural scrolling. Cached in Orion Settings JSON; applied by the
  `org.orion.Shell` input device manager.
- **Bluetooth** — list of paired devices (org.bluez ObjectManager);
  "forget" via `org.bluez.Adapter1.RemoveDevice`. Pairing is done from
  the Quick Settings panel (v1.1 will add scanning + PIN entry here).
- **Printers** — `lpstat -e` output as a list; one-click "Enable CUPS"
  button that calls `org.freedesktop.systemd1.Manager.StartUnit` on
  `cups.service` (polkit prompt). Add-printer mini-form runs `lpadmin`.
- **Cameras** — V4L2 devices under `/dev/video*`.

### 4. Network

- **Connection status** — overall NetworkManager state (asleep /
  disconnected / connecting / connected-local/site/global) and the
  WirelessEnabled / NetworkingEnabled toggles.
- **Wi-Fi list** — `org.freedesktop.NetworkManager.Device.Wireless.
  GetAllAccessPoints()`; click any AP to open a password dialog and
  call `AddAndActivateConnection`.
- **Ethernet** — wired connections from `Settings.ListConnections()`.
- **VPN** — list of `vpn`/`wireguard` connections; "Import" runs
  `nmcli connection import type openvpn file <path>`.
- **Proxy** — mode picker (none/manual/auto) + host/port fields; writes
  to Orion Settings JSON and (if available) `gsettings
  org.gnome.system.proxy`.

### 5. Accounts

- **Current user card** — username, real name, UID, home, shell,
  account type, avatar (from `org.freedesktop.Accounts.FindUserById` →
  `IconFile`).
- **Avatar upload** — `FileDialog` → `SetIconFile` (polkit:
  `org.freedesktop.accounts.change-own-user-data`).
- **Password change** — `passwd` via stdin; PAM validates the old
  password.
- **Login preferences** — auto-login toggle and account-type combo
  (admin only); both go through `org.freedesktop.Accounts.User`.
- **User management (admins only)** — list of `ListCachedUsers()`
  accounts with create/delete dialogs. Delete requires typing the
  username to confirm.

### 6. Privacy & Security

- **Firewall status** — `ufw status` (preferred) or `nft list ruleset`
  (fallback). Enable/Disable toggles call
  `org.freedesktop.systemd1.Manager.StartUnit`/`StopUnit` on
  `ufw.service` (polkit prompt).
- **Screen-lock timeout** — writes to Orion Settings JSON and pushes
  to `org.orion.Lockscreen.SetIdleTimeout`.
- **Disk-encryption status** — calls `lsblk --json` and walks the
  tree to detect whether the root filesystem is on a LUKS volume.
- **App permissions** — per-app permission JSON
  (`~/.config/orion/permissions/<id>.json`). v1 read-only; v1.1
  will bridge to xdg-desktop-portal.
- **Telemetry** — **OFF by default**. Opt-in only. The card explains
  exactly what is sent (OS version, kernel, CPU arch, country derived
  from timezone, counts of installed apps) and what is not (no
  personal data, no file paths, no network identifiers).
- **Diagnostics** — local crash logs under
  `~/.local/share/orion/diagnostics`. Off by default.

### 7. Applications

- **Installed applications** — discovered from `~/.local/share/applications`,
  `/usr/share/applications`, `/usr/local/share/applications`. Search field
  filters by name. Uninstall opens Orion Software Center which runs
  `pacman -R` via polkit.
- **Default applications** — per-mime-type picker driven by `xdg-mime
  query default` / `xdg-mime default`.
- **Startup applications** — XDG autostart entries from
  `~/.config/autostart` and `/etc/xdg/autostart`. Toggle moves the
  `.desktop` file between `<id>.desktop` and `<id>.desktop.disabled`.
- **Repository info** — `pacman -Sl` summary (repo list + total
  package count).

## Build

> See the warning above — this code has **not** been compiled in the
> development sandbox. The instructions below are what a real-Arch
> host would run.

```bash
# 1. Install build deps (Arch Linux)
pacman -S qt6-base qt6-declarative qt6-wayland qt6-tools \
          cmake ninja extra-cmake-modules \
          accountsservice networkmanager udisks2 ufw xdg-utils \
          cups bluez bluez-utils util-linux
# orion-framework must be installed from the Orion OS repo first.

# 2. Configure & build
cd desktop/settings
cmake -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j"$(nproc)"

# 3. Install
sudo cmake --install build
# Binary lands at /usr/lib/orion/orion-settings

# 4. Run
orion-settings
```

## Architecture

```
desktop/settings/
├── CMakeLists.txt
├── README.md
├── src/
│   ├── main.cpp                  # entry point; registers `controller`
│   │                             # context property. Refuses root.
│   ├── settingscontroller.h/.cpp # central controller; 7 categories
│   └── log.h/.cpp                # orion.settings logging category
└── qml/
    ├── Main.qml                  # ApplicationWindow; two-pane layout
    ├── Sidebar.qml               # 7 OrionListRow entries
    ├── components/
    │   ├── ThemeCard.qml         # theme preview card (mini-screenshot)
    │   └── AccentSwatch.qml      # accent color swatch button
    └── pages/
        ├── PersonalizationPage.qml
        ├── SystemPage.qml
        ├── DevicesPage.qml
        ├── NetworkPage.qml
        ├── AccountsPage.qml
        ├── PrivacyPage.qml
        └── ApplicationsPage.qml
```

### Context property exposed to QML

| Name         | C++ class                    | Role                              |
|---|---|---|
| `controller` | `Orion::SettingsController` | All settings reads/writes + D-Bus |

### SettingsController (Q_INVOKABLE)

| Category         | Methods (representative)                                                     |
|---|---|
| Personalization  | `setWallpaper`, `setTheme`, `setAccent`, `setReduceMotion`, `setReduceTransparency`, `setFontFamily`, `setLockScreenTimeout`, `setPanelPosition`, `setTaskbarAutoHide`, `setAnimationsEnabled` |
| System           | `setTimezone`, `setNtpEnabled`, `setHostname`, `setLocale`, `setDisplayScale`, `setDisplayResolution`, `setNotificationLevel`, `setPowerProfile`, `setLanguage`, `availableTimezones` |
| Devices          | `setKeyboardLayout`, `setMouseSensitivity`, `setTapToClick`, `setNaturalScroll`, `pairBluetooth`, `forgetBluetooth`, `enableCups`, `addPrinter` |
| Network          | `getNetworkConnections`, `wifiAccessPoints`, `connectToWifi`, `disconnectFromWifi`, `addVpn`, `removeVpn`, `setProxy` |
| Accounts         | `createUser`, `deleteUser`, `setAvatar`, `changePassword`, `setAutoLogin`, `setUserType` |
| Privacy          | `enableFirewall`, `disableFirewall`, `setScreenLockTimeout`, `setTelemetry`, `setDiagnostics` |
| Applications     | `installedApps`, `defaultApps`, `setDefaultApplication`, `startupApps`, `toggleStartupApp`, `uninstallApplication` |
| Confirmation     | `applyConfirmedSetHostname`, `applyConfirmedSetLocale`, `applyConfirmedDeleteUser` |
| Helpers          | `isCurrentUserAdmin`, `isRunningAsRoot`, `formatBytes`, `settingsFilePath`, `refresh` |

### SettingsController signals

| Signal                              | When emitted                                       |
|---|---|
| `personalizationChanged()`          | Any personalization key changed                    |
| `systemInfoChanged()`               | Hostname / timezone / locale / power / etc.        |
| `currentUserChanged()`              | Current user info refreshed                         |
| `usersChanged()`                   | Users list changed                                  |
| `networkStateChanged()`             | Network state changed                                |
| `firewallStatusChanged()`            | Firewall enabled/disabled                            |
| `storageInfoChanged()`               | Storage list refreshed                               |
| `diskEncryptionStatusChanged()`      | (After refresh)                                      |
| `installedAppsChanged()`            | (After refresh)                                      |
| `startupAppsChanged()`               | A startup app was enabled/disabled                  |
| `defaultAppsChanged()`               | A default app was set                                |
| `repoInfoChanged()`                  | (After refresh)                                      |
| `operationStarted(description)`     | Async op started                                     |
| `operationFinished(desc, ok, msg)`    | Async op finished                                    |
| `errorOccurred(message)`             | Any user-visible error                               |
| `confirmationRequired(op, target, displayName)` | Destructive op needs typed confirmation |

## D-Bus usage

The Settings app is a **consumer** of many system services. It does
**not** register a service of its own.

| Service                              | Used for                                            |
|---|---|
| `org.freedesktop.hostname1`          | Read/set hostname + pretty hostname                 |
| `org.freedesktop.timedate1`          | Read/set timezone + NTP                             |
| `org.freedesktop.locale1`            | Read/set system locale + keyboard layout            |
| `org.freedesktop.systemd1`           | Start/stop/enable `cups.service`, `ufw.service`     |
| `org.freedesktop.NetworkManager`     | List devices, access points, connections; connect  |
| `org.freedesktop.Accounts`           | List/create/delete users; set avatar / account type |
| `org.freedesktop.UDisks2`            | (Reserved for v1.1 mount UI)                        |
| `org.bluez`                          | List/forget paired Bluetooth devices                |
| `org.freedesktop.portal.Desktop`     | `SetWallpaperURI` for the wallpaper picker           |
| `org.orion.Shell` / `.Panel` / `.Lockscreen` / `.Notifications` | Push Orion-specific settings to running services |

## Hard rules honored

1. **No hardcoded colors.** Every color binding reads from `Theme.*`.
   The ThemeCard preview colors for the 5 themes are hardcoded as a
   local lookup table because they must reflect the *previewed* theme,
   not the currently-applied one.
2. **Never runs as root.** `main.cpp` checks `::geteuid() == 0` and
   refuses to start, printing a clear message. The controller additionally
   re-checks on every privileged operation.
3. **Destructive operations require typed confirmation.** `setHostname`,
   `setLocale`, and `deleteUser` emit `confirmationRequired`, and QML
   shows an `OrionDialog` with a TextField where the user must type the
   target value. The actual mutation only runs from the matching
   `applyConfirmed*` slot after the typed value matches.
4. **All privileged operations go through polkit.** No `pkexec`, no
   `sudo`, no setuid binary. systemd `StartUnit`/`StopUnit` with
   `interactive=true` triggers the polkit prompt automatically.
5. **Reduced motion / transparency.** All `Behavior` / `ColorAnimation` /
   `NumberAnimation` instances read durations from `Theme.motionFast` /
   `Theme.motionDefault` / `Theme.motionSlow`. The page transition
   `NumberAnimation` is skipped entirely when `Theme.reduceMotion` is
   `true`. The busy overlay uses solid `Theme.surface0` when
   `Theme.reduceTransparency` is `true`.
6. **Lazy page loading.** The right pane is a `Loader` whose `source`
   is set from `currentCategory`. Only the visible page is instantiated.

## Known limitations

- The component has **NOT been compiled** in the development sandbox.
  Building requires a real Arch Linux host with Qt6, cmake, and the
  `orion-framework` package.
- Bluetooth device list unpacking is partially implemented in v1 — the
  C++ side calls `org.bluez`'s `GetManagedObjects` but does not
  deserialize the `a{oa{sa{sv}}}` reply into the `QVariantList`. The
  UI shows an empty state with a hint to pair from Quick Settings. v1.1
  will add the deserializer and a pairing wizard.
- Per-app volume mixing is not implemented in the Sound section; it's
  deferred to the audio daemon in the system tray.
- Mounting/unmounting drives is not implemented; `udisks2` Mount() calls
  require polkit. The Storage section lists already-mounted volumes only.
- The display resolution list is sourced from `wlr-randr` (Wayland). On
  X11 hosts without wlr-randr installed, only a static fallback list is
  shown and applying a mode fails.
- App-permission toggles in the Privacy section write to a local JSON
  file; they do not yet bridge to xdg-desktop-portal's per-app
  permissions (v1.1).
- Telemetry transmission itself is not implemented — the toggle just
  stores the opt-in state. The collector daemon (separate component)
  reads the state and posts reports.
- Single-instance enforcement is not implemented. Launching the app twice
  opens two windows.

## License

GPL-3.0-or-later. See `LICENSE` at the repository root.
