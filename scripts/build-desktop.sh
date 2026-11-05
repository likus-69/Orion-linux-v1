#!/usr/bin/env bash
#
# scripts/build-desktop.sh — build every Orion desktop component (Qt6/QML).
#
# Iterates desktop/<component>/CMakeLists.txt, runs cmake + ninja in
# desktop/<component>/build/, installs to /usr (system) or a staging
# directory if --staging is provided.
#
# Usage:
#   ./scripts/build-desktop.sh [--staging <dir>] [--component <name>] [--debug]
#
# Examples:
#   ./scripts/build-desktop.sh                              # build all, install to /usr (sudo)
#   ./scripts/build-desktop.sh --staging ./build/stage      # build all, install to staging dir
#   ./scripts/build-desktop.sh --component panel --debug   # build only panel in debug mode

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

STAGING=""
COMPONENT=""
BUILD_TYPE=Release
EXTRA_CMAKE_ARGS=()

while [ $# -gt 0 ]; do
    case "$1" in
        --staging) STAGING="$2"; shift 2 ;;
        --component) COMPONENT="$2"; shift 2 ;;
        --debug) BUILD_TYPE=Debug; shift ;;
        --clean) EXTRA_CMAKE_ARGS+=("--fresh"); shift ;;
        *) echo "Unknown arg: $1" >&2; exit 1 ;;
    esac
done

if [ -n "$STAGING" ]; then
    CMAKE_INSTALL_PREFIX="$STAGING"
    NEEDS_SUDO=""
else
    CMAKE_INSTALL_PREFIX="/usr"
    if [ "$(id -u)" -ne 0 ]; then
        NEEDS_SUDO="sudo"
    else
        NEEDS_SUDO=""
    fi
fi

# Discover components with a CMakeLists.txt.
mapfile -t COMPONENTS < <(
    find "$REPO_ROOT/desktop" -mindepth 2 -maxdepth 2 -type f -name CMakeLists.txt \
        -printf '%h\n' | sort
)

if [ ${#COMPONENTS[@]} -eq 0 ]; then
    echo "No desktop components found under $REPO_ROOT/desktop" >&2
    exit 1
fi

if [ -n "$COMPONENT" ]; then
    COMPONENTS=("$REPO_ROOT/desktop/$COMPONENT")
    if [ ! -f "${COMPONENTS[0]}/CMakeLists.txt" ]; then
        echo "Component '$COMPONENT' has no CMakeLists.txt" >&2
        exit 1
    fi
fi

BUILT_OK=()
FAILED=()

for comp_dir in "${COMPONENTS[@]}"; do
    name="$(basename "$comp_dir")"
    build_dir="$comp_dir/build"
    echo ""
    echo "============================================================"
    echo "  Building: orion-$name"
    echo "============================================================"

    mkdir -p "$build_dir"

    if ! cmake -B "$build_dir" -S "$comp_dir" \
        -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
        -DCMAKE_INSTALL_PREFIX="$CMAKE_INSTALL_PREFIX" \
        -DBUILD_TESTING=ON \
        "${EXTRA_CMAKE_ARGS[@]}"; then
        echo "  CMAKE CONFIGURE FAILED for $name" >&2
        FAILED+=("$name")
        continue
    fi

    if ! cmake --build "$build_dir" -j"$(nproc)"; then
        echo "  BUILD FAILED for $name" >&2
        FAILED+=("$name")
        continue
    fi

    # Install (only if we're not in a sandbox with no install perms)
    if [ -n "$NEEDS_SUDO" ]; then
        if ! $NEEDS_SUDO cmake --install "$build_dir"; then
            echo "  INSTALL FAILED for $name (need sudo?) — skipping install" >&2
            # Still count as built; install can be retried.
        else
            BUILT_OK+=("$name")
        fi
    else
        if ! cmake --install "$build_dir"; then
            echo "  INSTALL FAILED for $name" >&2
            FAILED+=("$name")
        else
            BUILT_OK+=("$name")
        fi
    fi
done

echo ""
echo "============================================================"
echo "  BUILD SUMMARY"
echo "============================================================"
echo "  Built and installed OK: ${BUILT_OK[*]:-none}"
echo "  Failed:                 ${FAILED[*]:-none}"
echo ""

if [ ${#FAILED[@]} -gt 0 ]; then
    exit 1
fi
