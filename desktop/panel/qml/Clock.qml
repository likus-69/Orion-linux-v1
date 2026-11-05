// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/Clock.qml — panel clock display + calendar popover.
//
// Renders the current time as HH:MM. Updates every second via a plain
// Timer (the interval is NOT tied to Theme.motion* so the clock stays
// accurate even when reduceMotion is on). Clicking opens a small
// calendar popover showing the current month.

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework

Item {
    id: clockRoot

    signal activated()

    implicitWidth: clockText.implicitWidth + Theme.space2
    implicitHeight: clockText.implicitHeight + Theme.space2

    // 1-second tick. Coarse timer keeps the panel out of the render loop
    // most of the time. The clock format only resolves to the minute, but
    // we tick every second so the minute rolls over precisely at :00
    // rather than up to 59 s late.
    Timer {
        id: ticker
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            const now = new Date();
            const hh = String(now.getHours()).padStart(2, "0");
            const mm = String(now.getMinutes()).padStart(2, "0");
            clockText.text = hh + ":" + mm;
            calendarLabel.text =
                now.toLocaleDateString(Qt.locale(), "MMMM yyyy");
            calendarGrid.month = now.getMonth();
            calendarGrid.year = now.getFullYear();
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        onTapped: {
            clockRoot.activated();
            calendarPopup.open();
        }
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        text: "--:--"
        color: hover.hovered ? Theme.accent300 : Theme.fgPrimary
        font.family: Theme.fontFamily
        font.pixelSize: 14
        font.weight: Font.Medium
        Behavior on color {
            ColorAnimation {
                duration: Theme.reduceMotion ? 0 : Theme.motionFast
            }
        }
    }

    // ---- Calendar popover ----------------------------------------------
    Popup {
        id: calendarPopup
        x: (clockRoot.width - width) / 2
        y: -height - Theme.space2
        width: 280
        height: 280
        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Theme.surface2
            border.width: 1
            border.color: Theme.borderDefault
            radius: Theme.radiusMd
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.space3
            spacing: Theme.space2

            Text {
                id: calendarLabel
                Layout.fillWidth: true
                text: ""
                color: Theme.fgPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 16
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
            }

            // Day-of-week header row
            RowLayout {
                Layout.fillWidth: true
                spacing: 0
                Repeater {
                    model: ["M", "T", "W", "T", "F", "S", "S"]
                    Text {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24
                        text: modelData
                        color: Theme.fgTertiary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // Day-of-month grid
            Grid {
                id: calendarGrid
                property int month: 0
                property int year: 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                rows: 6
                spacing: 0

                Repeater {
                    model: 42
                    Item {
                        width: calendarGrid.width / 7
                        height: calendarGrid.height / 6
                        readonly property date today: new Date()
                        readonly property date cellDate: {
                            const first = new Date(
                                calendarGrid.year, calendarGrid.month, 1);
                            const offset = (first.getDay() + 6) % 7;  // Mon=0
                            new Date(calendarGrid.year, calendarGrid.month,
                                     (index - offset) + 1);
                        }
                        readonly property bool inMonth:
                            cellDate.getMonth() === calendarGrid.month
                        readonly property bool isToday:
                            cellDate.toDateString() === today.toDateString()

                        Text {
                            anchors.centerIn: parent
                            text: parent.cellDate.getDate()
                            color: parent.isToday
                                ? Theme.accent500
                                : (parent.inMonth ? Theme.fgPrimary
                                                  : Theme.fgTertiary)
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            font.weight: parent.isToday ? Font.DemiBold
                                                        : Font.Normal
                        }
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.width: 1
                            border.color: Theme.accent500
                            radius: Theme.radiusFull
                            visible: parent.isToday
                            z: -1
                        }
                    }
                }
            }
        }
    }
}
