// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/OrionBusy.qml — circular spinner, used during long operations.

import QtQuick
import org.orion.framework

Item {
    id: busy
    property bool running: true
    property color tint: Theme.accent500
    property int size: 24

    implicitWidth: size
    implicitHeight: size
    visible: running

    Item {
        anchors.fill: parent
        visible: busy.running
        rotation: running ? 360 : 0
        Behavior on rotation {
            NumberAnimation {
                duration: Theme.motionSlow * 3
                loops: Animation.Infinite
                running: busy.running
            }
        }

        // A 3/4 arc.
        Canvas {
            anchors.fill: parent
            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                ctx.strokeStyle = busy.tint;
                ctx.lineWidth = 3;
                ctx.lineCap = "round";
                ctx.beginPath();
                ctx.arc(width / 2, height / 2, Math.min(width, height) / 2 - 2,
                        0, Math.PI * 1.5);
                ctx.stroke();
            }
        }
    }

    Accessible.role: Accessible.Indicator
    Accessible.name: qsTr("Loading")
}
