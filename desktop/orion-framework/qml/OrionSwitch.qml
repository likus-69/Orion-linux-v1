// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/OrionSwitch.qml — toggle switch with accessible label.

import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

Switch {
    id: sw

    property string label: ""

    implicitHeight: 24
    implicitWidth: 44

    indicator: Rectangle {
        implicitWidth: 44
        implicitHeight: 24
        x: sw.leftPadding
        y: parent.height / 2 - height / 2
        radius: height / 2
        color: sw.checked ? Theme.accent500 : Theme.surface4
        border.width: 1
        border.color: sw.checked ? Theme.accent700 : Theme.borderDefault

        Behavior on color { ColorAnimation { duration: Theme.motionFast } }

        Rectangle {
            x: sw.checked ? parent.width - width - 3 : 3
            y: 3
            width: parent.height - 6
            height: parent.height - 6
            radius: width / 2
            color: sw.checked ? Theme.fgInverse : Theme.fgTertiary

            Behavior on x {
                NumberAnimation { duration: Theme.motionDefault; easing.type: Easing.OutCubic }
            }
        }
    }

    contentItem: Text {
        text: sw.label
        font.family: Theme.fontFamily
        font.pixelSize: 14
        color: sw.enabled ? Theme.fgPrimary : Theme.fgDisabled
        verticalAlignment: Text.AlignVCenter
        leftPadding: sw.indicator.width + sw.spacing
    }
}
