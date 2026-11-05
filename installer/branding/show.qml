// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// /etc/calamares/branding/show.qml — Calamares slideshow played during
// installation. Tells the user what Orion OS is while packages are copied.

import QtQuick

Item {
    id: root
    anchors.fill: parent

    // Background gradient.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#131826" }
            GradientStop { position: 1.0; color: "#0B0F1A" }
        }
    }

    // Logo
    Image {
        id: logo
        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.horizontalCenter: parent.horizontalCenter
        source: "logo.png"
        sourceSize.width: 96
        sourceSize.height: 96
    }

    // Rotating taglines
    Text {
        id: tagline
        anchors.top: logo.bottom
        anchors.topMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: "Inter"
        font.pixelSize: 28
        font.weight: Font.DemiBold
        color: "#FFFFFF"
        text: "Welcome to Orion OS"
    }

    Text {
        id: body
        anchors.top: tagline.bottom
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 120
        horizontalAlignment: Text.AlignHCenter
        font.family: "Inter"
        font.pixelSize: 16
        color: "#B6BDD0"
        wrapMode: Text.WordWrap
        text: "Installing Orion OS — a polished, Arch-Linux-based desktop."
    }

    // Tagline rotator
    Timer {
        interval: 4000
        running: true
        repeat: true
        onTriggered: {
            const messages = [
                "Welcome to Orion OS",
                "Windows-inspired, distinctly Orion",
                "Wayland-native. Qt6-powered.",
                "Polkit-gated, polkit-safe.",
                "Btrfs snapshots. Snapper integration.",
                "PackageKit for safe software management",
                "Calamares — your installer, branded."
            ];
            tagline.text = messages[(messages.indexOf(tagline.text) + 1) % messages.length];
        }
    }

    // Footer credit
    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: "Inter"
        font.pixelSize: 12
        color: "#4A5066"
        text: "github.com/likus-69/Orion-linux-v1.1"
    }
}
