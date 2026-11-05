// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/OrionListRow.qml — list row with leading icon, primary text,
// secondary text, and an optional trailing accessory.

import QtQuick
import org.orion.framework

Item {
    id: row

    property string iconSource: ""
    property string title: ""
    property string subtitle: ""
    property string accessoryText: ""
    property bool selected: false
    property bool showDivider: true

    signal clicked()

    implicitHeight: 40
    implicitWidth: parent ? parent.width : 360

    Rectangle {
        id: bg
        anchors.fill: parent
        color: row.selected
            ? Theme.accent500.withAlphaF(0.15)
            : (hover.hovered ? Theme.surface3 : Theme.surface1)
        Behavior on color { ColorAnimation { duration: Theme.motionFast } }

        // Selection indicator bar.
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 3
            color: Theme.accent500
            visible: row.selected
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        onTapped: row.clicked()
    }

    // Focus ring
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        color: "transparent"
        border.width: 2
        border.color: Theme.accent500
        visible: row.activeFocus
        z: -1
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.space3
        anchors.rightMargin: Theme.space3
        spacing: Theme.space3

        // Icon (24x24 by default)
        Item {
            id: iconSlot
            width: 24
            height: 24
            anchors.verticalCenter: parent.verticalCenter
            visible: row.iconSource.length > 0
            OrionIcon {
                anchors.fill: parent
                source: row.iconSource
            }
        }

        // Title + subtitle column
        Column {
            width: parent.width - iconSlot.width - accessorySlot.width - 3 * Theme.space3
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text: row.title
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.weight: row.selected ? 600 : 400
                color: row.enabled ? Theme.fgPrimary : Theme.fgDisabled
                elide: Text.ElideRight
                width: parent.width
            }
            Text {
                text: row.subtitle
                visible: row.subtitle.length > 0
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.fgTertiary
                elide: Text.ElideRight
                width: parent.width
            }
        }

        // Trailing accessory
        Item {
            id: accessorySlot
            width: accessoryText.implicitWidth + 8
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            visible: row.accessoryText.length > 0

            Text {
                id: accessoryText
                anchors.centerIn: parent
                text: row.accessoryText
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: Theme.fgSecondary
            }
        }
    }

    // Divider (optional)
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.borderSubtle
        visible: row.showDivider
    }
}
