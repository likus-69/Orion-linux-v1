// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/pages/SystemPage.qml — System settings.
//
// Sections:
//   * System info card (from /etc/os-release via hostname1, /proc/cpuinfo, /proc/meminfo)
//   * Display — scaling + resolution
//   * Sound (placeholder, links to system volume)
//   * Notifications — DND / level
//   * Power — profile picker (power-profiles-daemon)
//   * Storage — disk usage bars
//   * Default apps — links to Applications page
//   * Language and region
//   * Date and time — timezone, NTP toggle, manual offset

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

    readonly property var sys: controller.systemInfo
    readonly property var st: controller.storageInfo

    function formatBytes(b) {
        return controller.formatBytes(b);
    }

    ColumnLayout {
        id: column
        width: page.width - 2 * Theme.space5
        x: Theme.space5
        y: Theme.space5
        spacing: Theme.space5

        // ---- System info card ----
        OrionCard {
            Layout.fillWidth: true
            title: sys.osPrettyName || qsTr("Orion OS")
            subtitle: sys.osHomepage || ""

            contentItem: GridLayout {
                columns: page.width > 900 ? 2 : 1
                columnSpacing: Theme.space4
                rowSpacing: Theme.space2
                width: parent ? parent.width - 2 * Theme.space4 : 600

                InfoRow { label: qsTr("Operating system"); value: sys.osName + " " + sys.osVersion }
                InfoRow { label: qsTr("Build ID"); value: sys.osBuildId || qsTr("(unknown)") }
                InfoRow { label: qsTr("Kernel"); value: sys.kernel || qsTr("(unknown)") }
                InfoRow { label: qsTr("Architecture"); value: sys.architecture || qsTr("(unknown)") }
                InfoRow { label: qsTr("Hostname"); value: sys.hostname || qsTr("(unknown)") }
                InfoRow { label: qsTr("Chassis"); value: sys.chassis || qsTr("(unknown)") }
                InfoRow { label: qsTr("Hardware vendor"); value: sys.hardwareVendor || qsTr("(unknown)") }
                InfoRow { label: qsTr("Hardware model"); value: sys.hardwareModel || qsTr("(unknown)") }
                InfoRow {
                    label: qsTr("CPU")
                    value: sys.cpuModel + " (" + sys.cpuCores + " cores)"
                }
                InfoRow {
                    label: qsTr("Memory")
                    value: formatBytes(sys.memAvailableBytes) + " / " +
                           formatBytes(sys.memTotalBytes)
                }
            }
        }

        // ---- Display ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Display")
            subtitle: qsTr("Scaling and resolution for your primary monitor")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Scaling")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionComboBox {
                        id: scaleCombo
                        width: 140
                        model: ["50%", "75%", "100%", "125%", "150%", "175%", "200%"]
                        property var scaleMap: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
                        Component.onCompleted: {
                            var idx = scaleMap.indexOf(sys.displayScale);
                            if (idx < 0) idx = 2;
                            currentIndex = idx;
                        }
                        onActivated: controller.setDisplayScale(scaleMap[currentIndex])
                    }
                }

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Resolution")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionComboBox {
                        width: 200
                        model: sys.displayResolutions
                    }
                }
            }
        }

        // ---- Sound ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Sound")
            subtitle: qsTr("Output volume and device selection")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Master volume")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionSlider {
                        width: 320
                        from: 0
                        to: 100
                        value: 60
                    }
                    Text {
                        text: "60%"
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Text {
                    text: qsTr("Per-app volume and input device selection are handled by the audio mixer in the system tray.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.fgTertiary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        // ---- Notifications ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Notifications")
            subtitle: qsTr("How and when Orion shows alerts")

            contentItem: Row {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Text {
                    text: qsTr("Level")
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.fgSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }
                OrionComboBox {
                    width: 200
                    model: [qsTr("Do not disturb"), qsTr("Normal"), qsTr("Critical only")]
                    property var idMap: ["do-not-disturb", "normal", "critical-only"]
                    Component.onCompleted: {
                        var idx = idMap.indexOf(sys.notificationLevel);
                        if (idx < 0) idx = 1;
                        currentIndex = idx;
                    }
                    onActivated: controller.setNotificationLevel(idMap[currentIndex])
                }
            }
        }

        // ---- Power ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Power")
            subtitle: qsTr("Trade performance for battery life")

            contentItem: Row {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Text {
                    text: qsTr("Profile")
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.fgSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }
                OrionComboBox {
                    width: 200
                    model: [qsTr("Power saver"), qsTr("Balanced"), qsTr("Performance")]
                    property var idMap: ["power-saver", "balanced", "performance"]
                    Component.onCompleted: {
                        var idx = idMap.indexOf(sys.powerProfile);
                        if (idx < 0) idx = 1;
                        currentIndex = idx;
                    }
                    onActivated: controller.setPowerProfile(idMap[currentIndex])
                }
            }
        }

        // ---- Storage ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Storage")
            subtitle: qsTr("Mounted filesystems and free space")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Repeater {
                    model: st.mounts
                    Column {
                        width: parent.width
                        spacing: Theme.space1

                        Row {
                            width: parent.width
                            Text {
                                text: modelData.rootPath + "  (" + modelData.fileSystemType + ")"
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: Theme.fgPrimary
                                width: parent.width * 0.6
                            }
                            Text {
                                text: formatBytes(modelData.bytesUsed) + " / " +
                                      formatBytes(modelData.bytesTotal)
                                font.family: Theme.fontFamilyMono
                                font.pixelSize: 12
                                color: Theme.fgSecondary
                                horizontalAlignment: Text.AlignRight
                                width: parent.width * 0.4
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 8
                            radius: 4
                            color: Theme.surface4
                            Rectangle {
                                width: parent.width * (
                                    modelData.bytesTotal > 0
                                        ? modelData.bytesUsed / modelData.bytesTotal
                                        : 0)
                                height: parent.height
                                radius: parent.radius
                                color: {
                                    var pct = modelData.bytesUsed / Math.max(1, modelData.bytesTotal);
                                    if (pct > 0.9) return Theme.danger;
                                    if (pct > 0.75) return Theme.warning;
                                    return Theme.accent500;
                                }
                                Behavior on color {
                                    ColorAnimation { duration: Theme.motionDefault }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ---- Language and region ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Language and region")
            subtitle: qsTr("System locale, language, and formats")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Locale")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionTextField {
                        id: localeInput
                        width: 280
                        text: sys.locale || ""
                        hint: qsTr("e.g. en_US.UTF-8")
                    }
                    OrionButton {
                        text: qsTr("Apply")
                        variant: OrionButton.Variant.Primary
                        size: OrionButton.Size.Compact
                        anchors.verticalCenter: parent.verticalCenter
                        enabled: localeInput.text.length > 0 && localeInput.text.contains(".")
                        onClicked: controller.setLocale(localeInput.text)
                    }
                }
                Text {
                    text: qsTr("Changing the locale requires authorization (polkit). "
                              + "You will be asked to retype the value to confirm.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.fgTertiary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        // ---- Date and time ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Date and time")
            subtitle: qsTr("Timezone and automatic network time")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Timezone")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionComboBox {
                        id: tzCombo
                        width: 280
                        editable: true
                        model: controller.availableTimezones()
                        Component.onCompleted: {
                            var idx = find(sys.timezone);
                            currentIndex = idx >= 0 ? idx : 0;
                            editText = sys.timezone || "";
                        }
                        onAccepted: {
                            controller.setTimezone(currentText);
                        }
                    }
                    OrionButton {
                        text: qsTr("Apply")
                        size: OrionButton.Size.Compact
                        variant: OrionButton.Variant.Primary
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: controller.setTimezone(tzCombo.currentText)
                    }
                }

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Automatic network time (NTP)")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionSwitch {
                        checked: sys.ntpActive
                        onToggled: controller.setNtpEnabled(checked)
                    }
                }

                // Hostname card (system rename requires polkit + typed confirmation)
                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Hostname")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionTextField {
                        id: hostnameInput
                        width: 200
                        text: sys.hostname || ""
                        hint: qsTr("letters, digits, dots, hyphens")
                    }
                    OrionButton {
                        text: qsTr("Change")
                        variant: OrionButton.Variant.Secondary
                        size: OrionButton.Size.Compact
                        anchors.verticalCenter: parent.verticalCenter
                        enabled: hostnameInput.text.length > 0 &&
                                 hostnameInput.text !== sys.hostname
                        onClicked: controller.setHostname(hostnameInput.text)
                    }
                }
                Text {
                    text: qsTr("You will be asked to retype the new hostname to confirm.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.fgTertiary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        Item { Layout.fillHeight: true; height: Theme.space2 }
    }

    // ---- Small info-row component ----
    component InfoRow: Row {
        property string label: ""
        property string value: ""
        spacing: Theme.space3
        width: parent ? parent.width : 200
        Layout.fillWidth: true

        Text {
            text: parent.label
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: Theme.fgTertiary
            width: 160
        }
        Text {
            text: parent.value
            font.family: Theme.fontFamilyMono
            font.pixelSize: 12
            color: Theme.fgPrimary
            elide: Text.ElideRight
            width: parent.width - 160
        }
    }
}
