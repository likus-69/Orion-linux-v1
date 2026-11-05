// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/Sidebar.qml — left navigation panel listing the 7 settings categories.
//
// Uses OrionListRow for each entry. Highlights the active category and
// emits `categorySelected(categoryId)` on click.

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    id: sidebar

    property string currentCategory: "personalization"
    signal categorySelected(string category)

    // The 7 categories. Each row maps to a page file under qml/pages/.
    ListModel {
        id: categories
        ListElement {
            categoryId: "personalization"
            title: QT_TR_NOOP("Personalization")
            subtitle: QT_TR_NOOP("Wallpaper, themes, accent, fonts")
            icon: "preferences-desktop-wallpaper"
        }
        ListElement {
            categoryId: "system"
            title: QT_TR_NOOP("System")
            subtitle: QT_TR_NOOP("About, display, sound, power, storage")
            icon: "preferences-system"
        }
        ListElement {
            categoryId: "devices"
            title: QT_TR_NOOP("Devices")
            subtitle: QT_TR_NOOP("Keyboard, mouse, Bluetooth, printers")
            icon: "input-keyboard"
        }
        ListElement {
            categoryId: "network"
            title: QT_TR_NOOP("Network")
            subtitle: QT_TR_NOOP("Wi-Fi, Ethernet, VPN, proxy")
            icon: "network-wireless"
        }
        ListElement {
            categoryId: "accounts"
            title: QT_TR_NOOP("Accounts")
            subtitle: QT_TR_NOOP("User info, avatar, password, users")
            icon: "user-identity"
        }
        ListElement {
            categoryId: "privacy"
            title: QT_TR_NOOP("Privacy & Security")
            subtitle: QT_TR_NOOP("Firewall, encryption, telemetry")
            icon: "preferences-system-privacy"
        }
        ListElement {
            categoryId: "applications"
            title: QT_TR_NOOP("Applications")
            subtitle: QT_TR_NOOP("Installed, defaults, startup, repos")
            icon: "preferences-desktop-apps"
        }
    }

    // Look up the display title for a given category id.
    function categoryTitle(catId) {
        for (var i = 0; i < categories.count; ++i) {
            var e = categories.get(i);
            if (e.categoryId === catId) return qsTr(e.title);
        }
        return qsTr("Settings");
    }
    // Convert category id → page class name (e.g. "personalization" →
    // "Personalization"). The Loader uses this to construct the path.
    function categoryClassName(catId) {
        if (catId === "privacy") return "Privacy";
        return catId.charAt(0).toUpperCase() + catId.slice(1);
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surface1

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 1
            color: Theme.borderSubtle
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: Theme.space3
            spacing: 0

            // Branding header.
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.space4
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.space2

                    Rectangle {
                        width: 28
                        height: 28
                        anchors.verticalCenter: parent.verticalCenter
                        radius: Theme.radiusMd
                        color: Theme.accent500
                        Text {
                            anchors.centerIn: parent
                            text: "O"
                            font.family: Theme.fontFamily
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: Theme.fgInverse
                        }
                    }
                    Text {
                        text: qsTr("Orion Settings")
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: Theme.fgPrimary
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.borderSubtle
            }

            // Category list.
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: categories
                spacing: 0
                delegate: OrionListRow {
                    width: ListView.view.width
                    iconSource: model.icon
                    title: qsTr(model.title)
                    subtitle: qsTr(model.subtitle)
                    selected: model.categoryId === sidebar.currentCategory
                    showDivider: false
                    onClicked: sidebar.categorySelected(model.categoryId)
                }
            }
        }
    }
}
