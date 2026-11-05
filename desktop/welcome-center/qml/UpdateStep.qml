// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/UpdateStep.qml — Step 8.
//
// Update configuration. Toggle auto-check-for-updates (default ON — this
// is a local check that doesn't transmit any data, unlike telemetry).
// The step also kicks off the first `pkcon refresh` async, so by the
// time the user finishes the wizard, the local package database is
// up to date and the Update Manager can show pending updates.

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
            text: qsTr("Stay up to date")
        }
        OrionLabel {
            role: OrionLabel.Role.Body
            tint: Theme.fgSecondary
            text: qsTr("Orion OS uses PackageKit to check for updates. Auto-check just polls "
                      + "the local package database — it doesn't send any data anywhere. "
                      + "(Telemetry is a separate opt-in; see the next step.)")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // ---- Auto-check toggle ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Automatic update check")
            subtitle: qsTr("Daily background check for pending package updates")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Row {
                    spacing: Theme.space3
                    width: parent.width

                    Text {
                        text: qsTr("Check for updates automatically")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item { width: 16; height: 1 }
                    OrionSwitch {
                        checked: welcomeController.autoCheckUpdates
                        onToggled: welcomeController.autoCheckUpdates = checked
                    }
                    Item { width: 16; height: 1 }
                    Rectangle {
                        width: pillText.implicitWidth + 16
                        height: 22
                        radius: 11
                        color: Theme.success
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            id: pillText
                            anchors.centerIn: parent
                            text: qsTr("ON by default")
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: Theme.fgInverse
                        }
                    }
                }

                Text {
                    text: qsTr("Orion OS checks daily via orion-update-manager.service. When "
                              + "updates are available, the Update Manager shows a notification "
                              + "in the system tray. Installs require explicit polkit "
                              + "authorization — nothing is installed automatically.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.fgSecondary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        // ---- First refresh card ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Refresh package metadata now")
            subtitle: qsTr("Runs `pkcon refresh` in the background")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Row {
                    spacing: Theme.space3
                    width: parent.width

                    OrionButton {
                        text: qsTr("Refresh")
                        variant: OrionButton.Variant.Primary
                        size: OrionButton.Size.Default
                        enabled: !welcomeController.updateCheckRunning
                        onClicked: welcomeController.checkForUpdates()
                    }

                    Item { width: 16; height: 1 }

                    OrionBusy {
                        visible: welcomeController.updateCheckRunning
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        id: refreshStatus
                        text: welcomeController.updateCheckRunning
                                ? qsTr("Refreshing package metadata…")
                                : qsTr("Idle.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !updateResultText.visible
                    }

                    Text {
                        id: updateResultText
                        visible: false
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 200
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        Item { Layout.fillHeight: true; Layout.preferredHeight: Theme.space2 }
    }

    // Listen for the async result of checkForUpdates().
    Connections {
        target: welcomeController
        function onUpdateCheckFinished(success, message) {
            updateResultText.visible = true;
            refreshStatus.visible = false;
            updateResultText.text = (success
                ? qsTr("✓ %1").arg(message)
                : qsTr("⚠ %1").arg(message));
            updateResultText.color = success ? Theme.success : Theme.warning;
        }
        function onUpdateCheckRunningChanged() {
            if (welcomeController.updateCheckRunning) {
                updateResultText.visible = false;
                refreshStatus.visible = true;
            }
        }
    }
}
