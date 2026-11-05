// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/components/ThemeCard.qml — preview card for one of the 5 Orion themes.
//
// Shows a mini-screenshot of the theme (a small swatch grid that uses the
// theme's actual surface/accent colors) and an "Active" indicator when
// selected. Clicking the card emits `selected(themeId)`.

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    id: card

    // Theme metadata passed in from the parent.
    property string themeId: ""          // "orion-dark", "orion-light", ...
    property string themeName: ""         // "Orion Dark"
    property string description: ""      // "Default deep navy + blue"
    property bool isSelected: false

    // The 5 themes' representative colors. We hardcode them here (mirrored
    // from data/tokens.json) so the preview renders identically even when
    // the active theme is different from the one being previewed.
    readonly property var themeColors: ({
        "orion-dark":           { surface0: "#0B0F1A", surface2: "#1A2030", accent: "#2D7FF9", fg: "#F2F4F8" },
        "orion-light":          { surface0: "#F7F9FC", surface2: "#FFFFFF", accent: "#0F6FE8", fg: "#1A1F2E" },
        "orion-midnight":       { surface0: "#04060B", surface2: "#0F1320", accent: "#7C5CFF", fg: "#F2F4F8" },
        "orion-aurora":         { surface0: "#0A1A14", surface2: "#162B22", accent: "#2FB57C", fg: "#EAF2EE" },
        "orion-high-contrast":  { surface0: "#000000", surface2: "#1A1A1A", accent: "#FFFFFF", fg: "#FFFFFF" }
    })
    readonly property var colors: themeColors[themeId] || themeColors["orion-dark"]

    signal selected(string themeId)

    implicitHeight: 168
    implicitWidth: 220

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Theme.radiusLg
        color: Theme.surface2
        border.width: card.isSelected ? 2 : 1
        border.color: card.isSelected ? Theme.accent500 : Theme.borderSubtle

        Behavior on border.color { ColorAnimation { duration: Theme.motionFast } }
        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        onTapped: card.selected(card.themeId)
    }

    // Focus ring.
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: bg.radius + 2
        color: "transparent"
        border.width: 2
        border.color: Theme.accent500
        visible: card.activeFocus
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.space3
        spacing: Theme.space2

        // ---- Mini screenshot preview ----
        // A small mock of the desktop: a panel bar at the top + an accent
        // button + a card surface, all in the theme's actual colors.
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 84
            radius: Theme.radiusMd
            color: card.colors.surface0
            clip: true

            // Mock panel bar.
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 12
                color: card.colors.surface2

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    width: 6
                    height: 6
                    radius: 3
                    color: card.colors.accent
                }
            }

            // Mock window content card.
            Rectangle {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 6
                width: parent.width - 28
                height: 36
                radius: 4
                color: card.colors.surface2

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    height: 10
                    radius: 2
                    color: card.colors.accent
                }
                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14
                    height: 6
                    radius: 2
                    color: card.colors.fg
                    opacity: 0.4
                }
            }
        }

        // ---- Theme name + description ----
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space2

            Text {
                text: card.themeName
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: Theme.fgPrimary
                elide: Text.ElideRight
            }

            // Active badge.
            Rectangle {
                visible: card.isSelected
                width: activeText.implicitWidth + 12
                height: 18
                radius: 9
                color: Theme.accent500
                Text {
                    id: activeText
                    anchors.centerIn: parent
                    text: qsTr("Active")
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    color: Theme.fgInverse
                }
            }
        }

        Text {
            text: card.description
            Layout.fillWidth: true
            font.family: Theme.fontFamily
            font.pixelSize: 11
            color: Theme.fgTertiary
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 2
        }
    }
}
