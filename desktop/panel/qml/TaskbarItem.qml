// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/TaskbarItem.qml — a single taskbar entry (pinned or running).
//
// The model entry passed in via `taskData` has the fields produced by
// Main.qml.__mergedTasks():
//   { kind, desktopFileId, name, icon, exec,
//     running, active, minimized, uuid }
//
// Click:
//   * If pinned-and-running OR running-only: activate the window via the
//     panelKWin.activateWindow(uuid) D-Bus call.
//   * If pinned-and-not-running: launch via panelPinned.launch(desktopFileId).
// Right-click: open a small context menu with Close (running only) and
// Pin/Unpin actions.

import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

Item {
    id: root

    property var taskData: ({})
    readonly property bool isPinned: taskData.kind === "pinned"
    readonly property bool isRunning: !!taskData.running
    readonly property bool isActive: !!taskData.active
    readonly property bool isMinimized: !!taskData.minimized

    signal clicked(var taskData)
    signal requestPin(string desktopFileId)
    signal requestUnpin(string desktopFileId)

    implicitWidth: 40
    implicitHeight: 40

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: {
            root.clicked(root.taskData);
            if (root.isRunning && root.taskData.uuid) {
                panelKWin.activateWindow(root.taskData.uuid);
            } else if (root.isPinned && root.taskData.desktopFileId) {
                panelPinned.launch(root.taskData.desktopFileId);
            }
        }
    }
    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: contextMenu.popup()
    }

    // Background tile.
    Rectangle {
        id: tile
        anchors.fill: parent
        anchors.margins: Theme.space1
        radius: Theme.radiusMd
        color: root.isActive
            ? Theme.accent500.withAlphaF(0.18)
            : hover.hovered
                ? Theme.surface3
                : Theme.surface1.withAlpha(0)
        border.width: root.isActive ? 1 : 0
        border.color: Theme.accent500.withAlphaF(0.4)
        Behavior on color {
            ColorAnimation { duration: Theme.motionFast }
        }
    }

    // App icon — 24x24 per spec.
    OrionIcon {
        id: icon
        anchors.centerIn: parent
        size: 24
        source: root.taskData.icon || "application-x-executable"
        tint: root.isActive ? Theme.accent300 : Theme.fgPrimary
    }

    // Running indicator dot beneath the icon (Windows 11 style).
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.space1
        width: root.isRunning ? (root.isActive ? 18 : 6) : 0
        height: 3
        radius: Theme.radiusFull
        color: Theme.accent500
        Behavior on width {
            NumberAnimation {
                duration: Theme.motionFast
                easing.type: Easing.OutCubic
            }
        }
    }

    // Tooltip with the title (always on hover).
    OrionTooltip {
        visible: hover.hovered
        text: root.taskData.name || qsTr("Unknown")
        x: (parent.width - width) / 2
        y: -height - Theme.space1
    }

    // Context menu (right-click).
    OrionMenu {
        id: contextMenu

        MenuItem {
            text: root.isRunning ? qsTr("Activate") : qsTr("Launch")
            onTriggered: {
                if (root.isRunning && root.taskData.uuid) {
                    panelKWin.activateWindow(root.taskData.uuid);
                } else if (root.isPinned) {
                    panelPinned.launch(root.taskData.desktopFileId);
                }
            }
        }
        MenuItem {
            text: root.isPinned ? qsTr("Unpin from panel") : qsTr("Pin to panel")
            onTriggered: {
                if (root.isPinned) {
                    root.requestUnpin(root.taskData.desktopFileId);
                } else if (root.taskData.desktopFileId) {
                    root.requestPin(root.taskData.desktopFileId);
                }
            }
        }
        MenuItem {
            text: qsTr("Close window")
            enabled: root.isRunning
            onTriggered: {
                if (root.taskData.uuid)
                    panelKWin.closeWindow(root.taskData.uuid);
            }
        }
    }
}
