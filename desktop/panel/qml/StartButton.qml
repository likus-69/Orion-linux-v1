// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/StartButton.qml — Orion logo Start button.
//
// On click emits startMenuTriggered(). main.cpp connects this signal to a
// D-Bus call to the orion-start-menu service (org.orion.StartMenu.Toggle).
// A pulsing accent ring appears on hover while motion is allowed.

import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

Item {
    id: root

    signal startMenuTriggered()
    signal clicked()

    implicitWidth: 56
    implicitHeight: 48

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        onTapped: {
            root.clicked();
            root.startMenuTriggered();
        }
    }

    // Background circle that scales subtly on hover.
    Rectangle {
        id: hoverBg
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) - Theme.space2
        height: width
        radius: Theme.radiusFull
        color: hover.hovered ? Theme.surface3 : Theme.surface1.withAlpha(0)
        Behavior on color {
            ColorAnimation { duration: Theme.motionFast }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Theme.motionFast
                easing.type: Easing.OutCubic
            }
        }
        scale: hover.hovered ? 1.05 : 1.0
    }

    // Pulsing accent ring — only animates when motion is allowed.
    Rectangle {
        id: pulseRing
        anchors.centerIn: parent
        width: hoverBg.width + Theme.space1
        height: hoverBg.height + Theme.space1
        radius: Theme.radiusFull
        color: "transparent"
        border.width: 2
        border.color: Theme.accent500
        opacity: hover.hovered ? 1.0 : 0.0
        visible: opacity > 0.01

        SequentialAnimation on scale {
            running: hover.hovered && !Theme.reduceMotion
            loops: Animation.Infinite
            PauseAnimation { duration: 0 }
            NumberAnimation {
                from: 1.0
                to: 1.18
                duration: Theme.motionSlow
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                from: 1.18
                to: 1.0
                duration: Theme.motionSlow
                easing.type: Easing.InOutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation { duration: Theme.motionFast }
        }
    }

    // Orion logo — uses the freedesktop icon-theme entry "orion-logo" which
    // the orion-themes package installs. If the icon name is unknown to the
    // icon engine, Qt renders nothing; the hover ring still makes it clear
    // the area is interactive. A future OrionIcon.status bind could add a
    // fallback glyph here without changing the public API.
    OrionIcon {
        id: logoIcon
        anchors.centerIn: parent
        source: "orion-logo"
        tint: Theme.fgPrimary
        size: 28
    }

    // Tooltip: only the panel audience knows "Start" — show on hover.
    OrionTooltip {
        visible: hover.hovered
        text: qsTr("Start")
        x: (parent.width - width) / 2
        y: -height - Theme.space1
    }
}
