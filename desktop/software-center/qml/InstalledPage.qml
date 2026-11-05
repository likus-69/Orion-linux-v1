// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: Theme.space4; spacing: Theme.space4

        Text {
            text: qsTr("Installed applications")
            font.family: Theme.fontFamily
            font.pixelSize: 16; font.weight: Font.DemiBold
            color: Theme.fgPrimary
        }

        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true
            spacing: Theme.space2
            model: pk.installedPackages()
            delegate: OrionListRow {
                width: parent.width
                iconSource: "icon-package"
                title: modelData
                subtitle: qsTr("Click to remove")
                onClicked: pk.removePackage(modelData)
            }
        }
    }
}
