// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    id: sidebar
    signal pageSelected(string page)
    property string currentPage: "browse"
    property int updateCount: 0

    Rectangle {
        anchors.fill: parent
        color: Theme.surface1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.space3
        spacing: Theme.space1

        // Logo
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space3

            Image {
                source: "file:///usr/share/orion/orion-logo.png"
                sourceSize.width: 24
                sourceSize.height: 24
            }
            Text {
                text: qsTr("Software Center")
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: Theme.fgPrimary
            }
        }

        Rectangle {
            Layout.fillWidth: true; height: 1
            color: Theme.borderSubtle
        }

        Repeater {
            model: [
                { id: "browse",    icon: "icon-grid",          label: qsTr("Browse") },
                { id: "search",    icon: "icon-search",        label: qsTr("Search") },
                { id: "installed", icon: "icon-installed",     label: qsTr("Installed") },
                { id: "updates",   icon: "icon-updates",       label: qsTr("Updates") }
            ]
            OrionListRow {
                Layout.fillWidth: true
                iconSource: modelData.icon
                title: modelData.label
                accessoryText: modelData.id === "updates" && sidebar.updateCount > 0
                              ? sidebar.updateCount : ""
                selected: sidebar.currentPage === modelData.id
                showDivider: false
                onClicked: sidebar.pageSelected(modelData.id)
            }
        }

        Item { Layout.fillHeight: 1 }

        Rectangle {
            Layout.fillWidth: true; height: 1
            color: Theme.borderSubtle
        }

        Text {
            text: qsTr("Sources:")
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            color: Theme.fgTertiary
        }
        Text {
            text: qsTr("• Arch official (signed)\n• Orion OS (signed)\n• Flatpak (sandboxed)\n• AUR (community, off by default)")
            font.family: Theme.fontFamily
            font.pixelSize: 11
            color: Theme.fgSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }
}
