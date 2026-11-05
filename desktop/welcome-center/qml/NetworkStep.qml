// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/NetworkStep.qml — Step 3.
//
// Wi-Fi connect via NetworkManager. Lists visible SSIDs with strength
// bars; click to connect. Passwords are entered in an OrionDialog and
// passed straight to nmcli — they are NEVER stored by the welcome center.
//
// The step is optional: if Wi-Fi isn't available or the user has no
// password handy, they can hit Next / Skip and configure networking
// later in Settings → Network.

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework

Item {
    id: step
    Layout.fillWidth: true
    Layout.fillHeight: true

    property var wifiList: []

    Component.onCompleted: refresh()

    function refresh() {
        wifiList = welcomeController.wifiAccessPoints();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        OrionLabel {
            role: OrionLabel.Role.H1
            text: qsTr("Connect to Wi-Fi")
        }
        OrionLabel {
            role: OrionLabel.Role.Body
            tint: Theme.fgSecondary
            text: qsTr("Orion OS uses NetworkManager. Pick a network to connect — you'll be "
                      + "prompted for a password if needed. You can skip this and configure "
                      + "networking later in Settings.")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // ---- Wi-Fi list ----
        OrionCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            title: qsTr("Available networks")
            subtitle: qsTr("%n network(s) found", "", step.wifiList.length)

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    OrionButton {
                        text: qsTr("Rescan")
                        variant: OrionButton.Variant.Ghost
                        size: OrionButton.Size.Compact
                        onClicked: step.refresh()
                    }
                    Item { width: 16; height: 1 }
                    Text {
                        text: qsTr("Password is never stored by the welcome center.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.fgTertiary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                ListView {
                    width: parent.width
                    height: Math.min(220, contentHeight)
                    clip: true
                    model: step.wifiList
                    delegate: OrionListRow {
                        width: ListView.view.width
                        title: modelData.ssid || qsTr("(hidden network)")
                        subtitle: qsTr("Signal: %1%").arg(modelData.strength)
                        accessoryText: modelData.secure ? qsTr("Secure") : qsTr("Open")
                        onClicked: {
                            wifiConnectDialog.ssid = modelData.ssid;
                            wifiConnectDialog.password = "";
                            wifiConnectDialog.open();
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: parent.count === 0
                        text: qsTr("No networks found. Make sure Wi-Fi is enabled and click Rescan.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                        width: parent.width
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        Item { Layout.fillHeight: true; Layout.preferredHeight: Theme.space2 }
    }

    // ---- Wi-Fi password dialog ----
    OrionDialog {
        id: wifiConnectDialog
        property string ssid: ""
        property string password: ""
        titleText: qsTr("Connect to Wi-Fi")
        contentItem: Column {
            spacing: Theme.space3
            width: parent ? parent.width - 2 * Theme.space5 : 360

            Text {
                text: qsTr("Enter the password for “%1”:").arg(wifiConnectDialog.ssid)
                font.family: Theme.fontFamily
                font.pixelSize: 14
                color: Theme.fgSecondary
                wrapMode: Text.WordWrap
                width: parent.width
            }
            TextField {
                id: wifiPasswordInput
                width: parent.width
                echoMode: TextInput.Password
                placeholderText: qsTr("Password")
                font.family: Theme.fontFamilyMono
                font.pixelSize: 14
                color: Theme.fgPrimary
                selectByMouse: true
                background: Rectangle {
                    color: Theme.surface1
                    border.width: 1
                    border.color: wifiPasswordInput.activeFocus
                        ? Theme.accent500
                        : Theme.borderDefault
                    radius: Theme.radiusMd
                }
                onTextChanged: wifiConnectDialog.password = text
                Keys.onReturnPressed: wifiConnectDialog.__tryConnect()
            }
            Text {
                text: qsTr("The password is passed directly to NetworkManager and is never "
                          + "stored by the welcome center.")
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.fgTertiary
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }
        actions: [
            { text: qsTr("Cancel"), role: "secondary",
              onClicked: function(){} },
            { text: qsTr("Connect"), role: "primary",
              onClicked: function(){
                  wifiConnectDialog.__tryConnect();
              } }
        ]
        function __tryConnect() {
            welcomeController.connectToWifi(
                wifiConnectDialog.ssid, wifiConnectDialog.password);
            wifiPasswordInput.text = "";
            wifiConnectDialog.password = "";
        }
    }
}
