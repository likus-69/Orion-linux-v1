// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
// App detail page — full description, screenshots, dependencies, install button.

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    property var app: null

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.space6
        spacing: Theme.space4

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space4

            Rectangle {
                width: 64; height: 64; radius: Theme.radiusLg
                color: Theme.surface3
                Image {
                    anchors.centerIn: parent
                    source: app ? app.icon : ""
                    sourceSize.width: 40; sourceSize.height: 40
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.space1
                Text {
                    text: app ? app.name : ""
                    font.family: Theme.fontFamily; font.pixelSize: 24
                    font.weight: Font.DemiBold; color: Theme.fgPrimary
                }
                Text {
                    text: app ? app.summary : ""
                    font.family: Theme.fontFamily; font.pixelSize: 14
                    color: Theme.fgSecondary
                }
                RepoBadge { repo: app ? app.repository : "extra" }
            }
            InstallButton { appId: app ? app.appId : "" }
        }

        // Long description
        Text {
            Layout.fillWidth: true
            text: app ? app.description : qsTr("No description available.")
            font.family: Theme.fontFamily; font.pixelSize: 14
            color: Theme.fgPrimary; wrapMode: Text.WordWrap
        }

        // Screenshots (placeholder)
        RowLayout {
            Layout.fillWidth: true; spacing: Theme.space3
            Repeater {
                model: 3
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 180
                    color: Theme.surface2; radius: Theme.radiusLg
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Screenshot ") + (index + 1)
                        color: Theme.fgTertiary
                    }
                }
            }
        }
    }
}
