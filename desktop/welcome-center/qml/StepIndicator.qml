// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors

import QtQuick
import org.orion.framework

Item {
    property int currentStep: 0
    property int totalSteps: 13
    implicitHeight: 8

    Row {
        anchors.fill: parent
        spacing: Theme.space1

        Repeater {
            model: totalSteps
            Rectangle {
                width: (parent.width - (totalSteps - 1) * Theme.space1) / totalSteps
                height: 4
                radius: 2
                color: index === currentStep ? Theme.accent500
                       : (index < currentStep ? Theme.accent700 : Theme.surface4)
                Behavior on color { ColorAnimation { duration: Theme.motionFast } }
            }
        }
    }
}
