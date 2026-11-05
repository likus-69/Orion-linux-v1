// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/SoftwareStep.qml — Step 7.
//
// Software installation intro. A button launches the Orion Software
// Center (which wraps pacman / PackageKit under the hood). The step is
// purely informational — installing apps is deferred to the Software
// Center so the welcome center itself never needs polkit.

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    id: step
    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        OrionLabel {
            role: OrionLabel.Role.H1
            text: qsTr("Install software")
        }
        OrionLabel {
            role: OrionLabel.Role.Body
            tint: Theme.fgSecondary
            text: qsTr("The Orion Software Center is the safe, signed way to install apps. "
                      + "It wraps pacman and PackageKit — every install is authorized by polkit "
                      + "and recorded in the system log.")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // ---- Quick-launch card ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Orion Software Center")
            subtitle: qsTr("Browse, install, and remove applications")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Row {
                    spacing: Theme.space3
                    width: parent.width

                    OrionButton {
                        text: qsTr("Open Software Center")
                        variant: OrionButton.Variant.Primary
                        size: OrionButton.Size.Default
                        onClicked: welcomeController.openSoftwareCenter()
                    }

                    Text {
                        text: qsTr("Opens in a new window. The welcome tour continues here.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 220
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        // ---- Recommended starter apps ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Recommended starter apps")
            subtitle: qsTr("Search these names in the Software Center")

            contentItem: Column {
                spacing: Theme.space2
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Repeater {
                    model: [
                        { name: "Firefox",         desc: qsTr("Web browser") },
                        { name: "Thunderbird",      desc: qsTr("Email client") },
                        { name: "LibreOffice",     desc: qsTr("Office suite") },
                        { name: "VLC",              desc: qsTr("Media player") },
                        { name: "GIMP",             desc: qsTr("Image editor") },
                        { name: "Visual Studio Code", desc: qsTr("Code editor") },
                        { name: "Steam",            desc: qsTr("Game client (multilib required)") }
                    ]
                    delegate: OrionListRow {
                        width: parent.width
                        title: modelData.name
                        subtitle: modelData.desc
                        accessoryText: qsTr("Search")
                        onClicked: welcomeController.openSoftwareCenter()
                    }
                }
            }
        }

        Item { Layout.fillHeight: true; Layout.preferredHeight: Theme.space2 }
    }
}
