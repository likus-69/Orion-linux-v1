// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/components/AccentSwatch.qml — color swatch button for the accent picker.
//
// Shows a circular swatch filled with the accent color, a soft ring when
// selected, and a check mark. Emits `selected(accentId)` on click.

import QtQuick
import org.orion.framework

Item {
    id: swatch

    property string accentId: ""   // "blue", "cyan", "violet", ...
    property string hexColor: "#2D7FF9"
    property string label: ""
    property bool isSelected: false

    signal selected(string accentId)

    implicitHeight: 72
    implicitWidth: 72

    HoverHandler { cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: swatch.selected(swatch.accentId) }

    // Focus ring.
    Rectangle {
        anchors.fill: parent
        anchors.margins: -3
        radius: width / 2
        color: "transparent"
        border.width: 2
        border.color: Theme.accent500
        visible: swatch.activeFocus
    }

    Column {
        anchors.fill: parent
        spacing: Theme.space1

        Item {
            width: 48
            height: 48
            anchors.horizontalCenter: parent.horizontalCenter

            // Outer ring (visible on hover or selection).
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: swatch.isSelected ? 3 : 0
                border.color: swatch.hexColor

                Behavior on border.width {
                    NumberAnimation { duration: Theme.motionFast }
                }
            }

            // Swatch fill.
            Rectangle {
                anchors.centerIn: parent
                width: 38
                height: 38
                radius: width / 2
                color: swatch.hexColor

                Behavior on color { ColorAnimation { duration: Theme.motionFast } }

                // Inner highlight.
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 4
                    width: 12
                    height: 12
                    radius: 6
                    color: "#FFFFFF"
                    opacity: 0.18
                }

                // Check mark when selected.
                Canvas {
                    anchors.fill: parent
                    visible: swatch.isSelected
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.strokeStyle = "#FFFFFF";
                        ctx.lineWidth = 3;
                        ctx.lineCap = "round";
                        ctx.beginPath();
                        ctx.moveTo(11, 19);
                        ctx.lineTo(17, 25);
                        ctx.lineTo(28, 13);
                        ctx.stroke();
                    }
                }
            }
        }

        Text {
            text: swatch.label
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: Theme.fontFamily
            font.pixelSize: 11
            color: swatch.isSelected ? Theme.fgPrimary : Theme.fgSecondary
            font.weight: swatch.isSelected ? Font.DemiBold : Font.Normal
        }
    }
}
