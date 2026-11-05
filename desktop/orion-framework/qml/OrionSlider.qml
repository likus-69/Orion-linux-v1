// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/OrionSlider.qml — volume / brightness slider with token-driven styling.

import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

Slider {
    id: slider

    implicitHeight: 24
    implicitWidth: 200

    background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        implicitWidth: slider.availableWidth
        implicitHeight: 4
        width: slider.availableWidth
        height: 4
        radius: 2
        color: Theme.surface4

        Rectangle {
            width: slider.visualPosition * parent.width
            height: parent.height
            color: Theme.accent500
            radius: parent.radius
        }
    }

    handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition
           * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        implicitWidth: 16
        implicitHeight: 16
        radius: 8
        color: Theme.fgInverse
        border.width: 1
        border.color: Theme.accent500

        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
    }
}
