// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/pages/NetworkPage.qml — Network settings.
//
// Sections:
//   * Connection status (NetworkManager overall state)
//   * Wi-Fi list — SSIDs with strength bars; click to connect (password prompt)
//   * Ethernet status
//   * VPN — list + add (nmcli import) + remove
//   * Proxy — mode picker (none/manual/auto) + host/port fields

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

    readonly property var nmState: controller.networkState
    property var wifiList: []
    property var connections: []

    Component.onCompleted: {
        refreshLists();
    }
    function refreshLists() {
        wifiList = controller.wifiAccessPoints();
        connections = controller.getNetworkConnections();
    }

    ColumnLayout {
        id: column
        width: page.width - 2 * Theme.space5
        x: Theme.space5
        y: Theme.space5
        spacing: Theme.space5

        // ---- Connection status ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Connection status")
            subtitle: nmState.available ? qsTr("NetworkManager is running") : qsTr("NetworkManager unavailable")

            contentItem: Column {
                spacing: Theme.space2
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("State")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        width: 120
                    }
                    Text {
                        text: nmState.state || qsTr("unknown")
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: 13
                        color: Theme.fgPrimary
                    }
                }
                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Networking")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        width: 120
                    }
                    OrionSwitch {
                        checked: nmState.networkingEnabled
                        onToggled: { /* v1.1: toggle via NM */ }
                    }
                }
                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Wi-Fi")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        width: 120
                    }
                    OrionSwitch {
                        checked: nmState.wirelessEnabled
                        onToggled: { /* v1.1: toggle via NM */ }
                    }
                }
            }
        }

        // ---- Wi-Fi ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Wi-Fi")
            subtitle: qsTr("Available networks")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    OrionButton {
                        text: qsTr("Rescan")
                        variant: OrionButton.Variant.Ghost
                        size: OrionButton.Size.Compact
                        onClicked: page.refreshLists()
                    }
                }

                ListView {
                    width: parent.width
                    height: Math.max(120, contentHeight)
                    clip: true
                    model: page.wifiList
                    delegate: OrionListRow {
                        width: ListView.view.width
                        iconSource: modelData.secure ? "network-wireless-encrypted"
                                                       : "network-wireless"
                        title: modelData.ssid || qsTr("(hidden network)")
                        subtitle: qsTr("Signal strength: %1%").arg(modelData.strength)
                        accessoryText: modelData.secure ? qsTr("Secure") : qsTr("Open")
                        onClicked: {
                            wifiConnectDialog.ssid = modelData.ssid;
                            wifiConnectDialog.open();
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: parent.count === 0
                        text: qsTr("No networks found. Make sure Wi-Fi is enabled.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                    }
                }
            }
        }

        // ---- Ethernet ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Ethernet")
            subtitle: qsTr("Wired connections")

            contentItem: Column {
                spacing: Theme.space2
                width: parent ? parent.width - 2 * Theme.space4 : 600

                ListView {
                    width: parent.width
                    height: Math.max(60, contentHeight)
                    clip: true
                    model: {
                        var out = [];
                        var conns = page.connections;
                        for (var i = 0; i < conns.length; ++i) {
                            if (conns[i].type === "802-3-ethernet") out.push(conns[i]);
                        }
                        return out;
                    }
                    delegate: OrionListRow {
                        width: ListView.view.width
                        iconSource: "network-wired"
                        title: modelData.id
                        subtitle: qsTr("Wired connection")
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: parent.count === 0
                        text: qsTr("No wired connections configured.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                    }
                }
            }
        }

        // ---- VPN ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("VPN")
            subtitle: qsTr("Import OpenVPN / WireGuard configuration files")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                ListView {
                    width: parent.width
                    height: Math.max(60, contentHeight)
                    clip: true
                    model: {
                        var out = [];
                        var conns = page.connections;
                        for (var i = 0; i < conns.length; ++i) {
                            if (conns[i].type === "vpn" || conns[i].type === "wireguard") {
                                out.push(conns[i]);
                            }
                        }
                        return out;
                    }
                    delegate: OrionListRow {
                        width: ListView.view.width
                        iconSource: "network-vpn"
                        title: modelData.id
                        subtitle: modelData.type
                        accessoryText: qsTr("Remove")
                        onClicked: controller.removeVpn(modelData.path)
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: parent.count === 0
                        text: qsTr("No VPN connections.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                    }
                }

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    OrionTextField {
                        id: vpnPath
                        width: 280
                        placeholderText: qsTr("/path/to/config.ovpn")
                    }
                    OrionButton {
                        text: qsTr("Import")
                        variant: OrionButton.Variant.Primary
                        size: OrionButton.Size.Compact
                        anchors.verticalCenter: parent.verticalCenter
                        enabled: vpnPath.text.length > 0
                        onClicked: controller.addVpn(vpnPath.text)
                    }
                    Text {
                        text: qsTr("Uses nmcli connection import. Requires polkit.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.fgTertiary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // ---- Proxy ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Proxy")
            subtitle: qsTr("HTTP proxy for applications that honor it")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Mode")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionComboBox {
                        id: proxyMode
                        width: 160
                        model: [qsTr("None"), qsTr("Manual"), qsTr("Auto")]
                        property var idMap: ["none", "manual", "auto"]
                    }
                }
                Row {
                    spacing: Theme.space3
                    width: parent.width
                    visible: proxyMode.currentIndex === 1
                    OrionTextField {
                        id: proxyHost
                        width: 200
                        placeholderText: qsTr("Proxy host")
                    }
                    OrionTextField {
                        id: proxyPort
                        width: 80
                        placeholderText: qsTr("Port")
                        validator: IntValidator { bottom: 1; top: 65535 }
                    }
                    OrionButton {
                        text: qsTr("Apply")
                        variant: OrionButton.Variant.Primary
                        size: OrionButton.Size.Compact
                        anchors.verticalCenter: parent.verticalCenter
                        enabled: proxyHost.text.length > 0 && proxyPort.text.length > 0
                        onClicked: controller.setProxy(
                            proxyMode.idMap[proxyMode.currentIndex],
                            proxyHost.text,
                            parseInt(proxyPort.text))
                    }
                }
            }
        }

        Item { Layout.fillHeight: true; height: Theme.space2 }
    }

    // ---- Wi-Fi password dialog ----
    OrionDialog {
        id: wifiConnectDialog
        property string ssid: ""
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
                id: wifiPassword
                width: parent.width
                echoMode: TextInput.Password
                placeholderText: qsTr("Password")
                font.family: Theme.fontFamilyMono
                background: Rectangle {
                    color: Theme.surface1
                    border.width: 1
                    border.color: wifiPassword.activeFocus
                        ? Theme.accent500
                        : Theme.borderDefault
                    radius: Theme.radiusMd
                }
            }
        }
        actions: [
            { text: qsTr("Cancel"), role: "secondary",
              onClicked: function(){} },
            { text: qsTr("Connect"), role: "primary",
              onClicked: function(){
                  controller.connectToWifi(wifiConnectDialog.ssid, wifiPassword.text);
                  wifiPassword.text = "";
              } }
        ]
    }
}
