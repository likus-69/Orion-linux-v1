// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/Main.qml — root panel window.
//
// The bottom taskbar of Orion OS. Three logical sections are laid out
// inside one Row:
//   * LEFT   — Start button
//   * CENTER — pinned + running apps (anchored to the screen centre in the
//              "centered" layout, or pushed right after the Start button in
//              the "left" layout)
//   * RIGHT  — system tray (clock, audio, battery, network, quick-settings)
//
// The window itself is an ApplicationWindow. When LayerShellQt was found at
// build time, main.cpp anchors it to the bottom Wayland output as a
// top-layer surface with an exclusive zone equal to the panel height.
// Without LayerShellQt the window is a frameless window positioned at the
// bottom of the screen — visually equivalent, just not compositor-anchored.

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Window
import org.orion.framework

ApplicationWindow {
    id: panelRoot

    // --- Geometry ---------------------------------------------------------
    // Height is configurable between 36 and 56 (spec). Default 48.
    readonly property int panelHeight: {
        const raw = panelSettings.get("height", 48);
        const v = parseInt(raw, 10) || 48;
        return Math.max(36, Math.min(56, v));
    }
    readonly property string panelLayout:
        panelSettings.get("layout", "centered")

    // Theme-aware opacity: when reduceTransparency is true the panel is
    // fully opaque (no compositor blur). Otherwise we let a fraction of the
    // wallpaper show through and rely on the compositor to blur behind us.
    readonly property real panelOpacity:
        Theme.reduceTransparency ? 1.0 : 0.92

    width: Screen.width
    height: panelHeight
    x: 0
    y: Screen.height - panelHeight
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"  // background drawn by the inner Rectangle
    visible: true

    // panelSettings is exposed as a context property from main.cpp (the
    // C++ Orion::Settings class has no default constructor so it can't be
    // instantiated directly in QML).

    // --- Background -------------------------------------------------------
    Rectangle {
        id: bg
        anchors.fill: parent
        color: Theme.surface1
        opacity: panelRoot.panelOpacity

        // Bottom corners are flush with the screen edge — we mask the
        // rounded corner there with a thin rectangle.
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Theme.radiusLg
            color: parent.color
        }
        // Top hairline border (spec).
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: Theme.borderSubtle
        }
        // Subtle top-rounded corners are purely cosmetic — the panel
        // background rectangle is already a plain rectangle here.
        radius: 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motionDefault
                easing.type: Easing.OutCubic
            }
        }
    }

    // --- Merged task list model ------------------------------------------
    // For each pinned app we show one TaskbarItem. If a running window's
    // appId matches the pinned app's desktopFileId (without the .desktop
    // suffix), we attach the running indicator to that pinned item.
    // Remaining running windows (not pinned) are appended afterwards.
    //
    // The binding explicitly reads panelPinned.pinnedApps and
    // panelKWin.windows first thing so QML's dependency-capture picks them
    // up and re-evaluates this property on their respective NOTIFY signals.
    readonly property var mergedTasks: {
        const pinned = panelPinned ? panelPinned.pinnedApps : [];
        const running = panelKWin ? panelKWin.windows : [];

        const out = [];
        const runningByApp = {};
        for (let i = 0; i < running.length; ++i) {
            const w = running[i];
            const key = String(w.appId || "").toLowerCase();
            if (key && !(key in runningByApp)) runningByApp[key] = w;
        }
        for (let i = 0; i < pinned.length; ++i) {
            const p = pinned[i];
            const id = String(p.desktopFileId || "")
                .replace(/\.desktop$/i, "").toLowerCase();
            const w = runningByApp[id] || null;
            out.push({
                kind: "pinned",
                desktopFileId: p.desktopFileId,
                name: p.name,
                icon: p.icon,
                exec: p.exec,
                running: w ? true : false,
                active: w ? !!w.isActive : false,
                minimized: w ? !!w.isMinimized : false,
                uuid: w ? w.uuid : ""
            });
        }
        for (let i = 0; i < running.length; ++i) {
            const w = running[i];
            const key = String(w.appId || "").toLowerCase();
            if (key in runningByApp && runningByApp[key] === w) {
                // Already attached to a pinned entry.
                continue;
            }
            out.push({
                kind: "running",
                desktopFileId: "",
                name: w.title || w.appId || "Window",
                icon: w.appId || "application-x-executable",
                exec: "",
                running: true,
                active: !!w.isActive,
                minimized: !!w.isMinimized,
                uuid: w.uuid || ""
            });
        }
        return out;
    }

    // --- Layout -----------------------------------------------------------
    Row {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: Theme.space3
        anchors.rightMargin: Theme.space3
        spacing: Theme.space2

        // LEFT: Start button
        StartButton {
            id: startButton
            objectName: "startButton"  // matched by main.cpp for D-Bus trigger
            height: panelRoot.panelHeight
            width: 56
        }

        // Growing spacer that pushes the centre block (or the tray in the
        // "left" layout) to its proper place.
        // For the "centered" layout we mirror left and right spacers so the
        // task list sits at the screen's horizontal centre. The 4*space2
        // term accounts for the Row's inter-child spacing (4 gaps between
        // 5 children) and the 2*space3 term accounts for the Row's own
        // left+right margins.
        Item {
            id: leftSpacer
            height: 1
            width: panelRoot.panelLayout === "centered"
                ? Math.max(0, (panelRoot.width
                              - 2 * Theme.space3
                              - 4 * Theme.space2
                              - startButton.width
                              - taskList.width
                              - tray.implicitWidth) / 2)
                : Theme.space2
        }

        // CENTER (or LEFT) task list
        Row {
            id: taskList
            height: panelRoot.panelHeight
            spacing: Theme.space1

            Repeater {
                model: panelRoot.mergedTasks
                TaskbarItem {
                    height: panelRoot.panelHeight
                    width: panelRoot.panelHeight  // square-ish tile
                    taskData: modelData
                }
            }
        }

        // Growing spacer that pushes the tray to the right edge.
        Item {
            height: 1
            width: panelRoot.panelLayout === "centered"
                ? leftSpacer.width   // mirror the left spacer for symmetry
                : Math.max(0, panelRoot.width
                              - 2 * Theme.space3
                              - 4 * Theme.space2
                              - startButton.width
                              - leftSpacer.width
                              - taskList.width
                              - tray.implicitWidth)
        }

        // RIGHT: system tray
        SystemTray {
            id: tray
            height: panelRoot.panelHeight
        }
    }
}
