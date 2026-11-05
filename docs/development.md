# Orion OS — Development Guide

This document explains how to develop, build, test, and debug Orion OS
components locally. It assumes you are on an Arch Linux host (see
[`installation.md`](installation.md) for setup).

## 1. Repository orientation

Read these documents first:

- [`docs/architecture.md`](architecture.md) — why each technology was chosen.
- [`docs/design-system.md`](design-system.md) — colors, typography, spacing
  tokens that every Orion application must use.
- [`STATUS.md`](../STATUS.md) — current implementation state.

The repository is organized as:

```
desktop/orion-framework/   ← shared library; build first
desktop/<component>/        ← each app depends on orion-framework
packaging/orion-<component>/  ← PKGBUILD templates
scripts/                     ← build, test, dev helpers
tests/                       ← pytest + Qt tests
```

## 2. Building orion-framework

`orion-framework` is the shared Qt6 library every Orion desktop component
depends on. Build it first.

```bash
cd desktop/orion-framework
cmake -B build -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DBUILD_TESTING=ON
cmake --build build -j"$(nproc)"
sudo cmake --install build
```

This installs `liborion-framework.so`, QML modules under
`/usr/lib/qt6/qml/org/orion/framework/`, and CMake package config files under
`/usr/lib/cmake/OrionFramework/`.

To verify:

```bash
orion-framework-selftest
```

(A small test binary that prints the loaded version and theme tokens.)

## 3. Building a single desktop component

```bash
cd desktop/panel
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j"$(nproc)"
sudo cmake --install build
```

Run the component standalone for development:

```bash
./scripts/dev-run-shell.sh --component=panel
```

`dev-run-shell.sh` sets `QT_LOGGING_RULES` for verbose logging, loads the local
`orion-framework` build (`LD_LIBRARY_PATH` + `QML_IMPORT_PATH`), and launches
the component under the active KWin Wayland session.

## 4. Building all desktop components

```bash
./scripts/build-desktop.sh
```

Iterates over every `desktop/<component>/CMakeLists.txt`, builds in
`desktop/<component>/build/`, installs to a staging directory at
`build/stage/`. Useful for testing the full set before a release.

## 5. Building the ISO

```bash
./scripts/build-iso.sh
```

See [`installation.md`](installation.md).

## 6. Running the tests

### Unit tests

```bash
pytest tests/unit/ -v
```

The Python unit tests cover `orion-framework` token resolution, the panel's
pin/running-apps logic, the start-menu's `.desktop` enumeration, and the
settings app's schema validation.

### Integration tests

```bash
./scripts/run-integration-tests.sh
```

Spawns a transient KWin Wayland session, registers the Orion components against
its session bus, and runs the integration test suite. Requires
`dbus-run-session` and a working Qt6 Wayland plugin.

### Security scan

```bash
./scripts/security-scan.sh
```

Static checks for secrets, hardcoded passwords, world-writable config files,
unsanitized input passed to shell, and other pitfalls documented in
[`docs/security.md`](security.md).

### Virtual-machine test

```bash
./scripts/test-iso-qemu.sh distro/archiso/out/orion-os-<version>-x86_64.iso
```

Boots the ISO under QEMU, runs the Orion smoke test inside the live session,
and reports results. See [`tests/virtual-machine/`](../tests/virtual-machine/)
for the test definition.

## 7. Hot-reload during QML development

For rapid QML iteration without rebuilding C++:

```bash
# In one terminal, start the panel against the live orion-framework
./scripts/dev-run-shell.sh --component=panel --hot-reload

# In another terminal, edit QML files under desktop/panel/qml/
# Save the file; the panel reloads it automatically via QQmlApplicationEngine
# 'clearComponentCache' triggered by a file-watcher.
```

## 8. Debugging

### Enabling debug logging

```bash
export QT_LOGGING_RULES="orion.*=true;kwin_*=false"
export G_MESSAGES_DEBUG=all
```

### Inspecting D-Bus

```bash
busctl --user tree org.orion.Panel
gdbus introspect --session --dest org.orion.StartMenu --object-path /orion/StartMenu
```

### Inspecting the running KWin session

```bash
qdbus org.kde.KWin /KWin supportInformation
qdbus org.kde.KWin /KWin queryWindowInfo
```

### Crashes

```bash
coredumpctl list
coredumpctl info <pid>
```

If a component is a systemd user unit, `journalctl --user -u orion-panel.service`
shows its log.

## 9. Adding a new Orion desktop component

See [`CONTRIBUTING.md`](../CONTRIBUTING.md) §"How to add a new desktop
component". In short:

1. `desktop/<component>/` with `CMakeLists.txt`, `src/main.cpp`, `qml/Main.qml`,
   `<component>.desktop`, `README.md`.
2. Depend on `OrionFramework` via `find_package(OrionFramework)`.
3. Use only design tokens from `org.orion.framework.Theme` — never hard-code
   colors.
4. Add `packaging/orion-<component>/PKGBUILD`.
5. Add the binary name to `distro/archiso/packages.x86_64`.
6. Add unit tests under `tests/unit/`.
7. Update `STATUS.md`.

## 10. Branching and release flow

- `main` — always buildable; what the ISO is cut from.
- `feature/<scope>-<short-desc>` — feature branches, merged via PR.
- `release/<version>` — release stabilization; only bug fixes allowed.

Releases are tagged `v<MAJOR>.<MINOR>.<PATCH>` (semver). See
[`release-process.md`](release-process.md) for the full release procedure.

## 11. Coding standards

- **C++:** C++17 minimum. C++20 preferred for new code. `clang-format` config
  at `.clang-format`. `clang-tidy` config at `.clang-tidy`.
- **QML:** Use `//` for line comments. Always declare properties with explicit
  types. Never reference magic numbers — pull them from the theme.
- **Python:** `black` + `ruff` for tests and scripts.
- **Shell:** `shellcheck` for every script under `scripts/`.

## 12. Getting help

- Open an issue on the project tracker (link in `README.md`).
- Ask in the project's chat channel (link in `README.md`).
- Read [`troubleshooting.md`](troubleshooting.md) first.
