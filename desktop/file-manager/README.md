# Orion File Manager

A Windows-Explorer-style file manager for the Orion OS desktop. Built with
Qt6/QML on Wayland (works on X11 too). The file manager runs as a normal
user application; it **never escalates privileges** — operations on files
owned by another user simply fail with a clear error message.

## Features

- **Tabbed browsing** — multiple tabs, each with its own path. `Ctrl+T` opens
  a new tab at `$HOME`, `Ctrl+W` closes the current tab. Middle-click on a
  tab also closes it.
- **Breadcrumb navigation** — clickable path segments below the toolbar.
  Click any ancestor folder to jump there.
- **Back / Forward / Up** — Windows-Explorer-style nav cluster with
  per-tab history. `Alt+Left`/`Alt+Right`/`Alt+Up` shortcuts.
- **Three view modes** — List (default, with name + size + mtime),
  Icon (large icons in a grid), and Compact (single-line rows).
- **Search field** — case-insensitive substring filter on the current
  folder's contents. Does not recurse; use `find` for that.
- **Hidden files** — toggle with `Ctrl+H` or the eye icon in the toolbar.
- **Places sidebar** — Home, Desktop, Documents, Downloads, Pictures,
  Music, Videos, plus Recent / Favorites / Trash special entries, plus
  every mounted volume reported by udisks2.
- **Mounts sidebar** — automatically populated from udisks2; falls back
  to `/proc/mounts` for network shares and FUSE filesystems.
- **Copy / Move / Rename / Delete / Trash** — full set of file
  operations with progress reporting and a confirmation flow.
- **Destructive-operation confirmation** — `trash()` and `remove()` emit
  a `confirmDelete` signal that the QML layer catches to show an
  `OrionDialog` with explicit "Move to trash?" or "Permanently delete?"
  wording before any filesystem mutation happens.
- **Conflict resolution** — copy/move over an existing file emits
  `confirmOverwrite` with Skip / Replace / Rename choices. The file
  manager **never silently overwrites** existing files.
- **Permission-aware** — every mutation checks `QFileInfo::isWritable()`
  first; permission-denied errors are surfaced as readable dialogs.
  There is no `pkexec`, no `sudo`, no polkit prompt — operations on
  another user's files simply fail.
- **Free-disk-space readout** — the status bar shows the free space on
  the current folder's filesystem via `QStorageInfo`.
- **Theme-aware** — every color comes from `Theme` tokens
  (`org.orion.framework`). No hardcoded colors anywhere.
- **Reduced-motion support** — animations honor `Theme.reduceMotion`.

## Build

> This component has **NOT been compiled** in the development sandbox.
> The sandbox is Debian without Qt6, without cmake, and without the
> `orion-framework` package installed. Compilation requires a real
> Arch Linux host with Qt 6.6+ and the `orion-framework` package.

```bash
# 1. Install build deps (Arch Linux)
pacman -S qt6-base qt6-declarative qt6-wayland qt6-tools \
          cmake ninja extra-cmake-modules udisks2
# orion-framework must be installed from the Orion OS repo first.

# 2. Configure & build
cd desktop/file-manager
cmake -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j"$(nproc)"

# 3. Install
sudo cmake --install build
# Binary lands at /usr/lib/orion/orion-file-manager

# 4. Run
orion-file-manager            # opens at $HOME
orion-file-manager /etc       # opens at /etc
```

## Architecture

```
desktop/file-manager/
├── CMakeLists.txt
├── README.md
├── src/
│   ├── main.cpp              # entry point; registers QML context properties
│   ├── filesystemmodel.{h,cpp}   # QAbstractListModel for one directory
│   ├── mountsmodel.{h,cpp}       # QAbstractListModel of mounted volumes
│   ├── placesmodel.{h,cpp}       # QAbstractListModel of standard places
│   └── log.{h,cpp}              # orion.filemanager logging category
└── qml/
    ├── Main.qml               # ApplicationWindow; wires everything together
    ├── Toolbar.qml            # back/forward/up + breadcrumb + view + search
    ├── Breadcrumb.qml         # clickable path segments
    ├── TabBar.qml             # multi-tab interface
    ├── PlacesSidebar.qml      # left panel: places + mounts
    ├── FileItemDelegate.qml   # row/cell delegate for List/Grid/Compact
    └── StatusBar.qml          # item count + selected size + free space
```

### Context properties exposed to QML

| Name         | C++ class                   | Role                           |
|---|---|---|
| `fileSystem` | `Orion::FileSystemModel`    | The current directory listing  |
| `mounts`     | `Orion::MountsModel`        | Mounted volumes (udisks2)      |
| `places`     | `Orion::PlacesModel`        | Standard places + mount entries |

### FileSystemModel roles

| Role              | Type     | Notes                                    |
|---|---|---|
| `name`            | string   | file/folder display name                |
| `path`            | string   | absolute path                            |
| `icon`            | string   | freedesktop icon name                    |
| `size`            | int      | bytes; 0 for directories                 |
| `sizeFormatted`   | string   | "1.2 MB"                                  |
| `mtime`           | datetime | last-modified                            |
| `mtimeFormatted`  | string   | localized short format                   |
| `isDir`           | bool     |                                          |
| `isSymlink`       | bool     |                                          |
| `isHidden`        | bool     |                                          |
| `mimeType`        | string   | "inode/directory" for dirs              |
| `permissions`     | string   | "rwxr-xr-x" style                        |
| `selected`        | bool     | selection state (driven by selectedPaths)|

### FileSystemModel methods (Q_INVOKABLE)

| Method                                       | Purpose                            |
|---|---|---|
| `cd(path)`                                   | Change directory                   |
| `cdUp()`                                     | Go to parent                       |
| `breadcrumbs()` → `[{name, path}, …]`        | Path segments for Breadcrumb.qml   |
| `freeBytes() / freeBytesFormatted()`         | Free space on the current fs        |
| `totalSize(paths)`                           | Sum of file sizes (recursive for dirs) |
| `mkdir(name)`                                | Create a folder                    |
| `rename(old, new)`                           | Rename (confirms overwrite)        |
| `remove(paths)`                              | Permanent delete (confirms)        |
| `trash(paths)`                                | Trash (confirms; uses `gio trash`) |
| `copy(srcs, dst)`                             | Copy files (confirms per-file overwrite) |
| `move(srcs, dst)`                             | Move files (confirms per-file overwrite) |
| `open(path)`                                  | `xdg-open` for files; `cd` for dirs |
| `resolve(path)`                               | Resolve relative to current dir     |
| `isSelected(path) / toggleSelected(path)`    | Selection state                     |
| `clearSelection()`                            |                                    |
| `formatSize(bytes) / formatDate(dt)`          | Formatting helpers                  |
| `resolveOverwrite(action, renamedName?)`      | QML → C++ resume of confirmOverwrite |
| `resolveDeleteConfirmation(confirmed)`        | QML → C++ resume of confirmDelete   |

### FileSystemModel signals

| Signal                                | When emitted                                          |
|---|---|
| `pathChanged()`                       | After `cd()` / `cdUp()`                               |
| `countChanged()`                      | Row count changed                                     |
| `selectionChanged()`                  | selectedPaths changed                                 |
| `showHiddenChanged()`                 |                                                       |
| `filterChanged()`                     |                                                       |
| `busyChanged()`                       | Long operation started/finished                       |
| `errorOccurred(message)`              | Any user-visible error                                |
| `progressStarted(op, total)`          | Copy/move/delete started                              |
| `progressChanged(done, total, file)`  | Per-file progress                                     |
| `progressFinished(op, ok, failed)`     | Done                                                  |
| `confirmDelete(paths, permanent)`      | Trash or delete requested → QML must confirm           |
| `confirmOverwrite(srcPath, dstPath)`   | Copy/move would overwrite → QML must resolve           |

## D-Bus usage

The file manager does not register a D-Bus service of its own; it
**consumes** the following system services:

### udisks2 (`org.freedesktop.UDisks2`)

- Path: `/org/freedesktop/UDisks2/Manager`
- Interface: `org.freedesktop.UDisks2.Manager`
- Method: `GetBlockDevices(a{sv}) → ao`
- For each returned object path:
  - Read `org.freedesktop.UDisks2.Block` for `Device`, `IdLabel`, `IdUUID`,
    `IdType`, `HintSystem`, `HintRemovable`.
  - Read `org.freedesktop.UDisks2.Filesystem` for `MountPoints`.
- A `QDBusServiceWatcher` watches for the (re)appearance of the
  `org.freedesktop.UDisks2` owner and re-scans when it changes.
- We do not call `Mount`/`Unmount` in v1 — drives that are already
  mounted appear; unmounted drives don't. Mounting from the UI is
  deferred to v1.1 (it requires polkit authorization).

### `/proc/mounts` (fallback)

When udisks2 is unavailable or doesn't surface a mount (common for
network shares and FUSE filesystems), `MountsModel::scanProcMounts()`
parses `/proc/mounts` and adds entries that the udisks2 scan missed.
Pseudo-filesystems (proc, sysfs, devtmpfs, tmpfs, cgroup, ...) are
filtered out.

### Trash

The Trash feature uses `gio trash` (from GLib) for the XDG Trash spec.
When `gio` is not available, the in-process fallback in
`FileSystemModel::runDelete()` permanently deletes the files (after
confirmation). This is intentional — we don't write to the trash
protocol directly in v1.

### File opening

`FileSystemModel::open(path)` calls `xdg-open` for files (which then
dispatches to the registered handler per the XDG MIME system). Folders
are opened internally via `cd()`.

## Hard rules honored

1. **No hardcoded colors.** Every color binding reads from `Theme.*`.
2. **Never runs as root.** The CMake target is a plain executable; no
   setuid, no polkit action is registered. Operations on files owned
   by another user fail with `tr("Permission denied: …")`.
3. **Confirm before delete.** Both `remove()` and `trash()` emit
   `confirmDelete`, which QML shows as an `OrionDialog` with explicit
   "Move to trash?" / "Permanently delete?" wording. The actual
   filesystem mutation only runs after `resolveDeleteConfirmation(true)`.
4. **Never silently overwrite.** Copy/move/rename over an existing
   file emit `confirmOverwrite`, and QML shows Skip / Replace / Rename
   buttons. The operation resumes only after `resolveOverwrite(action)`.
5. **Native dialogs when available.** `QFileDialog`-style integration
   is deferred to v1.1; v1 uses themed `OrionDialog` instances which
   match the rest of the Orion OS look.
6. **Reduced motion.** All `Behavior`/`ColorAnimation`/`NumberAnimation`
   instances read durations from `Theme.motionFast` / `Theme.motionDefault`
   / `Theme.motionSlow`, which collapse to zero when `Theme.reduceMotion`
   is enabled.

## Keyboard shortcuts

| Shortcut         | Action                                |
|---|---|
| `Alt+Left`       | Back                                  |
| `Alt+Right`      | Forward                               |
| `Alt+Up`         | Up to parent folder                   |
| `Ctrl+T`         | New tab at `$HOME`                    |
| `Ctrl+W`         | Close current tab                      |
| `Ctrl+H`         | Toggle hidden files                    |
| `Ctrl+L`         | Focus search field                     |
| `F2`             | Rename selected item                  |
| `Delete`         | Move selection to trash               |
| `Shift+Delete`   | Permanently delete selection           |
| `F5`             | Refresh current folder                |

## Known limitations

- The component has **NOT been compiled** in the development sandbox.
  Building requires a real Arch Linux host with Qt6, cmake, and the
  `orion-framework` package installed.
- Tabs share a single `FileSystemModel`. Switching tabs does a `cd()`
  rather than swapping models. This is fine for typical use but
  loses the per-tab scroll position and selection. A v1.1 revision
  will use one `FileSystemModel` per tab.
- Copy/move run synchronously on the GUI thread. Large copies emit
  `progressChanged` after each file via `QCoreApplication::processEvents()`,
  which keeps the UI responsive but does not parallelize. Long copies
  will appear "stuck" briefly between progress updates; a v1.1
  revision will move the work to `QtConcurrent`.
- The copy/move confirmation flow stops iterating on the first conflict
  and re-runs the whole list when the user resolves it. This means the
  user can be asked twice about a file that hasn't been re-encountered
  yet — but since we re-check `targetInfo.exists()` on each iteration,
  no actual double-asking happens. (The current logic is correct but
  could be tightened with an `apply_to_all` flag in v1.1.)
- Mounting/unmounting drives from the sidebar is not implemented in v1.
  udisks2 `Mount()` requires polkit authorization; we explicitly avoid
  privilege escalation in this component.
- The Recent place opens `$HOME` as a placeholder. The proper
  `recently-used.xbel` browser is deferred to v1.1.
- The Trash place opens `~/.local/share/Trash/files` directly rather
  than via the `trash://` URI scheme. Files deleted via `gio trash`
  appear here.
- Properties dialogs (file permissions / MIME / owner) are not yet
  implemented. The model exposes the data via roles; a v1.1 properties
  panel will display them.
- Single-instance enforcement is not implemented. Launching the
  manager twice will open two windows.
- The file manager does not yet honor drag-and-drop copy/move. That is
  targeted for v1.1.

## License

GPL-3.0-or-later. See `LICENSE` at the repository root.
