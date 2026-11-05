// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        Text {
            text: qsTr("Stay up to date")
            font.family: Theme.fontFamily
            font.pixelSize: 22
            font.weight: Font.DemiBold
            color: Theme.fgPrimary
        }
        Text {
            text: qsTr("Orion OS uses Arch Linux's rolling-release model. Updates arrive continuously.\nWe recommend checking for updates weekly. Orion can notify you automatically.")
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.fgSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.space3

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: qsTr("Check for updates automatically (every 4 hours)")
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    color: Theme.fgPrimary
                    Layout.fillWidth: true
                }
                Switch { checked: true }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: qsTr("Notify me about available updates")
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    color: Theme.fgPrimary
                    Layout.fillWidth: true
                }
                Switch { checked: true }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: qsTr("Create a Btrfs snapshot before each system update")
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    color: Theme.fgPrimary
                    Layout.fillWidth: true
                }
                Switch { checked: true }
            }
        }

        OrionButton {
            text: qsTr("Check for updates now")
            variant: OrionButton.Variant.Secondary
            onClicked: welcome.checkForUpdates()
        }
    }
}
