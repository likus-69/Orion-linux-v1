// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/PrivacyStep.qml — Step 10.
//
// Privacy + security. Telemetry is OFF by default — the toggle must be
// explicitly enabled. The explanation makes clear what data would be
// sent (anonymous system stats only) and what would NOT (no personal
// info, no file paths, no network identifiers).
//
// Hard rule honored: this step never transmits anything. The toggle
// just persists the opt-in state to ~/.config/orion/welcome.json. A
// separate collector daemon (orion-telemetry-collector.service) reads
// the state and posts reports only when it is true.

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
            text: qsTr("Privacy & security")
        }
        OrionLabel {
            role: OrionLabel.Role.Body
            tint: Theme.fgSecondary
            text: qsTr("Orion OS is built privacy-first. Telemetry is OFF by default and must "
                      + "be explicitly enabled. No personal information is ever collected, "
                      + "stored, or transmitted.")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // ---- Telemetry card (OFF by default) ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Telemetry")
            subtitle: qsTr("Anonymous usage reports sent to the Orion OS project")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Row {
                    spacing: Theme.space3
                    width: parent.width

                    Text {
                        text: qsTr("Send anonymous telemetry")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item { width: 12; height: 1 }
                    OrionSwitch {
                        checked: welcomeController.telemetry
                        onToggled: welcomeController.telemetry = checked
                    }
                    Item { width: 12; height: 1 }
                    Rectangle {
                        width: pillText.implicitWidth + 16
                        height: 22
                        radius: 11
                        color: welcomeController.telemetry
                            ? Theme.success
                            : Theme.warning
                        anchors.verticalCenter: parent.verticalCenter

                        Behavior on color {
                            ColorAnimation { duration: Theme.motionFast }
                        }

                        Text {
                            id: pillText
                            anchors.centerIn: parent
                            text: welcomeController.telemetry
                                ? qsTr("ON (opted in)")
                                : qsTr("OFF by default")
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: Theme.fgInverse
                        }
                    }
                }

                Text {
                    text: qsTr("<b>Telemetry is disabled by default</b> and is strictly "
                              + "opt-in. When enabled, Orion sends an anonymous daily report "
                              + "containing: OS version, kernel version, CPU architecture, "
                              + "country (derived from timezone only), and counts of "
                              + "installed applications. <b>No personal data, file paths, "
                              + "or network identifiers are ever transmitted.</b> Reports "
                              + "are signed and posted to https://telemetry.github.com/likus-69/Orion-linux-v1.1/. "
                              + "You can disable this at any time in Settings → Privacy.")
                    textFormat: Text.RichText
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.fgSecondary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                Text {
                    text: qsTr("The toggle just persists the opt-in state to "
                              + "~/.config/orion/welcome.json. A separate collector daemon "
                              + "(orion-telemetry-collector.service) reads the state and "
                              + "posts reports only when it is true.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.fgTertiary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        // ---- Local diagnostics card ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Local crash reports")
            subtitle: qsTr("Stored locally; never sent automatically")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Text {
                    text: qsTr("Orion OS stores crash logs and performance traces locally "
                              + "under ~/.local/share/orion/diagnostics. They are never "
                              + "sent anywhere automatically; you must explicitly attach "
                              + "them to a bug report. This is independent of telemetry — "
                              + "even with telemetry ON, crash reports stay local.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.fgSecondary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        // ---- Disk encryption status ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Disk encryption")
            subtitle: qsTr("Status of the LUKS container backing the root filesystem")

            contentItem: Column {
                spacing: Theme.space2
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Text {
                    text: qsTr("If you chose “Encrypt disk” during install, your root "
                              + "filesystem is on a LUKS volume. If not, you can re-install "
                              + "Orion OS with encryption enabled. Orion OS does not support "
                              + "in-place conversion to LUKS.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.fgSecondary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                OrionButton {
                    text: qsTr("Open Privacy settings")
                    variant: OrionButton.Variant.Secondary
                    size: OrionButton.Size.Compact
                    onClicked: welcomeController.openSettings()
                }
            }
        }

        Item { Layout.fillHeight: true; Layout.preferredHeight: Theme.space2 }
    }
}
