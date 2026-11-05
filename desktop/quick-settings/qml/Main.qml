// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import org.orion.framework
import org.orion.quicksettings

ApplicationWindow {
    id: window
    width: 360; height: 480
    flags: Qt.FramelessWindowHint | Qt.Popup | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: false

    Rectangle {
        anchors.fill: parent
        color: Theme.surface1
        radius: Theme.radiusXl
        border.width: 1
        border.color: Theme.borderSubtle
        opacity: Theme.reduceTransparency ? 1.0 : 0.96

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.space4
            spacing: Theme.space3

            // Quick toggles grid (2 columns)
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: Theme.space2
                columnSpacing: Theme.space2

                QuickToggle {
                    Layout.fillWidth: true
                    text: qsTr("Wi-Fi")
                    icon: quick.wifiOn ? "icon-wifi-on" : "icon-wifi-off"
                    checked: quick.wifiOn
                    onToggled: quick.toggleWifi()
                }
                QuickToggle {
                    Layout.fillWidth: true
                    text: qsTr("Bluetooth")
                    icon: quick.bluetoothOn ? "icon-bt-on" : "icon-bt-off"
                    checked: quick.bluetoothOn
                    onToggled: quick.toggleBluetooth()
                }
                QuickToggle {
                    Layout.fillWidth: true
                    text: qsTr("Airplane")
                    icon: "icon-airplane"
                    checked: quick.airplaneMode
                    onToggled: quick.toggleAirplaneMode()
                }
                QuickToggle {
                    Layout.fillWidth: true
                    text: qsTr("Night Light")
                    icon: "icon-night-light"
                    checked: false
                    onToggled: {}
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.borderSubtle
            }

            // Audio slider
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.space3
                OrionIcon {
                    source: quick.muted ? "icon-audio-muted" : "icon-audio-on"
                    size: 18
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: quick.muted = !quick.muted
                    }
                }
                Slider {
                    Layout.fillWidth: true
                    from: 0; to: 100; value: quick.volume
                    onMoved: quick.volume = int(value)
                }
                Text {
                    text: quick.volume + "%"
                    font.family: Theme.fontFamilyMono; font.pixelSize: 12
                    color: Theme.fgSecondary
                    Layout.preferredWidth: 36
                }
            }

            // Brightness slider (placeholder; real impl queries /sys/class/backlight)
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.space3
                OrionIcon { source: "icon-brightness"; size: 18 }
                Slider {
                    Layout.fillWidth: true
                    from: 0; to: 100; value: 75
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.borderSubtle
            }

            // Power profile selector
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.space2
                Repeater {
                    model: [
                        { id: "power-saver", label: qsTr("Saver") },
                        { id: "balanced",    label: qsTr("Balanced") },
                        { id: "performance", label: qsTr("Perf") }
                    ]
                    OrionButton {
                        text: modelData.label
                        variant: OrionButton.Variant.Secondary
                        Layout.fillWidth: true
                        checked: quick.powerProfile === modelData.id
                        checkable: true
                        onClicked: quick.powerProfile = modelData.id
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Theme.borderSubtle
            }

            // Battery + power buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.space2

                OrionIcon { source: quick.onBattery ? "icon-battery" : "icon-plug"; size: 18 }
                Text {
                    text: quick.batteryPercent + "%"
                    font.family: Theme.fontFamilyMono; font.pixelSize: 13
                    color: Theme.fgSecondary
                }
                Item { Layout.fillWidth: true }

                // Settings button
                Rectangle {
                    width: 32; height: 32; radius: Theme.radiusMd
                    color: parent.hovered ? Theme.surface3 : "transparent"
                    OrionIcon { anchors.centerIn: parent; source: "icon-settings"; size: 18 }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally("orion-settings://")
                    }
                }
                // Power button
                Rectangle {
                    width: 32; height: 32; radius: Theme.radiusMd
                    color: parent.hovered ? Theme.surface3 : "transparent"
                    OrionIcon { anchors.centerIn: parent; source: "icon-power"; size: 18 }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: powerMenu.popup()
                    }
                    Menu {
                        id: powerMenu
                        MenuItem { text: qsTr("Lock");  onTriggered: {} }
                        MenuItem { text: qsTr("Restart"); onTriggered: {} }
                        MenuItem { text: qsTr("Shut down"); onTriggered: {} }
                    }
                }
            }
        }
    }
}
