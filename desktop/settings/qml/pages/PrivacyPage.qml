// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/pages/PrivacyPage.qml — Privacy & Security settings.
//
// Sections:
//   * Firewall status card (ufw wrapper)
//   * Screen-lock timeout
//   * Disk-encryption status (LUKS via lsblk)
//   * Telemetry (OFF by default; explanation)
//   * Diagnostics toggle
//   * App permissions (per-app ruleset)

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework

Flickable {
    id: page
    anchors.fill: parent
    contentWidth: width
    contentHeight: column.implicitHeight + 2 * Theme.space5
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

    readonly property var fw: controller.firewallStatus
    readonly property var enc: controller.diskEncryptionStatus
    readonly property var pv: controller.privacySettings

    ColumnLayout {
        id: column
        width: page.width - 2 * Theme.space5
        x: Theme.space5
        y: Theme.space5
        spacing: Theme.space5

        // ---- Firewall status ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Firewall")
            subtitle: fw.available
                ? qsTr("Backend: %1").arg(fw.backend)
                : qsTr("No firewall backend detected (install ufw or nftables)")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width

                    // Status pill.
                    Rectangle {
                        width: statusText.implicitWidth + 20
                        height: 24
                        radius: 12
                        color: fw.enabled ? Theme.success : Theme.warning
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            id: statusText
                            anchors.centerIn: parent
                            text: fw.enabled ? qsTr("Active") : qsTr("Inactive")
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: Theme.fgInverse
                        }
                    }
                    Item { width: 200; height: 1 }
                    Item { Layout.fillWidth: true; width: 100 }
                    OrionButton {
                        text: fw.enabled ? qsTr("Disable") : qsTr("Enable")
                        variant: fw.enabled ? OrionButton.Variant.Danger
                                            : OrionButton.Variant.Primary
                        size: OrionButton.Size.Compact
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: fw.enabled
                            ? controller.disableFirewall()
                            : controller.enableFirewall()
                    }
                }

                // Rules list (ufw status output).
                ListView {
                    width: parent.width
                    height: Math.min(180, contentHeight)
                    clip: true
                    visible: fw.rules && fw.rules.length > 0
                    model: fw.rules
                    delegate: OrionListRow {
                        width: ListView.view.width
                        title: modelData.to
                        subtitle: qsTr("From %1").arg(modelData.from)
                        accessoryText: modelData.action
                    }
                }

                Text {
                    text: qsTr("Toggle uses ufw.service via systemd. A polkit prompt will appear.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.fgTertiary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        // ---- Screen-lock timeout ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Screen lock")
            subtitle: qsTr("How long the session can be idle before locking")

            contentItem: Row {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Text {
                    text: qsTr("Lock after")
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.fgSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }
                OrionComboBox {
                    id: lockCombo
                    width: 200
                    model: [
                        qsTr("Never"),
                        qsTr("30 seconds"),
                        qsTr("1 minute"),
                        qsTr("2 minutes"),
                        qsTr("5 minutes"),
                        qsTr("10 minutes"),
                        qsTr("30 minutes")
                    ]
                    property var secondsMap: [0, 30, 60, 120, 300, 600, 1800]
                    Component.onCompleted: {
                        var v = pv.screenLockTimeout;
                        var idx = secondsMap.indexOf(v);
                        if (idx < 0) idx = 4;
                        currentIndex = idx;
                    }
                    onActivated: controller.setScreenLockTimeout(secondsMap[currentIndex])
                }
            }
        }

        // ---- Disk encryption status ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Disk encryption")
            subtitle: qsTr("Status of the LUKS container backing the root filesystem")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width

                    Rectangle {
                        width: encStatusText.implicitWidth + 20
                        height: 24
                        radius: 12
                        color: enc.rootOnLuks ? Theme.success : Theme.warning
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            id: encStatusText
                            anchors.centerIn: parent
                            text: enc.rootOnLuks ? qsTr("Encrypted (LUKS)") : qsTr("Not encrypted")
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: Theme.fgInverse
                        }
                    }
                    Item { width: 16; height: 1 }
                    Text {
                        text: enc.rootOnLuks && enc.luksDevice
                            ? qsTr("LUKS device: /dev/%1").arg(enc.luksDevice)
                            : qsTr("The root filesystem is not on a LUKS volume.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Text {
                    text: qsTr("Detected via `lsblk --json`. To enable disk encryption, "
                              + "reinstall Orion with the “Encrypt disk” option in the installer.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.fgTertiary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        // ---- Telemetry (off by default) ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Telemetry")
            subtitle: qsTr("Anonymous usage reports sent to the Orion OS project")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

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
                    OrionSwitch {
                        checked: pv.telemetry || false
                        onToggled: controller.setTelemetry(checked)
                    }
                    Item { width: 12; height: 1 }
                    Rectangle {
                        width: pillText.implicitWidth + 16
                        height: 22
                        radius: 11
                        color: Theme.warning
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            id: pillText
                            anchors.centerIn: parent
                            text: qsTr("OFF by default")
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: Theme.fgInverse
                        }
                    }
                }
                Text {
                    text: qsTr("Telemetry is <b>disabled by default</b> and is strictly opt-in. "
                              + "When enabled, Orion sends an anonymous daily report containing: "
                              + "OS version, kernel version, CPU architecture, country (derived "
                              + "from timezone), and counts of installed applications. "
                              + "<b>No personal data, file paths, or network identifiers are "
                              + "ever transmitted.</b> Reports are signed and posted to "
                              + "https://telemetry.github.com/likus-69/Orion-linux-v1.1/")
                    textFormat: Text.RichText
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.fgSecondary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        // ---- Diagnostics ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Diagnostics")
            subtitle: qsTr("Local crash reports and performance traces")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Collect local diagnostics")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionSwitch {
                        checked: pv.diagnostics || false
                        onToggled: controller.setDiagnostics(checked)
                    }
                }
                Text {
                    text: qsTr("When enabled, Orion stores crash logs and performance traces "
                              + "locally under ~/.local/share/orion/diagnostics. They are never "
                              + "sent anywhere automatically; you must opt in to attach them "
                              + "to a bug report.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.fgSecondary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        Item { Layout.fillHeight: true; height: Theme.space2 }
    }
}
