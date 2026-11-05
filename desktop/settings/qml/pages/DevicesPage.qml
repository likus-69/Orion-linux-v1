// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/pages/DevicesPage.qml — Devices settings.
//
// Sections:
//   * Keyboard — layout selector (localectl list-keymaps)
//   * Mouse / touchpad — sensitivity, tap-to-click, natural scroll
//   * Bluetooth — pair/forget (org.bluez)
//   * Printers — list, enable cups.service on demand, add new printer
//   * Cameras — list V4L2 devices

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

    readonly property var kb: controller.keyboardInfo()

    ColumnLayout {
        id: column
        width: page.width - 2 * Theme.space5
        x: Theme.space5
        y: Theme.space5
        spacing: Theme.space5

        // ---- Keyboard ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Keyboard")
            subtitle: qsTr("Layout and input method")

            contentItem: Row {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Text {
                    text: qsTr("Layout")
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.fgSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }
                OrionComboBox {
                    id: kbCombo
                    width: 220
                    editable: true
                    model: kb.availableLayouts
                    Component.onCompleted: {
                        editText = kb.layout
                    }
                    onAccepted: controller.setKeyboardLayout(currentText)
                }
                OrionButton {
                    text: qsTr("Apply")
                    variant: OrionButton.Variant.Primary
                    size: OrionButton.Size.Compact
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: controller.setKeyboardLayout(kbCombo.currentText)
                }
            }
        }

        // ---- Mouse / touchpad ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Mouse and touchpad")
            subtitle: qsTr("Pointer speed, taps, and scroll direction")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Sensitivity")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionSlider {
                        id: sensSlider
                        width: 280
                        from: 0
                        to: 3
                        stepSize: 1
                        value: kb.mouseSensitivity
                        onMoved: controller.setMouseSensitivity(Math.round(value))
                    }
                    Text {
                        text: {
                            var v = Math.round(sensSlider.value);
                            return [qsTr("Slow"), qsTr("Medium-slow"),
                                    qsTr("Medium"), qsTr("Fast")][v];
                        }
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Tap to click")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionSwitch {
                        checked: kb.tapToClick
                        onToggled: controller.setTapToClick(checked)
                    }
                }

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Natural scrolling")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionSwitch {
                        checked: kb.naturalScroll
                        onToggled: controller.setNaturalScroll(checked)
                    }
                }
            }
        }

        // ---- Bluetooth ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Bluetooth")
            subtitle: qsTr("Paired devices (org.bluez)")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                ListView {
                    width: parent.width
                    height: Math.max(80, contentHeight)
                    clip: true
                    model: controller.bluetoothDevices()
                    delegate: OrionListRow {
                        width: ListView.view.width
                        iconSource: "bluetooth"
                        title: modelData.name || modelData.address
                        subtitle: modelData.address
                        accessoryText: modelData.connected ? qsTr("Connected") : qsTr("Paired")
                        onClicked: controller.forgetBluetooth(modelData.address)
                    }
                    // Empty state.
                    Text {
                        anchors.centerIn: parent
                        visible: parent.count === 0
                        text: qsTr("No Bluetooth devices discovered. Pair from your device's Bluetooth menu.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                    }
                }
                Text {
                    text: qsTr("Use the Orion Quick Settings panel to scan for new devices. "
                              + "Pairing requires authentication (polkit).")
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.fgTertiary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        // ---- Printers ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Printers")
            subtitle: qsTr("CUPS queues and queue management")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("CUPS service")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionButton {
                        text: qsTr("Enable CUPS")
                        variant: OrionButton.Variant.Primary
                        size: OrionButton.Size.Compact
                        onClicked: controller.enableCups()
                    }
                    Text {
                        text: qsTr("Starts cups.service via systemd (polkit prompt).")
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.fgTertiary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                ListView {
                    width: parent.width
                    height: Math.max(60, contentHeight)
                    clip: true
                    model: controller.printers()
                    delegate: OrionListRow {
                        width: ListView.view.width
                        iconSource: "printer"
                        title: modelData.name
                        subtitle: qsTr("Printer queue")
                        accessoryText: modelData.isDefault ? qsTr("Default") : ""
                        onClicked: { /* select default — v1.1 */ }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: parent.count === 0
                        text: qsTr("No printers configured. Use CUPS web UI at http://localhost:631 to add one.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                    }
                }

                // Add-printer mini-form.
                Row {
                    spacing: Theme.space3
                    width: parent.width
                    OrionTextField {
                        id: printerName
                        width: 140
                        placeholderText: qsTr("Queue name")
                    }
                    OrionTextField {
                        id: printerUri
                        width: 240
                        placeholderText: qsTr("Device URI (e.g. socket://192.168.1.5)")
                    }
                    OrionButton {
                        text: qsTr("Add printer")
                        variant: OrionButton.Variant.Secondary
                        size: OrionButton.Size.Compact
                        anchors.verticalCenter: parent.verticalCenter
                        enabled: printerName.text.length > 0 && printerUri.text.length > 0
                        onClicked: controller.addPrinter(printerUri.text, printerName.text)
                    }
                }
            }
        }

        // ---- Cameras ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Cameras")
            subtitle: qsTr("V4L2 video devices detected on this system")

            contentItem: ListView {
                width: parent ? parent.width - 2 * Theme.space4 : 600
                height: Math.max(80, contentHeight)
                clip: true
                model: controller.cameras()
                delegate: OrionListRow {
                    width: ListView.view.width
                    iconSource: "camera-web"
                    title: modelData.device
                    subtitle: qsTr("Video device")
                }
                Text {
                    anchors.centerIn: parent
                    visible: parent.count === 0
                    text: qsTr("No cameras detected.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    color: Theme.fgTertiary
                }
            }
        }

        Item { Layout.fillHeight: true; height: Theme.space2 }
    }
}
