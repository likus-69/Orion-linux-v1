// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        Text {
            text: qsTr("Install software")
            font.family: Theme.fontFamily
            font.pixelSize: 22
            font.weight: Font.DemiBold
            color: Theme.fgPrimary
        }
        Text {
            text: qsTr("Open the Orion Software Center to browse and install apps.\nOrion separates official Arch repositories, Orion OS repositories, Flatpak, and the optional AUR.")
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.fgSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space3

            Repeater {
                model: [
                    { name: "Firefox",       icon: "icon-firefox",   desc: qsTr("Web browser") },
                    { name: "LibreOffice",   icon: "icon-office",   desc: qsTr("Office suite") },
                    { name: "GIMP",          icon: "icon-gimp",     desc: qsTr("Image editor") },
                    { name: "VLC",           icon: "icon-vlc",       desc: qsTr("Media player") },
                    { name: "Steam (Flatpak)", icon: "icon-steam", desc: qsTr("Game launcher") },
                    { name: "Spotify",       icon: "icon-spotify",  desc: qsTr("Music streaming") }
                ]
                OrionCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.space3
                        spacing: Theme.space2
                        OrionIcon { source: modelData.icon; size: 24 }
                        Text {
                            text: modelData.name
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: Theme.fgPrimary
                        }
                        Text {
                            text: modelData.desc
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.fgTertiary
                        }
                    }
                }
            }
        }

        OrionButton {
            text: qsTr("Open Software Center")
            variant: OrionButton.Variant.Primary
            onClicked: welcome.openSoftwareCenter()
        }
    }
}
