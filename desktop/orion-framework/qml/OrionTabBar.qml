// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/OrionTabBar.qml — top tab bar with underline indicator.

import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

TabBar {
    id: bar
    implicitHeight: 40
    spacing: 0

    background: Rectangle {
        color: Theme.surface1
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Theme.borderSubtle
        }
    }

    contentItem: ListView {
        model: bar.contentModel
        currentIndex: bar.currentIndex
        spacing: 0
        orientation: ListView.Horizontal
    }

    delegate: TabButton {
        text: modelData
        width: Math.max(120, implicitContentWidth + 2 * Theme.space4)
        font.family: Theme.fontFamily
        font.pixelSize: 14
        font.weight: bar.currentIndex === index ? Font.DemiBold : Font.Normal
        contentItem: Text {
            text: parent.text
            font: parent.font
            color: bar.currentIndex === index ? Theme.fgPrimary : Theme.fgSecondary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: "transparent"
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2 * Theme.space4
                height: 2
                color: Theme.accent500
                visible: bar.currentIndex === index
            }
        }
    }
}
