// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework
import org.orion.softwarecenter

ApplicationWindow {
    id: window
    width: 1024; height: 720; visible: true
    title: qsTr("Orion Software Center")
    color: Theme.surface0

    // Navigation state.
    property string currentPage: "browse"
    property var selectedApp: null

    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // ---- Sidebar ----
        Sidebar {
            id: sidebar
            Layout.fillHeight: true
            Layout.preferredWidth: 220
            onPageSelected: (page) => window.currentPage = page
            currentPage: window.currentPage
            updateCount: pk.updatesReady.length  // simplified
        }

        // ---- Main content ----
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: Theme.surface1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.space4
                    anchors.rightMargin: Theme.space4
                    spacing: Theme.space3

                    Text {
                        text: window.currentPage === "browse"   ? qsTr("Browse")
                            : window.currentPage === "search"   ? qsTr("Search")
                            : window.currentPage === "installed" ? qsTr("Installed")
                            : window.currentPage === "updates"   ? qsTr("Updates")
                            : qsTr("Orion Software Center")
                        font.family: Theme.fontFamily
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        color: Theme.fgPrimary
                    }
                    Item { Layout.fillWidth: true }

                    // Search box
                    OrionTextField {
                        placeholderText: qsTr("Search apps…")
                        Layout.preferredWidth: 240
                        onTextChanged: {
                            if (text.length > 2) {
                                window.currentPage = "search";
                                pk.searchPackages(text);
                            }
                        }
                    }

                    OrionButton {
                        text: qsTr("Refresh")
                        variant: OrionButton.Variant.Secondary
                        onClicked: pk.refreshCache()
                        enabled: !pk.busy
                    }
                }
            }

            // Body
            StackLayout {
                id: body
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: ["browse", "search", "installed", "updates"]
                              .indexOf(window.currentPage)

                BrowsePage    {}
                SearchPage    {}
                InstalledPage {}
                UpdatesPage   {}
            }

            // Bottom progress bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: Theme.surface1
                visible: pk.busy

                Text {
                    anchors.centerIn: parent
                    text: pk.statusMessage
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.fgSecondary
                }
            }
        }
    }
}
