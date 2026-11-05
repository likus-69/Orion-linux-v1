// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework
import org.orion.welcome

ApplicationWindow {
    id: window
    width: 880
    height: 620
    minimumWidth: 720
    minimumHeight: 540
    title: qsTr("Welcome to Orion OS")
    color: Theme.surface0
    visible: true

    property int currentStep: 0
    property int totalSteps: 13
    property bool dontShowAgain: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.space6
        spacing: Theme.space4

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space4

            Image {
                source: "file:///usr/share/orion/orion-logo.png"
                sourceSize.width: 32
                sourceSize.height: 32
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: qsTr("Orion OS Welcome")
                font.family: Theme.fontFamily
                font.pixelSize: 22
                font.weight: Font.DemiBold
                color: Theme.fgPrimary
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            OrionButton {
                text: qsTr("Skip")
                variant: OrionButton.Variant.Ghost
                onClicked: {
                    welcome.markDone();
                    Qt.quit();
                }
                Layout.alignment: Qt.AlignVCenter
            }
        }

        StepIndicator {
            currentStep: window.currentStep
            totalSteps: window.totalSteps
            Layout.fillWidth: true
        }

        // Stack of step pages
        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: window.currentStep

            steps.WelcomeStep        {}
            steps.NavigationStep     {}
            steps.PersonalizationStep{}
            steps.NetworkStep        {}
            steps.AudioStep          {}
            steps.DisplayStep        {}
            steps.HardwareStep       {}
            steps.SoftwareStep       {}
            steps.UpdateStep         {}
            steps.BackupStep         {}
            steps.PrivacyStep        {}
            steps.DocsStep           {}
            steps.DoneStep           {}
        }

        // Footer nav
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space3

            OrionButton {
                text: qsTr("Back")
                enabled: window.currentStep > 0
                variant: OrionButton.Variant.Secondary
                onClicked: window.currentStep = Math.max(0, window.currentStep - 1)
            }

            Item { Layout.fillWidth: true }

            CheckBox {
                text: qsTr("Don't show again on next login")
                checked: window.dontShowAgain
                onCheckedChanged: window.dontShowAgain = checked
                visible: window.currentStep === window.totalSteps - 1
                font.family: Theme.fontFamily
            }

            OrionButton {
                text: window.currentStep === window.totalSteps - 1
                      ? qsTr("Finish") : qsTr("Next")
                variant: OrionButton.Variant.Primary
                onClicked: {
                    if (window.currentStep === window.totalSteps - 1) {
                        if (window.dontShowAgain) welcome.markDone();
                        Qt.quit();
                    } else {
                        window.currentStep++;
                    }
                }
            }
        }
    }
}
