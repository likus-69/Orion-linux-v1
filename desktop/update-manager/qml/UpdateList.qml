// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import org.orion.framework

ListView {
    id: list
    clip: true
    spacing: Theme.space1
    model: updates.updates

    delegate: OrionListRow {
        width: list.width
        iconSource: "icon-updates"
        title: modelData.name
        subtitle: modelData.version + "  →  " + modelData.newVersion
        accessoryText: modelData.size ? (modelData.size / 1024 / 1024).toFixed(1) + " MB" : ""
        onClicked: updates.applyOne(modelData.id)
    }

    Text {
        anchors.centerIn: parent
        visible: list.count === 0
        text: qsTr("All packages are up to date.")
        font.family: Theme.fontFamily; font.pixelSize: 14
        color: Theme.fgTertiary
    }
}
