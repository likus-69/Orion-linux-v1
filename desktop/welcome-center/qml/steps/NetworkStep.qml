// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        Text {
            text: qsTr("Connect to a network")
            font.family: Theme.fontFamily
            font.pixelSize: 22
            font.weight: Font.DemiBold
            color: Theme.fgPrimary
        }
        Text {
            text: qsTr("Pick a Wi-Fi network to connect to the internet. You can also do this later from Quick Settings.")
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.fgSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // Placeholder for Wi-Fi list (would query NetworkManager D-Bus in a real impl).
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: ListModel {
                ListElement { name: qsTr("OrionSetup"); strength: 4; secured: true }
                ListElement { name: qsTr("Guest Network"); strength: 3; secured: false }
                ListElement { name: qsTr("Hidden network..."); strength: 0; secured: false }
            }
            delegate: OrionListRow {
                width: parent.width
                iconSource: "icon-wifi"
                title: model.name
                subtitle: model.secured ? qsTr("Secured") : qsTr("Open")
                accessoryText: "●●●●".substring(0, model.strength)
                onClicked: {}  // Would open password dialog
            }
        }

        Text {
            text: qsTr("Tip: Wired connections work automatically; just plug in the cable.")
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: Theme.fgTertiary
            Layout.fillWidth: true
        }
    }
}
