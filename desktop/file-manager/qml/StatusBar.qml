// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/StatusBar.qml — bottom status bar.
//
// Left  : item count + selected count + selected size
// Center: current folder path (elided)
// Right : free disk space on the current filesystem

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Rectangle {
    id: root
    implicitHeight: 28
    color: Theme.surface1

    property int itemCount: 0
    property int selectedCount: 0
    property string selectedSizeText: ""
    property string freeSpaceText: ""
    property string currentPath: ""

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: Theme.borderSubtle
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.space3
        anchors.rightMargin: Theme.space3
        spacing: Theme.space4

        Text {
            text: root.selectedCount > 0
                ? qsTr("%1 of %2 selected (%3)")
                    .arg(root.selectedCount)
                    .arg(root.itemCount)
                    .arg(root.selectedSizeText)
                : qsTr("%1 item(s)").arg(root.itemCount)
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: Theme.fgSecondary
        }

        Item { Layout.fillWidth: true }

        Text {
            text: root.currentPath
            font.family: Theme.fontFamilyMono
            font.pixelSize: 11
            color: Theme.fgTertiary
            elide: Text.ElideMiddle
            Layout.preferredWidth: 360
            horizontalAlignment: Text.AlignHCenter
        }

        Item { Layout.fillWidth: true }

        Text {
            text: qsTr("Free space: %1").arg(root.freeSpaceText)
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: Theme.fgSecondary
            horizontalAlignment: Text.AlignRight
        }
    }
}
