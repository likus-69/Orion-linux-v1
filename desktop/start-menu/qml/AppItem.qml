// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors

import QtQuick
import org.orion.framework

Item {
    id: appItem
    property string iconSource: ""
    property string title: ""
    property string subtitle: ""
    property bool showDivider: true
    signal clicked()

    implicitHeight: 44
    implicitWidth: parent ? parent.width : 320

    Rectangle {
        anchors.fill: parent
        color: parent.hovered ? Theme.surface3 : Theme.surface1
        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.space3
        anchors.rightMargin: Theme.space3
        spacing: Theme.space3

        OrionIcon { source: appItem.iconSource; size: 24; anchors.verticalCenter: parent.verticalCenter }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 24 - Theme.space3
            Text {
                text: appItem.title
                font.family: Theme.fontFamily
                font.pixelSize: 14
                color: Theme.fgPrimary
                elide: Text.ElideRight
                width: parent.width
            }
            Text {
                text: appItem.subtitle
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.fgTertiary
                elide: Text.ElideRight
                width: parent.width
                visible: appItem.subtitle.length > 0
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: appItem.clicked()
    }

    Rectangle {
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        height: 1
        color: Theme.borderSubtle
        visible: appItem.showDivider
    }
}
