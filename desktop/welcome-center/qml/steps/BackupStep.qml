// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        Text {
            text: qsTr("Back up your data")
            font.family: Theme.fontFamily
            font.pixelSize: 22
            font.weight: Font.DemiBold
            color: Theme.fgPrimary
        }
        Text {
            text: qsTr("Btrfs snapshots are great for rolling back broken updates, but they are NOT a substitute for backups.\nWe strongly recommend an external backup to a USB drive or remote storage.")
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
                title: qsTr("Déjà Dup Backups")
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.space3
                    spacing: Theme.space2
                    Text {
                        text: qsTr("Simple GUI backup tool. Backs up to local folders, network shares, Google Drive.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    OrionButton {
                        text: qsTr("Open Déjà Dup")
                        variant: OrionButton.Variant.Primary
                        onClicked: welcome.setupBackup()
                    }
                }
            }

            OrionCard {
                Layout.fillWidth: true
                title: qsTr("Timeshift")
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.space3
                    spacing: Theme.space2
                    Text {
                        text: qsTr("System-level snapshots on Btrfs. Already configured by Orion OS by default.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
