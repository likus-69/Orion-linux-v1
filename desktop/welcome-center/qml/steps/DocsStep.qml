// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        Text {
            text: qsTr("Documentation and community")
            font.family: Theme.fontFamily
            font.pixelSize: 22
            font.weight: Font.DemiBold
            color: Theme.fgPrimary
        }
        Text {
            text: qsTr("Orion OS is a community project. Here's where to find help.")
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.fgSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.space3

            OrionCard {
                Layout.fillWidth: true
                title: qsTr("Documentation")
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: Theme.space3; spacing: Theme.space2
                    Text {
                        text: qsTr("Full documentation: installation, troubleshooting, development, security.")
                        font.family: Theme.fontFamily; font.pixelSize: 13
                        color: Theme.fgSecondary; wrapMode: Text.WordWrap; Layout.fillWidth: true
                    }
                    OrionButton {
                        text: qsTr("Open documentation")
                        variant: OrionButton.Variant.Secondary
                        onClicked: welcome.openBrowser("https://github.com/likus-69/Orion-linux-v1.1/tree/main/docs/")
                    }
                }
            }
            OrionCard {
                Layout.fillWidth: true
                title: qsTr("Community")
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: Theme.space3; spacing: Theme.space2
                    Text {
                        text: qsTr("Chat, forum, and bug tracker links.")
                        font.family: Theme.fontFamily; font.pixelSize: 13
                        color: Theme.fgSecondary; wrapMode: Text.WordWrap; Layout.fillWidth: true
                    }
                    OrionButton {
                        text: qsTr("Visit community hub")
                        variant: OrionButton.Variant.Secondary
                        onClicked: welcome.openBrowser("https://github.com/likus-69/Orion-linux-v1.1/discussions/")
                    }
                }
            }
        }
    }
}
