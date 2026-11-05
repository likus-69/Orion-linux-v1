// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/Main.qml — Orion Settings top-level window.
//
// Layout:
//   ┌────────────┬──────────────────────────────────────────┐
//   │ Sidebar    │  Header (page title + search)            │
//   │ (7 cats)   │  ─────────────────────────────           │
//   │            │  Loader (loads pages/<Category>Page.qml) │
//   │            │                                          │
//   │            │                                          │
//   └────────────┴──────────────────────────────────────────┘
//
// The page is loaded lazily by a Loader so only the visible category
// is instantiated — keeps startup fast and memory low.

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework

ApplicationWindow {
    id: root
    visible: true
    width: 1040
    height: 720
    minimumWidth: 880
    minimumHeight: 600
    title: qsTr("Orion Settings")
    color: Theme.surface0

    // The active category. Drives the Loader's source.
    property string currentCategory: "personalization"

    // ---- Global confirmation dialog (used for destructive ops) ----
    // The SettingsController emits `confirmationRequired(operation, target,
    // displayName)`. We catch the signal here, populate the dialog with the
    // target string, and ask the user to retype it. On accept, we call the
    // matching `applyConfirmed*` slot.
    OrionDialog {
        id: confirmDialog
        property string operation: ""
        property string target: ""
        property string displayName: ""
        property string typedValue: ""

        // Override contentItem because OrionDialog doesn't expose a
        // body slot in v1.
        contentItem: Column {
            spacing: Theme.space3
            width: parent ? parent.width - 2 * Theme.space5 : 400

            Text {
                text: confirmDialog.displayName
                font.family: Theme.fontFamily
                font.pixelSize: 14
                color: Theme.fgSecondary
                wrapMode: Text.WordWrap
                width: parent.width
            }
            Text {
                text: qsTr("Type “%1” to confirm:").arg(confirmDialog.target)
                font.family: Theme.fontFamily
                font.pixelSize: 13
                color: Theme.fgTertiary
                wrapMode: Text.WordWrap
                width: parent.width
            }
            TextField {
                id: confirmInput
                width: parent.width
                font.family: Theme.fontFamilyMono
                font.pixelSize: 14
                color: Theme.fgPrimary
                echoMode: TextInput.Normal
                selectByMouse: true
                background: Rectangle {
                    color: Theme.surface1
                    border.width: 1
                    border.color: confirmInput.activeFocus ? Theme.accent500
                                                           : Theme.borderDefault
                    radius: Theme.radiusMd
                }
                onTextChanged: confirmDialog.typedValue = text
                Keys.onReturnPressed: confirmDialog.__tryConfirm()
            }
        }

        function __tryConfirm() {
            if (typedValue === target) {
                // Invoke the matching resolver.
                if (operation === "setHostname") {
                    controller.applyConfirmedSetHostname(target);
                } else if (operation === "setLocale") {
                    controller.applyConfirmedSetLocale(target);
                } else if (operation === "deleteUser") {
                    // For deleteUser, target holds the username. We need the
                    // uid → store it separately when the dialog opens.
                    if (confirmDialog.__deleteUid >= 0) {
                        controller.applyConfirmedDeleteUser(
                            confirmDialog.__deleteUid, confirmDialog.__removeFiles);
                    }
                }
                close();
                typedValue = "";
            }
        }
        property int __deleteUid: -1
        property bool __removeFiles: false
    }

    // Forwarded error dialog.
    OrionDialog {
        id: errorDialog
        property string bodyText: ""
        contentItem: Text {
            text: errorDialog.bodyText
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.fgSecondary
            wrapMode: Text.WordWrap
            width: parent ? parent.width - 2 * Theme.space5 : 400
        }
    }

    Connections {
        target: controller
        function onErrorOccurred(message) {
            errorDialog.titleText = qsTr("Error");
            errorDialog.bodyText = message;
            errorDialog.actions = [
                { text: qsTr("OK"), role: "primary", onClicked: function(){} }
            ];
            errorDialog.open();
        }
        function onConfirmationRequired(operation, target, displayName) {
            confirmDialog.operation = operation;
            confirmDialog.target = target;
            confirmDialog.displayName = displayName;
            confirmDialog.typedValue = "";
            confirmDialog.__deleteUid = -1;
            confirmDialog.__removeFiles = false;
            confirmDialog.titleText = qsTr("Confirm action");
            confirmDialog.actions = [
                { text: qsTr("Cancel"), role: "secondary",
                  onClicked: function(){} },
                { text: qsTr("Confirm"), role: "primary",
                  onClicked: function(){ confirmDialog.__tryConfirm(); } }
            ];
            confirmDialog.open();
        }
        function onOperationStarted(description) {
            busyOverlay.description = description;
            busyOverlay.visible = true;
        }
        function onOperationFinished(description, success, errorMessage) {
            busyOverlay.visible = false;
            if (!success && errorMessage.length > 0) {
                errorDialog.titleText = qsTr("Operation failed");
                errorDialog.bodyText = errorMessage;
                errorDialog.actions = [
                    { text: qsTr("OK"), role: "primary", onClicked: function(){} }
                ];
                errorDialog.open();
            }
        }
    }

    // ---- Layout ----
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Left sidebar — fixed 240px wide, lists the 7 categories.
        Sidebar {
            id: sidebar
            Layout.preferredWidth: 240
            Layout.minimumWidth: 200
            Layout.fillHeight: true
            currentCategory: root.currentCategory
            onCategorySelected: function(cat) {
                root.currentCategory = cat;
            }
        }

        // Right content pane.
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Page header.
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                color: Theme.surface1

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: Theme.borderSubtle
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.space5
                    anchors.rightMargin: Theme.space5
                    spacing: Theme.space3

                    Text {
                        text: sidebar.categoryTitle(root.currentCategory)
                        font.family: Theme.fontFamily
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                        color: Theme.fgPrimary
                    }
                    Item { Layout.fillWidth: true }
                    OrionButton {
                        text: qsTr("Refresh")
                        variant: OrionButton.Variant.Ghost
                        size: OrionButton.Size.Compact
                        onClicked: controller.refresh()
                    }
                }
            }

            // The page itself — loaded lazily.
            Loader {
                id: pageLoader
                Layout.fillWidth: true
                Layout.fillHeight: true
                source: "qrc:/qml/pages/" +
                        sidebar.categoryClassName(root.currentCategory) +
                        "Page.qml"
                // Animate the swap when reduceMotion is off.
                onSourceChanged: {
                    if (!Theme.reduceMotion) {
                        item ? item.opacity = 0 : null;
                    }
                }
                onLoaded: {
                    if (!Theme.reduceMotion && item) {
                        fadeAnimation.start();
                    }
                }
                NumberAnimation {
                    id: fadeAnimation
                    target: pageLoader.item
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Theme.motionDefault
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    // ---- Busy overlay ----
    Rectangle {
        id: busyOverlay
        property string description: ""
        visible: false
        anchors.fill: parent
        color: Theme.reduceTransparency
            ? Theme.surface0
            : Qt.rgba(Theme.surface0.redF(), Theme.surface0.greenF(),
                      Theme.surface0.blueF(), 0.7)

        Column {
            anchors.centerIn: parent
            spacing: Theme.space4

            OrionBusy { anchors.horizontalCenter: parent.horizontalCenter }

            Text {
                text: busyOverlay.description.length > 0
                       ? busyOverlay.description
                       : qsTr("Working…")
                font.family: Theme.fontFamily
                font.pixelSize: 14
                color: Theme.fgSecondary
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            // Block clicks while busy.
            onClicked: mouse.accepted = true
        }
    }
}
