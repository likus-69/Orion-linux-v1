// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/PersonalizationStep.qml — Step 2.
//
// Quick-pick theme picker with 5 cards (orion-dark, orion-light,
// orion-midnight, orion-aurora, orion-high-contrast) + accent color
// picker. Changes apply immediately via Theme.currentTheme (the Orion
// framework singleton) and are persisted by the orion-settings daemon
// (the settings.json file at ~/.config/orion/settings.json).
//
// Note: this is a quick-pick — the full Personalization page in Orion
// Settings exposes wallpaper, fonts, lock screen, panel position, and
// animation toggles.

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    id: step
    Layout.fillWidth: true
    Layout.fillHeight: true

    // Local Orion::Settings component bound to "settings" — the same
    // file the orion-settings daemon reads/writes (~/.config/orion/
    // settings.json). Writing here persists the user's theme/accent
    // choices; they take effect immediately via the Theme singleton
    // (for theme) and on next login (for accent, which is applied by
    // the orion-shell startup script).
    Settings {
        id: settingsStore
        component: "settings"
    }

    // The 5 themes + 7 accents. These are duplicated from
    // settings/qml/components/ThemeCard.qml so the welcome center is
    // self-contained; the preview colors are mirrored from
    // orion-framework/data/tokens.json so the preview renders in the
    // previewed theme's colors even when the active theme is different.
    readonly property var themes: [
        { id: "orion-dark",          name: qsTr("Dark"),
          desc: qsTr("Deep navy + blue accent (default)"),
          surface0: "#0B0F1A", surface2: "#1A2030", accent: "#2D7FF9", fg: "#F2F4F8" },
        { id: "orion-light",         name: qsTr("Light"),
          desc: qsTr("Bright surfaces, darker accent"),
          surface0: "#F7F9FC", surface2: "#FFFFFF", accent: "#0F6FE8", fg: "#1A1F2E" },
        { id: "orion-midnight",      name: qsTr("Midnight"),
          desc: qsTr("Pure black, violet accent (OLED)"),
          surface0: "#04060B", surface2: "#0F1320", accent: "#7C5CFF", fg: "#F2F4F8" },
        { id: "orion-aurora",        name: qsTr("Aurora"),
          desc: qsTr("Emerald accent on dark green"),
          surface0: "#0A1A14", surface2: "#162B22", accent: "#2FB57C", fg: "#EAF2EE" },
        { id: "orion-high-contrast", name: qsTr("High Contrast"),
          desc: qsTr("WCAG AAA, no blur or gradients"),
          surface0: "#000000", surface2: "#1A1A1A", accent: "#FFFFFF", fg: "#FFFFFF" }
    ]

    readonly property var accents: [
        { id: "blue",     hex: "#2D7FF9" },
        { id: "cyan",     hex: "#06B6D4" },
        { id: "violet",   hex: "#7C5CFF" },
        { id: "magenta",   hex: "#D946EF" },
        { id: "amber",    hex: "#F59E0B" },
        { id: "emerald",  hex: "#2FB57C" },
        { id: "crimson",  hex: "#EF4444" }
    ]

    // Currently selected accent (loaded from settings.json, defaults to
    // "blue" — the same default the orion-settings daemon assumes).
    property string currentAccent: settingsStore.get("accent", "blue")

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        OrionLabel {
            role: OrionLabel.Role.H1
            text: qsTr("Make it yours")
        }
        OrionLabel {
            role: OrionLabel.Role.Body
            tint: Theme.fgSecondary
            text: qsTr("Pick a base theme and an accent color. You can change these anytime in "
                      + "Settings → Personalization.")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // ---- Theme cards (5) ----
        GridLayout {
            Layout.fillWidth: true
            columns: step.width > 720 ? 5 : 2
            columnSpacing: Theme.space3
            rowSpacing: Theme.space3

            Repeater {
                model: step.themes
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 132
                    radius: Theme.radiusLg
                    color: Theme.surface2
                    border.width: Theme.currentTheme === modelData.id ? 2 : 1
                    border.color: Theme.currentTheme === modelData.id
                                   ? Theme.accent500
                                   : Theme.borderSubtle

                    Behavior on border.color {
                        ColorAnimation { duration: Theme.motionFast }
                    }

                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        onTapped: {
                            Theme.currentTheme = modelData.id;
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.space3
                        spacing: Theme.space2

                        // Mini screenshot preview — panel bar + a card
                        // with an accent button, in the theme's colors.
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 56
                            radius: Theme.radiusSm
                            color: modelData.surface0
                            clip: true

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                height: 10
                                color: modelData.surface2
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 6
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 6; height: 6
                                    radius: 3
                                    color: modelData.accent
                                }
                            }
                            Rectangle {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: 4
                                width: parent.width - 20
                                height: 22
                                radius: 3
                                color: modelData.surface2
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 6
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 22; height: 6
                                    radius: 2
                                    color: modelData.accent
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: Theme.fgPrimary
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: modelData.desc
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: Theme.fgTertiary
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            maximumLineCount: 2
                        }
                    }
                }
            }
        }

        // ---- Accent color picker ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Accent color")
            subtitle: qsTr("Used for highlights, focus rings, and primary buttons")

            contentItem: Column {
                spacing: Theme.space2
                width: parent ? parent.width - 2 * Theme.space4 : 360

                Row {
                    spacing: Theme.space3
                    width: parent.width

                    Repeater {
                        model: step.accents
                        delegate: Rectangle {
                            width: 28; height: 28
                            radius: 14
                            color: modelData.hex
                            border.width: step.currentAccent === modelData.id ? 3 : 0
                            border.color: Theme.fgPrimary

                            Behavior on border.width {
                                NumberAnimation { duration: Theme.motionFast }
                            }
                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                            TapHandler {
                                onTapped: {
                                    // Persist via Orion::Settings so the
                                    // orion-settings daemon picks up the
                                    // choice. The accent is applied on
                                    // next login (or next time the settings
                                    // daemon restarts).
                                    settingsStore.set("accent", modelData.id);
                                    settingsStore.save();
                                    step.currentAccent = modelData.id;
                                }
                            }
                        }
                    }
                }

                Text {
                    text: qsTr("Takes effect on next login. Open Settings → Personalization "
                              + "to apply immediately.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.fgTertiary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        Item { Layout.fillHeight: true; Layout.preferredHeight: Theme.space2 }
    }
}
