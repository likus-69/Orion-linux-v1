// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    implicitHeight: 140
    implicitWidth: parent ? parent.width : 600

    RowLayout {
        anchors.fill: parent
        spacing: Theme.space4

        // Recent files column
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.space1

            Text {
                text: qsTr("Recent files")
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: Theme.fgSecondary
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: appIndex.recentFiles.slice(0, 6)
                clip: true
                delegate: OrionListRow {
                    width: parent.width
                    iconSource: "icon-file"
                    title: {
                        const uri = modelData.uri || "";
                        const last = uri.toString().split('/').pop();
                        return last;
                    }
                    subtitle: modelData.appName || qsTr("Unknown app")
                    showDivider: false
                    onClicked: Qt.openUrlExternally(modelData.uri)
                }
            }
        }

        // Recommended apps column
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.space1

            Text {
                text: qsTr("Recommended")
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: Theme.fgSecondary
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: appIndex.recommendedApps
                clip: true
                delegate: OrionListRow {
                    width: parent.width
                    iconSource: modelData.icon
                    title: modelData.name
                    subtitle: modelData.genericName || ""
                    showDivider: false
                    onClicked: {
                        appIndex.launch(modelData.desktopFileId);
                        menu.hide();
                    }
                }
            }
        }
    }
}
