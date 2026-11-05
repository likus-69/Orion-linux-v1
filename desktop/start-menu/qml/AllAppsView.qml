// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors

import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

Item {
    id: view
    property string title: qsTr("All apps")
    property alias model: list.model
    implicitHeight: 380
    implicitWidth: parent ? parent.width : 600

    Text {
        id: header
        text: view.title
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.weight: Font.DemiBold
        color: Theme.fgSecondary
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: Theme.space2
    }

    ListView {
        id: list
        anchors.fill: parent
        anchors.topMargin: 32
        clip: true
        spacing: 0

        delegate: OrionListRow {
            width: list.width
            iconSource: modelData.icon
            title: modelData.name
            subtitle: modelData.genericName || modelData.comment || ""
            onClicked: {
                appIndex.launch(modelData.desktopFileId);
                menu.hide();
            }
        }

        ScrollBar.vertical: ScrollBar {}
    }
}
