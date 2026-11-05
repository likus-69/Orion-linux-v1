// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: Theme.space4; spacing: Theme.space4

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: qsTr("System updates")
                font.family: Theme.fontFamily; font.pixelSize: 16
                font.weight: Font.DemiBold; color: Theme.fgPrimary
                Layout.fillWidth: true
            }
            OrionButton {
                text: qsTr("Check for updates")
                variant: OrionButton.Variant.Primary
                onClicked: pk.getUpdates()
                enabled: !pk.busy
            }
        }

        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true; spacing: Theme.space2
            model: []  // populated by pk.updatesReady
            delegate: OrionListRow {
                width: parent.width
                iconSource: "icon-updates"
                title: modelData
                subtitle: qsTr("Update available")
                onClicked: pk.updatePackages([modelData])
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Item { Layout.fillWidth: true }
            OrionButton {
                text: qsTr("Update all")
                variant: OrionButton.Variant.Primary
                enabled: false  // enabled when updatesReady has entries
            }
        }
    }
}
