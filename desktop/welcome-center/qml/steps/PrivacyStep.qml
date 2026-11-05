// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        Text {
            text: qsTr("Privacy and security")
            font.family: Theme.fontFamily
            font.pixelSize: 22
            font.weight: Font.DemiBold
            color: Theme.fgPrimary
        }
        Text {
            text: qsTr("Orion OS does not collect telemetry by default. Your data stays yours.")
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.fgSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Anonymous usage statistics")
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.space3
                spacing: Theme.space2

                Text {
                    text: qsTr("<b>Off by default.</b> If you enable it, Orion sends:\n"
                              + "• Orion OS version and architecture\n"
                              + "• Kernel version\n"
                              + "• Whether your hardware boots via UEFI\n"
                              + "<br>Orion does NOT send:\n"
                              + "• Your username, hostname, or IP address\n"
                              + "• Personal files, settings, or installed-app list\n"
                              + "• Hardware serial numbers or MAC addresses")
                    textFormat: Text.RichText
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.fgSecondary
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: qsTr("Enable anonymous usage statistics")
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        color: Theme.fgPrimary
                        Layout.fillWidth: true
                    }
                    Switch { checked: false }  // OFF by default
                }
            }
        }

        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Firewall")
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.space3
                spacing: Theme.space2
                Text {
                    text: qsTr("No inbound network listeners are enabled by default. The firewall is informational on a default install.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.fgSecondary
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }
    }
}
