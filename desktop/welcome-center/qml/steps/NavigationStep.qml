// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        Text {
            text: qsTr("Get to know your desktop")
            font.family: Theme.fontFamily
            font.pixelSize: 22
            font.weight: Font.DemiBold
            color: Theme.fgPrimary
        }
        Text {
            text: qsTr("Orion's desktop takes inspiration from Windows but has its own identity.\nHere's a quick tour of the key elements.")
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.fgSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // Three feature cards.
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space3

            Repeater {
                model: [
                    { icon: "icon-start", title: qsTr("Start Menu"), text: qsTr("Click the Orion logo on the bottom-left of the panel, or press the Super key.") },
                    { icon: "icon-taskbar", title: qsTr("Panel"), text: qsTr("Pinned and running apps sit along the bottom. Right-click to pin/unpin.") },
                    { icon: "icon-quick-settings", title: qsTr("Quick Settings"), text: qsTr("Click the clock or system tray to access Wi-Fi, audio, battery, and power.") }
                ]

                OrionCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    title: modelData.title
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.space3
                        spacing: Theme.space2

                        OrionIcon { source: modelData.icon; size: 36 }
                        Text {
                            text: modelData.text
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

        Item { Layout.fillHeight: 1 }
    }
}
