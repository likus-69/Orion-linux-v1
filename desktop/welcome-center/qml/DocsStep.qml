// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/DocsStep.qml — Step 11.
//
// Documentation + community links. Every link is opened via
// welcomeController.openBrowser(url), which dispatches to the user's
// default browser through QDesktopServices — no personal info is sent
// in the URL, and no telemetry accompanies the navigation.

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    id: step
    Layout.fillWidth: true
    Layout.fillHeight: true

    readonly property var links: [
        { name: qsTr("Documentation"),
          desc: qsTr("Full guides, how-tos, and the Orion OS handbook"),
          url: welcomeController.documentationUrl(),
          icon: "system-help" },
        { name: qsTr("Community forum"),
          desc: qsTr("Ask questions, share tips, get help from other users"),
          url: welcomeController.communityUrl(),
          icon: "system-users" },
        { name: qsTr("Issue tracker"),
          desc: qsTr("Report bugs and request features (GitLab)"),
          url: welcomeController.issueTrackerUrl(),
          icon: "tools-report-bug" },
        { name: qsTr("Contributing guide"),
          desc: qsTr("How to submit patches, translate, or package for Orion OS"),
          url: welcomeController.documentationUrl() + "contributing/",
          icon: "document-edit" },
        { name: qsTr("Security policy"),
          desc: qsTr("How to report security vulnerabilities responsibly"),
          url: welcomeController.documentationUrl() + "security/",
          icon: "security-high" }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        OrionLabel {
            role: OrionLabel.Role.H1
            text: qsTr("Docs & community")
        }
        OrionLabel {
            role: OrionLabel.Role.Body
            tint: Theme.fgSecondary
            text: qsTr("Orion OS is a community project. Whether you're stuck, curious, or "
                      + "ready to contribute, here's where to go. Every link opens in your "
                      + "default browser.")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // ---- Links list ----
        OrionCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: qsTr("Resources")
            subtitle: qsTr("Click any row to open in your browser")

            contentItem: Column {
                spacing: Theme.space2
                width: parent ? parent.width - 2 * Theme.space4 : 480

                ListView {
                    width: parent.width
                    height: Math.max(200, contentHeight)
                    clip: true
                    model: step.links
                    delegate: OrionListRow {
                        width: ListView.view.width
                        iconSource: modelData.icon
                        title: modelData.name
                        subtitle: modelData.desc
                        accessoryText: qsTr("Open")
                        onClicked: welcomeController.openBrowser(modelData.url)
                    }
                }
            }
        }

        // ---- Matrix / IRC card ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Chat with us")
            subtitle: qsTr("Real-time help on Matrix and IRC")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Text {
                    text: qsTr("Join #orion-os:matrix.org for live help. The Orion OS "
                              + "community is friendly and patient — no question is too "
                              + "basic. The core team hangs out in the same channel.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.fgSecondary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                Row {
                    spacing: Theme.space3
                    width: parent.width

                    OrionButton {
                        text: qsTr("Open Matrix channel")
                        variant: OrionButton.Variant.Secondary
                        size: OrionButton.Size.Compact
                        onClicked: welcomeController.openBrowser(
                            "https://matrix.to/#/#orion-os:matrix.org")
                    }

                    OrionButton {
                        text: qsTr("IRC (#orion-os on Libera)")
                        variant: OrionButton.Variant.Ghost
                        size: OrionButton.Size.Compact
                        onClicked: welcomeController.openBrowser(
                            "https://web.libera.chat/?channel=#orion-os")
                    }
                }
            }
        }

        Item { Layout.fillHeight: true; Layout.preferredHeight: Theme.space2 }
    }
}
