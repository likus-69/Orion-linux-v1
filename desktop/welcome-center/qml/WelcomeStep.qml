// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/WelcomeStep.qml — Step 0.
//
// Orion logo + tagline + "Get started" button. The first thing the user
// sees. Pressing Get Started advances to step 1 (Navigation tutorial).
// The footer's "Next" button does the same; this in-step button is just
// a more discoverable affordance for users who scan content top-to-
// bottom rather than looking at the footer.

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    id: step
    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(560, step.width - 2 * Theme.space5)
        spacing: Theme.space5

        // Orion logo. The branding PNGs ship in /usr/share/orion/.
        Image {
            source: "/usr/share/orion/orion-logo.png"
            fillMode: Image.PreserveAspectFit
            sourceSize.width: 96
            sourceSize.height: 96
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 96
            Layout.preferredHeight: 96

            // Fallback when the logo PNG isn't installed yet (e.g. on a
            // developer box without the branding package).
            Text {
                anchors.centerIn: parent
                visible: parent.status !== Image.Ready
                text: "◈"
                font.family: Theme.fontFamily
                font.pixelSize: 64
                color: Theme.accent500
            }
        }

        OrionLabel {
            role: OrionLabel.Role.Display
            text: qsTr("Welcome to Orion OS")
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
        }

        OrionLabel {
            role: OrionLabel.Role.H3
            tint: Theme.fgSecondary
            text: qsTr("A clean, modern, Linux-based desktop — built for getting things done.")
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // Version pill.
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 28
            implicitWidth: versionText.implicitWidth + 24
            radius: 14
            color: Theme.surface2
            border.width: 1
            border.color: Theme.borderSubtle

            Text {
                id: versionText
                anchors.centerIn: parent
                text: welcomeController.orionVersion()
                font.family: Theme.fontFamilyMono
                font.pixelSize: 12
                color: Theme.fgSecondary
            }
        }

        Item { Layout.fillHeight: true; Layout.preferredHeight: Theme.space3 }

        // "Get started" — same effect as the footer's Next button.
        OrionButton {
            text: qsTr("Get started")
            variant: OrionButton.Variant.Primary
            size: OrionButton.Size.Large
            Layout.alignment: Qt.AlignHCenter
            onClicked: {
                // Walk up to the ApplicationWindow and call its next()
                // method. This is the idiomatic QML way to invoke a
                // method on the enclosing window from a child item.
                var win = step.Window.window;
                if (win && typeof win.next === "function") win.next();
            }
        }

        // Friendly greeting using the user's full name (or username).
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Hi, %1. This tour takes about 5 minutes.")
                    .arg(welcomeController.userName())
            font.family: Theme.fontFamily
            font.pixelSize: 13
            color: Theme.fgTertiary
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
