// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/BackupStep.qml — Step 9.
//
// Backup recommendations. Offers buttons to launch Deja-Dup (user data)
// and Timeshift (system snapshots) if they're installed. If neither is
// available, shows manual instructions.

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
            text: qsTr("Back up your data")
        }
        OrionLabel {
            role: OrionLabel.Role.Body
            tint: Theme.fgSecondary
            text: qsTr("Orion OS ships with snapper pre-configured for system rollbacks on "
                      + "BTRFS roots. For your personal files, we recommend Deja-Dup — it "
                      + "schedules encrypted, compressed backups to a USB drive, network "
                      + "share, or cloud account.")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // ---- Deja-Dup card ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Deja-Dup — Personal file backup")
            subtitle: qsTr("Encrypted, scheduled, user-friendly")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Text {
                    text: qsTr("Deja-Dup backs up your home directory on a schedule you "
                              + "choose. Backups are encrypted with a passphrase you set — "
                              + "Orion OS never sees the key.")
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
                        text: qsTr("Set up Deja-Dup")
                        variant: OrionButton.Variant.Primary
                        size: OrionButton.Size.Default
                        onClicked: {
                            const ok = welcomeController.setupBackup();
                            if (!ok) {
                                // No backup GUI installed — show manual
                                // instructions in the second card below.
                                manualCard.visible = true;
                            }
                        }
                    }

                    Text {
                        text: qsTr("If deja-dup isn't installed, manual instructions appear below.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.fgTertiary
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 220
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        // ---- Timeshift card ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Timeshift — System snapshots")
            subtitle: qsTr("BTRFS or RSYNC system rollback")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Text {
                    text: qsTr("Timeshift takes snapshots of system files (not your home "
                              + "directory) so you can roll back after a bad update. On BTRFS "
                              + "installs, Orion OS already ships with a snapper config at "
                              + "/etc/snapper/configs/root — Timeshift is an alternative GUI.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.fgSecondary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                OrionButton {
                    text: qsTr("Open Timeshift")
                    variant: OrionButton.Variant.Secondary
                    size: OrionButton.Size.Compact
                    onClicked: {
                        // Timeshift needs root; it invokes pkexec internally.
                        const ok = welcomeController.setupBackup();
                        if (!ok) manualCard.visible = true;
                    }
                }
            }
        }

        // ---- Manual instructions (hidden by default) ----
        OrionCard {
            id: manualCard
            Layout.fillWidth: true
            visible: false
            title: qsTr("Manual backup setup")
            subtitle: qsTr("No backup GUI installed")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Text {
                    text: welcomeController.backupInstructions()
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 12
                    color: Theme.fgSecondary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                OrionButton {
                    text: qsTr("Install deja-dup")
                    variant: OrionButton.Variant.Primary
                    size: OrionButton.Size.Compact
                    onClicked: welcomeController.openSoftwareCenter()
                }
            }
        }

        Item { Layout.fillHeight: true; Layout.preferredHeight: Theme.space2 }
    }
}
