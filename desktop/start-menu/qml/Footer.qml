// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    implicitHeight: 40
    implicitWidth: parent ? parent.width : 600

    Rectangle {
        anchors.fill: parent
        color: Theme.surface2
        radius: Theme.radiusMd

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.space2
            spacing: Theme.space3

            // User avatar
            Rectangle {
                width: 32; height: 32
                radius: width / 2
                color: Theme.accent500
                Layout.alignment: Qt.AlignVCenter
                Text {
                    anchors.centerIn: parent
                    text: "O"  // First letter of username (placeholder)
                    color: Theme.fgInverse
                    font.family: Theme.fontFamily
                    font.weight: Font.DemiBold
                    font.pixelSize: 14
                }
            }

            Text {
                text: qsTr("Orion User")  // Replaced with real username at runtime
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: Theme.fgPrimary
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            // Power button
            Rectangle {
                width: 32; height: 32
                radius: width / 2
                color: powerMa.containsMouse ? Theme.surface4 : "transparent"
                Layout.alignment: Qt.AlignVCenter
                Behavior on color { ColorAnimation { duration: Theme.motionFast } }

                OrionIcon {
                    anchors.centerIn: parent
                    source: "icon-power"
                    size: 18
                }

                MouseArea {
                    id: powerMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: powerMenu.popup(parent, 0, parent.height + 4)
                }

                Menu {
                    id: powerMenu
                    MenuItem { text: qsTr("Lock");  onTriggered: powerControl.lockSession() }
                    MenuItem { text: qsTr("Log out"); onTriggered: powerControl.terminateSession() }
                    MenuSeparator {}
                    MenuItem {
                        text: qsTr("Restart")
                        onTriggered: {
                            confirmDialog.action = "restart";
                            confirmDialog.open();
                        }
                    }
                    MenuItem {
                        text: qsTr("Shut down")
                        onTriggered: {
                            confirmDialog.action = "poweroff";
                            confirmDialog.open();
                        }
                    }
                }
            }
        }
    }

    OrionDialog {
        id: confirmDialog
        property string action: ""
        titleText: action === "poweroff" ? qsTr("Shut down Orion OS?")
                                         : qsTr("Restart Orion OS?")
        modal: true
        anchors.centerIn: parent
        actions: [
            { text: qsTr("Cancel"), role: "secondary", onClicked: {} },
            { text: qsTr("Confirm"), role: "primary", onClicked: () => {
                if (action === "poweroff") powerControl.powerOff();
                else if (action === "restart") powerControl.reboot();
            }}
        ]
    }
}
