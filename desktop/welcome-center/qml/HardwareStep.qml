// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/HardwareStep.qml — Step 6.
//
// Calls welcomeController.runHardwareScan() and shows NVIDIA/Broadcom
// detected devices plus suggested driver packages. The scan is done
// synchronously (orion-hardware-scan runs in under a second). If the
// scan finds NVIDIA or Broadcom devices, we suggest installing the
// matching driver packages via the Software Center.
//
// No personal info is collected — the scan only reads PCI IDs from lspci.

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    id: step
    Layout.fillWidth: true
    Layout.fillHeight: true

    property var scan: ({})
    property bool scanning: false

    Component.onCompleted: runScan()

    function runScan() {
        scanning = true;
        // runHardwareScan is synchronous (orion-hardware-scan runs in
        // under a second). We invoke it via Qt.callLater so the UI has
        // a chance to paint the "scanning…" state first.
        Qt.callLater(function() {
            scan = welcomeController.runHardwareScan();
            scanning = false;
        });
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        OrionLabel {
            role: OrionLabel.Role.H1
            text: qsTr("Hardware check")
        }
        OrionLabel {
            role: OrionLabel.Role.Body
            tint: Theme.fgSecondary
            text: qsTr("Orion OS ships with most open-source drivers preinstalled. We'll check "
                      + "for NVIDIA GPUs and Broadcom Wi-Fi cards that need out-of-tree drivers.")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // ---- Scan status ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Scan results")
            subtitle: scanning
                ? qsTr("Scanning PCI devices…")
                : (scan.available
                    ? qsTr("Scan complete")
                    : qsTr("Scan failed"))

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 480

                // Busy indicator while scanning.
                Row {
                    spacing: Theme.space3
                    visible: scanning
                    width: parent.width

                    OrionBusy {
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: qsTr("Reading PCI devices via lspci (orion-hardware-scan)…")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Error state.
                Text {
                    visible: !scanning && !scan.available
                    text: qsTr("Error: %1").arg(scan.error || qsTr("Unknown"))
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 12
                    color: Theme.warning
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                // Results list.
                ListView {
                    width: parent.width
                    height: Math.max(80, contentHeight)
                    visible: !scanning && scan.available
                    clip: true
                    model: {
                        var out = [];
                        var gpus = scan.nvidia_gpus || [];
                        for (var i = 0; i < gpus.length; ++i) {
                            out.push({
                                title: qsTr("NVIDIA GPU"),
                                subtitle: gpus[i].description || "",
                                accessory: qsTr("Driver: nvidia-dkms")
                            });
                        }
                        var wlans = scan.broadcom_wifi || [];
                        for (var j = 0; j < wlans.length; ++j) {
                            out.push({
                                title: qsTr("Broadcom Wi-Fi"),
                                subtitle: wlans[j].description || "",
                                accessory: qsTr("Driver: broadcom-wl-dkms")
                            });
                        }
                        return out;
                    }
                    delegate: OrionListRow {
                        width: ListView.view.width
                        iconSource: "video-display"
                        title: modelData.title
                        subtitle: modelData.subtitle
                        accessoryText: modelData.accessory
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: parent.count === 0
                        text: qsTr("No out-of-tree drivers needed. Your hardware works with "
                                  + "the preinstalled open-source drivers.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.success
                        width: parent.width
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // Kernel + suggested packages.
                Text {
                    visible: !scanning && scan.available
                    text: qsTr("Kernel: %1   Suggested packages: %2")
                            .arg(scan.kernel || qsTr("(unknown)"))
                            .arg((scan.suggested_packages || []).join(", ")
                                 || qsTr("(none)"))
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 12
                    color: Theme.fgTertiary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        // Action button — opens Software Center to install the suggested
        // packages. Visible only when at least one suggestion exists.
        Row {
            Layout.fillWidth: true
            spacing: Theme.space3
            visible: !scanning && scan.available
                    && (scan.suggested_packages || []).length > 0

            OrionButton {
                text: qsTr("Open Software Center")
                variant: OrionButton.Variant.Primary
                size: OrionButton.Size.Default
                onClicked: welcomeController.openSoftwareCenter()
            }

            Text {
                text: qsTr("Install the suggested packages to enable full hardware support. "
                          + "The Software Center will prompt for polkit authorization.")
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.fgTertiary
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 200
                wrapMode: Text.WordWrap
            }
        }

        // Re-scan button.
        OrionButton {
            text: qsTr("Re-scan")
            variant: OrionButton.Variant.Ghost
            size: OrionButton.Size.Compact
            onClicked: step.runScan()
        }

        Item { Layout.fillHeight: true; Layout.preferredHeight: Theme.space2 }
    }
}
