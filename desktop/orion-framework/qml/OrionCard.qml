// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/OrionCard.qml — bordered surface container with optional hover lift.

import QtQuick
import org.orion.framework

Item {
    id: control

    property string title: ""
    property string subtitle: ""
    property alias contentItem: contentColumn.children
    property bool interactive: false
    signal clicked()

    implicitHeight: Math.max(120, contentColumn.implicitHeight + 2 * Theme.space4 + (title ? 32 : 0))
    implicitWidth: 320

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Theme.radiusLg
        color: Theme.surface2
        border.width: 1
        border.color: Theme.borderSubtle

        Behavior on color { ColorAnimation { duration: Theme.motionDefault } }
        Behavior on border.color { ColorAnimation { duration: Theme.motionDefault } }
    }

    // Hover state — only when interactive.
    HoverHandler {
        enabled: control.interactive
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: {
            if (hovered) {
                bg.color = Theme.surface3;
                bg.border.color = Theme.accent500;
            } else {
                bg.color = Theme.surface2;
                bg.border.color = Theme.borderSubtle;
            }
        }
    }
    TapHandler {
        enabled: control.interactive
        onTapped: control.clicked()
    }

    // Focus ring for keyboard nav when interactive.
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: bg.radius + 2
        color: "transparent"
        border.width: 2
        border.color: Theme.accent500
        visible: control.interactive && control.activeFocus
    }

    Column {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: Theme.space4
        spacing: Theme.space2

        // Optional title bar.
        Item {
            width: parent.width
            height: titleText.implicitHeight + subtitleText.implicitHeight + Theme.space1
            visible: control.title.length > 0

            Text {
                id: titleText
                anchors.top: parent.top
                anchors.left: parent.left
                text: control.title
                font.family: Theme.fontFamily
                font.pixelSize: 16
                font.weight: 600
                color: Theme.fgPrimary
            }
            Text {
                id: subtitleText
                anchors.top: titleText.bottom
                anchors.left: parent.left
                text: control.subtitle
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: Theme.fgSecondary
                visible: control.subtitle.length > 0
            }
        }
    }
}
