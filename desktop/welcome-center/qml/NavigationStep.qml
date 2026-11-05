// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/NavigationStep.qml — Step 1.
//
// Three panels explaining the taskbar, start menu, and quick settings.
// Each panel is an OrionCard with a small mock illustration and a short
// description. The step is read-only; the footer advances.

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
            text: qsTr("Find your way around")
            Layout.alignment: Qt.AlignLeft
        }
        OrionLabel {
            role: OrionLabel.Role.Body
            tint: Theme.fgSecondary
            text: qsTr("Three things you'll use every day: the taskbar at the bottom of the screen, "
                      + "the Start menu for launching apps, and Quick Settings for Wi-Fi, sound, and "
                      + "power.")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // Three panels in a row (or stacked on narrow widths).
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: step.width > 720 ? 3 : 1
            columnSpacing: Theme.space4
            rowSpacing: Theme.space4

            // ---- Panel 1: Taskbar ----
            OrionCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Taskbar")
                subtitle: qsTr("Bottom of the screen")

                contentItem: Column {
                    spacing: Theme.space3
                    width: parent ? parent.width - 2 * Theme.space4 : 200

                    // Mock taskbar.
                    Rectangle {
                        width: parent.width
                        height: 36
                        radius: Theme.radiusSm
                        color: Theme.surface3
                        border.width: 1
                        border.color: Theme.borderSubtle

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.space2
                            anchors.rightMargin: Theme.space2
                            spacing: Theme.space2

                            // Mock pinned-app icons.
                            Repeater {
                                model: 4
                                Rectangle {
                                    width: 28; height: 28
                                    anchors.verticalCenter: parent.verticalCenter
                                    radius: Theme.radiusSm
                                    color: index === 0 ? Theme.accent500.withAlphaF(0.2)
                                                       : Theme.surface2
                                    border.width: index === 0 ? 1 : 0
                                    border.color: Theme.accent500
                                }
                            }
                            Item { width: 1; height: 1; Layout.fillWidth: true }
                            // Mock system tray.
                            Rectangle {
                                width: 60; height: 18
                                anchors.verticalCenter: parent.verticalCenter
                                radius: Theme.radiusSm
                                color: Theme.surface2
                            }
                        }
                    }

                    Text {
                        text: qsTr("Pinned apps on the left, system tray (network, sound, "
                                  + "battery, clock) on the right. Hover an app to see its "
                                  + "name; click to launch or focus it.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgSecondary
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            // ---- Panel 2: Start menu ----
            OrionCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Start menu")
                subtitle: qsTr("Launch apps and search")

                contentItem: Column {
                    spacing: Theme.space3
                    width: parent ? parent.width - 2 * Theme.space4 : 200

                    // Mock start menu.
                    Rectangle {
                        width: parent.width
                        height: 64
                        radius: Theme.radiusMd
                        color: Theme.surface3
                        border.width: 1
                        border.color: Theme.borderSubtle

                        Column {
                            anchors.fill: parent
                            anchors.margins: Theme.space2
                            spacing: Theme.space1

                            // Search bar.
                            Rectangle {
                                width: parent.width
                                height: 18
                                radius: Theme.radiusSm
                                color: Theme.surface1
                                border.width: 1
                                border.color: Theme.borderDefault
                            }
                            // App icon grid mock.
                            Row {
                                spacing: Theme.space2
                                Repeater {
                                    model: 5
                                    Rectangle {
                                        width: 16; height: 16
                                        radius: Theme.radiusSm
                                        color: Theme.accent500.withAlphaF(0.4 + index * 0.1)
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        text: qsTr("Click the Orion logo at the left of the taskbar (or press "
                                  + "the Super key) to open the Start menu. Search by typing; "
                                  + "pin favorites for quick access.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgSecondary
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            // ---- Panel 3: Quick settings ----
            OrionCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Quick Settings")
                subtitle: qsTr("Wi-Fi, sound, power")

                contentItem: Column {
                    spacing: Theme.space3
                    width: parent ? parent.width - 2 * Theme.space4 : 200

                    // Mock quick settings popover.
                    Rectangle {
                        width: parent.width
                        height: 64
                        radius: Theme.radiusMd
                        color: Theme.surface3
                        border.width: 1
                        border.color: Theme.borderSubtle

                        GridLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.space2
                            columns: 3
                            rowSpacing: Theme.space1
                            columnSpacing: Theme.space1

                            Repeater {
                                model: 6
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: Theme.radiusSm
                                    color: index % 2 === 0 ? Theme.accent500.withAlphaF(0.3)
                                                           : Theme.surface2
                                    border.width: 1
                                    border.color: index % 2 === 0 ? Theme.accent500
                                                                  : Theme.borderSubtle
                                }
                            }
                        }
                    }

                    Text {
                        text: qsTr("Click the system-tray cluster (network + sound + battery) "
                                  + "to open Quick Settings. Toggle Wi-Fi and Bluetooth, adjust "
                                  + "volume, switch power profiles, and log out / shut down — "
                                  + "all from one panel.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgSecondary
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }
        }

        Item { Layout.fillHeight: true; Layout.preferredHeight: Theme.space2 }
    }
}
