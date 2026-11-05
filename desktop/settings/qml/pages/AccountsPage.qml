// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/pages/AccountsPage.qml — Accounts settings.
//
// Sections:
//   * Current user info (read-only) + avatar upload
//   * Password change dialog
//   * Login preferences (auto-login toggle, account type)
//   * User management for admins — list + create + delete

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import org.orion.framework

Flickable {
    id: page
    anchors.fill: parent
    contentWidth: width
    contentHeight: column.implicitHeight + 2 * Theme.space5
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

    readonly property var me: controller.currentUser

    ColumnLayout {
        id: column
        width: page.width - 2 * Theme.space5
        x: Theme.space5
        y: Theme.space5
        spacing: Theme.space5

        // ---- Current user card ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Your account")
            subtitle: qsTr("Profile picture, name, and password")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space4
                    width: parent.width

                    // Avatar.
                    Rectangle {
                        id: avatar
                        width: 96
                        height: 96
                        radius: width / 2
                        color: Theme.surface3
                        border.width: 2
                        border.color: Theme.accent500
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: me.iconFile && me.iconFile.length > 0
                                ? me.iconFile
                                : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            visible: status === Image.Ready
                        }
                        // Fallback initial.
                        Text {
                            anchors.centerIn: parent
                            visible: !avatar.visible || avatar.children[1].status !== Image.Ready
                            text: me.userName ? me.userName.charAt(0).toUpperCase() : "?"
                            font.family: Theme.fontFamily
                            font.pixelSize: 36
                            font.weight: Font.DemiBold
                            color: Theme.fgInverse
                        }
                    }

                    Column {
                        spacing: Theme.space2
                        anchors.verticalCenter: avatar.verticalCenter

                        Text {
                            text: me.formattedRealName || me.realName || me.userName
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                            font.weight: Font.DemiBold
                            color: Theme.fgPrimary
                        }
                        Text {
                            text: "@" + (me.userName || "")
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 13
                            color: Theme.fgSecondary
                        }
                        Text {
                            text: me.isAdmin ? qsTr("Administrator") : qsTr("Standard user")
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: me.isAdmin ? Theme.accent500 : Theme.fgTertiary
                        }

                        Row {
                            spacing: Theme.space2
                            OrionButton {
                                text: qsTr("Change picture…")
                                variant: OrionButton.Variant.Secondary
                                size: OrionButton.Size.Compact
                                onClicked: avatarDialog.open()
                            }
                            OrionButton {
                                text: qsTr("Change password…")
                                variant: OrionButton.Variant.Secondary
                                size: OrionButton.Size.Compact
                                onClicked: passwordDialog.open()
                            }
                        }
                    }
                }

                // Profile details.
                GridLayout {
                    columns: 2
                    columnSpacing: Theme.space4
                    rowSpacing: Theme.space2
                    width: parent.width

                    Text {
                        text: qsTr("User ID (UID)")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                    }
                    Text {
                        text: me.uid !== undefined ? me.uid.toString() : "—"
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: 12
                        color: Theme.fgPrimary
                    }
                    Text {
                        text: qsTr("Home directory")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                    }
                    Text {
                        text: me.homeDir || "—"
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: 12
                        color: Theme.fgPrimary
                    }
                    Text {
                        text: qsTr("Shell")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                    }
                    Text {
                        text: me.shell || "—"
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: 12
                        color: Theme.fgPrimary
                    }
                }
            }
        }

        // ---- Login preferences ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Login preferences")
            subtitle: qsTr("Automatic login and account type")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Automatic login")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionSwitch {
                        checked: me.automaticLogin
                        onToggled: controller.setAutoLogin(me.uid, checked)
                    }
                }
                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Account type")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionComboBox {
                        model: [qsTr("Standard"), qsTr("Administrator")]
                        currentIndex: me.accountType === 1 ? 1 : 0
                        enabled: controller.isCurrentUserAdmin
                        onActivated: controller.setUserType(me.uid, currentIndex)
                    }
                    Text {
                        text: controller.isCurrentUserAdmin
                            ? qsTr("(admin only)")
                            : qsTr("(admins only)")
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.fgTertiary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // ---- User management (admin only) ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Other users")
            subtitle: controller.isCurrentUserAdmin
                ? qsTr("Create, delete, and manage local accounts")
                : qsTr("Only administrators can manage other users")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                ListView {
                    width: parent.width
                    height: Math.max(120, contentHeight)
                    clip: true
                    model: controller.users
                    delegate: OrionListRow {
                        width: ListView.view.width
                        iconSource: "user-identity"
                        title: modelData.realName || modelData.userName
                        subtitle: "@" + modelData.userName + " · UID " + modelData.uid
                        accessoryText: modelData.accountType === 1 ? qsTr("Admin") : qsTr("Standard")
                        onClicked: {
                            if (controller.isCurrentUserAdmin) {
                                page.selectedUid = modelData.uid;
                                page.selectedName = modelData.userName;
                                deleteDialog.open();
                            }
                        }
                    }
                }

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    visible: controller.isCurrentUserAdmin
                    OrionButton {
                        text: qsTr("Add user…")
                        variant: OrionButton.Variant.Primary
                        size: OrionButton.Size.Compact
                        onClicked: createUserDialog.open()
                    }
                }
            }
        }

        Item { Layout.fillHeight: true; height: Theme.space2 }
    }

    property int selectedUid: -1
    property string selectedName: ""

    // ---- Avatar picker ----
    FileDialog {
        id: avatarDialog
        title: qsTr("Choose a profile picture")
        nameFilters: [qsTr("Images (*.png *.jpg *.jpeg)")]
        onAccepted: controller.setAvatar(currentFile.toString())
    }

    // ---- Password change dialog ----
    OrionDialog {
        id: passwordDialog
        titleText: qsTr("Change password")
        contentItem: Column {
            spacing: Theme.space3
            width: parent ? parent.width - 2 * Theme.space5 : 400
            OrionTextField { id: pwOld; width: parent.width; echoMode: TextInput.Password;
                             placeholderText: qsTr("Current password") }
            OrionTextField { id: pwNew; width: parent.width; echoMode: TextInput.Password;
                             placeholderText: qsTr("New password (≥ 6 chars)") }
            OrionTextField { id: pwConfirm; width: parent.width; echoMode: TextInput.Password;
                             placeholderText: qsTr("Confirm new password") }
        }
        actions: [
            { text: qsTr("Cancel"), role: "secondary", onClicked: function(){} },
            { text: qsTr("Change"), role: "primary", onClicked: function(){
                if (pwNew.text !== pwConfirm.text) {
                    // QML can't emit C++ signals directly; surface via
                    // a controller method that takes care of the error.
                    // changePassword() itself validates and emits errorOccurred
                    // if the new password is too short. We additionally guard
                    // the mismatch case here by clearing and returning.
                    pwOld.text = ""; pwNew.text = ""; pwConfirm.text = "";
                    return;
                }
                controller.changePassword(pwOld.text, pwNew.text);
                pwOld.text = ""; pwNew.text = ""; pwConfirm.text = "";
            } }
        ]
    }

    // ---- Create user dialog ----
    OrionDialog {
        id: createUserDialog
        titleText: qsTr("Create user")
        contentItem: Column {
            spacing: Theme.space3
            width: parent ? parent.width - 2 * Theme.space5 : 420
            OrionTextField {
                id: cuUserName
                width: parent.width
                label: qsTr("Username")
                placeholderText: qsTr("lowercase, letters/digits, starts with letter")
            }
            OrionTextField {
                id: cuRealName
                width: parent.width
                label: qsTr("Full name")
            }
            OrionComboBox {
                id: cuAccountType
                width: parent.width
                model: [qsTr("Standard user"), qsTr("Administrator")]
            }
            OrionTextField {
                id: cuPassword
                width: parent.width
                label: qsTr("Initial password")
                echoMode: TextInput.Password
            }
        }
        actions: [
            { text: qsTr("Cancel"), role: "secondary", onClicked: function(){} },
            { text: qsTr("Create"), role: "primary", onClicked: function(){
                controller.createUser(cuUserName.text, cuRealName.text,
                                      cuAccountType.currentIndex, cuPassword.text);
                cuUserName.text = ""; cuRealName.text = "";
                cuPassword.text = ""; cuAccountType.currentIndex = 0;
            } }
        ]
    }

    // ---- Delete user dialog ----
    OrionDialog {
        id: deleteDialog
        titleText: qsTr("Delete user?")
        contentItem: Column {
            spacing: Theme.space3
            width: parent ? parent.width - 2 * Theme.space5 : 400
            Text {
                text: qsTr("You are about to delete user “%1” (UID %2).").arg(
                    page.selectedName).arg(page.selectedUid)
                font.family: Theme.fontFamily
                font.pixelSize: 14
                color: Theme.fgSecondary
                wrapMode: Text.WordWrap
                width: parent.width
            }
            Text {
                text: qsTr("Type the username to confirm:")
                font.family: Theme.fontFamily
                font.pixelSize: 13
                color: Theme.fgTertiary
            }
            TextField {
                id: deleteConfirmInput
                width: parent.width
                font.family: Theme.fontFamilyMono
                background: Rectangle {
                    color: Theme.surface1
                    border.width: 1
                    border.color: deleteConfirmInput.activeFocus
                        ? Theme.accent500 : Theme.borderDefault
                    radius: Theme.radiusMd
                }
            }
            OrionSwitch {
                id: deleteRemoveFiles
                label: qsTr("Also delete the user's home directory")
            }
        }
        actions: [
            { text: qsTr("Cancel"), role: "secondary", onClicked: function(){} },
            { text: qsTr("Delete user"), role: "primary", onClicked: function(){
                if (deleteConfirmInput.text === page.selectedName) {
                    controller.applyConfirmedDeleteUser(page.selectedUid,
                                                         deleteRemoveFiles.checked);
                }
                deleteConfirmInput.text = "";
                deleteRemoveFiles.checked = false;
            } }
        ]
    }
}
