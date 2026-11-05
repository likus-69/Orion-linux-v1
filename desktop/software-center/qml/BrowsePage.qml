// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent; anchors.margins: Theme.space4; spacing: Theme.space4

        Text {
            text: qsTr("Featured")
            font.family: Theme.fontFamily
            font.pixelSize: 16; font.weight: Font.DemiBold
            color: Theme.fgPrimary
        }

        // Featured apps row
        RowLayout {
            Layout.fillWidth: true; spacing: Theme.space3

            Repeater {
                model: catalog.featuredApps
                AppCard {
                    Layout.fillWidth: true; Layout.preferredHeight: 120
                    appId: modelData.appId
                    name: modelData.name
                    summary: modelData.summary
                    icon: modelData.icon
                    repo: modelData.repository
                }
            }
        }

        Text {
            text: qsTr("Categories")
            font.family: Theme.fontFamily
            font.pixelSize: 16; font.weight: Font.DemiBold
            color: Theme.fgPrimary
        }

        // Categories grid
        GridView {
            Layout.fillWidth: true; Layout.fillHeight: true
            cellWidth: 220; cellHeight: 120
            clip: true
            model: catalog.categories

            delegate: OrionCard {
                width: 200; height: 100
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: Theme.space3; spacing: Theme.space2
                    RowLayout {
                        Layout.fillWidth: true
                        OrionIcon { source: modelData.icon; size: 28 }
                        Text {
                            text: modelData.name
                            font.family: Theme.fontFamily; font.pixelSize: 14
                            font.weight: Font.DemiBold; color: Theme.fgPrimary
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
}
