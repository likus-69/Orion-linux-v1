#!/usr/bin/env bash
#
# scripts/dev-run-shell.sh — launch a single Orion desktop component for
# development, against the locally-built orion-framework.
#
# Sets up QT_QPA_PLATFORM=wayland, LD_LIBRARY_PATH, and QML_IMPORT_PATH
# so the locally-built framework is picked up without installing to /usr.
#
# Usage:
#   ./scripts/dev-run-shell.sh --component=panel [--hot-reload]
#   ./scripts/dev-run-shell.sh --component=start-menu
#   ./scripts/dev-run-shell.sh --component=settings
#
# Requires a running KWin Wayland session (or any Wayland compositor that
# supports the layer-shell protocol).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

COMPONENT=""
HOT_RELOAD=0

for arg in "$@"; do
    case "$arg" in
        --component=*) COMPONENT="${arg#*=}" ;;
        --hot-reload) HOT_RELOAD=1 ;;
        *) echo "Unknown arg: $arg" >&2; exit 1 ;;
    esac
done

if [ -z "$COMPONENT" ]; then
    echo "Usage: $0 --component=<name> [--hot-reload]" >&2
    echo "  Components: panel, start-menu, settings, file-manager," >&2
    echo "              welcome-center, software-center, notifications," >&2
    echo "              quick-settings, system-monitor, update-manager," >&2
    echo "              screenshot-tool, search, lockscreen, shell" >&2
    exit 1
fi

COMP_DIR="$REPO_ROOT/desktop/$COMPONENT"
[ -d "$COMP_DIR" ] || { echo "Component not found: $COMP_DIR" >&2; exit 1; }

BUILD_DIR="$COMP_DIR/build"
[ -d "$BUILD_DIR" ] || {
    echo "Build directory missing: $BUILD_DIR" >&2
    echo "Run: ./scripts/build-desktop.sh --component $COMPONENT --debug" >&2
    exit 1
}

# ---- Locate orion-framework build ------------------------------------------
ORION_FW_BUILD="$REPO_ROOT/desktop/orion-framework/build"
if [ ! -d "$ORION_FW_BUILD" ]; then
    echo "WARN: orion-framework is not built locally. Falling back to /usr/lib."
    FW_LIB_DIR=""
    FW_QML_DIR=""
else
    FW_LIB_DIR="$ORION_FW_BUILD"
    FW_QML_DIR="$ORION_FW_BUILD/qml"
fi

# ---- Set environment for the Orion session --------------------------------
export ORION_DESKTOP=1
export XDG_CURRENT_DESKTOP=orion
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=orion
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=orion
export QT_LOGGING_RULES="orion.*=true;kwin_*=false"
export QT_DEBUG_PLUGINS=0

# Point Qt at the locally-built orion-framework library and QML modules.
if [ -n "$FW_LIB_DIR" ]; then
    export LD_LIBRARY_PATH="$FW_LIB_DIR:${LD_LIBRARY_PATH:-}"
fi
if [ -n "$FW_QML_DIR" ]; then
    export QML_IMPORT_PATH="$FW_QML_DIR:${QML_IMPORT_PATH:-}"
    export QML2_IMPORT_PATH="$QML_IMPORT_PATH"
    export QT_ADDITIONAL_PACKAGES_PREFIX_PATH="$FW_QML_DIR"
fi

# Hot-reload: enable QQmlApplicationEngine file watcher.
if [ "$HOT_RELOAD" -eq 1 ]; then
    export ORION_HOT_RELOAD=1
    export QML_DISABLE_DISK_CACHE=1
fi

# Locate the built binary.
BINARY="$BUILD_DIR/orion-$COMPONENT"
if [ ! -x "$BINARY" ]; then
    # Some components have different binary names.
    BINARY="$BUILD_DIR/$COMPONENT"
    if [ ! -x "$BINARY" ]; then
        echo "Built binary not found in $BUILD_DIR" >&2
        echo "Expected: orion-$COMPONENT or $COMPONENT" >&2
        exit 1
    fi
fi

echo "[dev-run-shell] Launching $BINARY"
echo "[dev-run-shell] LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "[dev-run-shell] QML_IMPORT_PATH=$QML_IMPORT_PATH"

exec "$BINARY" "$@"
