// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/DoneStep.qml — Step 12.
//
// "You're all set!" with a "Don't show again" checkbox. The checkbox is
// checked by default — the welcome center assumes the user wants to be
// left alone after the tour unless they explicitly opt back in. The
// "Finish" button in the footer writes the done marker (or "skip"
// sentinel) so the autostart unit doesn't relaunch us on next login.

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import org.orion.framework

Item {
    id: step
    Layout.fillWidth: true
    Layout.fillHeight: true

    property bool dontShowAgain: true

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(560, step.width - 2 * Theme.space5)
        spacing: Theme.space5

        // Big checkmark.
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 96
            Layout.preferredHeight: 96
            radius: 48
            color: Theme.success.withAlphaF(0.15)
            border.width: 2
            border.color: Theme.success

            Text {
                anchors.centerIn: parent
                text: "✓"
                font.family: Theme.fontFamily
                font.pixelSize: 56
                font.weight: Font.Bold
                color: Theme.success
            }
        }

        OrionLabel {
            role: OrionLabel.Role.Display
            text: qsTr("You're all set!")
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
        }

        OrionLabel {
            role: OrionLabel.Role.H3
            tint: Theme.fgSecondary
            text: qsTr("Welcome to Orion OS, %1. Your desktop is ready.").arg(
                welcomeController.userName())
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // Quick recap of what was configured (purely informational).
        // We don't show the accent here because the welcome center
        // writes it to settings.json (the orion-settings daemon applies
        // it on next login); reading it back from JSON wouldn't reflect
        // what the user just picked on step 2 in this session.
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.space1

            Text {
                text: qsTr("Recap:")
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: Theme.fgTertiary
            }
            Text {
                text: qsTr("• Theme: <b>%1</b>   • Auto-update check: <b>%2</b>   • Telemetry: <b>%3</b>")
                        .arg(Theme.currentTheme)
                        .arg(welcomeController.autoCheckUpdates ? qsTr("ON") : qsTr("OFF"))
                        .arg(welcomeController.telemetry ? qsTr("ON (opted in)") : qsTr("OFF"))
                textFormat: Text.RichText
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: Theme.fgSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        // "Don't show again" checkbox.
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.space2

            CheckBox {
                id: dontShowCheck
                checked: step.dontShowAgain
                onToggled: step.dontShowAgain = checked

                indicator: Rectangle {
                    implicitWidth: 18
                    implicitHeight: 18
                    radius: Theme.radiusSm
                    color: dontShowCheck.checked ? Theme.accent500 : Theme.surface1
                    border.width: 1
                    border.color: dontShowCheck.checked
                        ? Theme.accent700
                        : Theme.borderDefault

                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }

                    Text {
                        anchors.centerIn: parent
                        text: "✓"
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: Theme.fgInverse
                        visible: dontShowCheck.checked
                    }
                }

                contentItem: Text {
                    text: qsTr("Don't show the welcome tour again")
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.fgSecondary
                    leftPadding: dontShowCheck.indicator.width + Theme.space2
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // Helper text.
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("If unchecked, the tour will start again on next login. You can "
                      + "always relaunch it manually from the Start menu.")
            font.family: Theme.fontFamily
            font.pixelSize: 11
            color: Theme.fgTertiary
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // Launch the file manager as a "let's go" affordance.
        OrionButton {
            text: qsTr("Open File Manager")
            variant: OrionButton.Variant.Secondary
            size: OrionButton.Size.Default
            Layout.alignment: Qt.AlignHCenter
            onClicked: welcomeController.openFileManager()
        }
    }

    // The Main.qml finish() function reads this step's `dontShowAgain`
    // property and only calls welcomeController.markDone() when it is
    // true. If the user unchecks the box, the marker is left absent
    // and the tour auto-launches again on next login.
    //
    // (No Connections needed here — Main.qml owns the finish() flow.)
}
