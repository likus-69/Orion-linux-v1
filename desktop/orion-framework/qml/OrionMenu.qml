// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/OrionMenu.qml — context menu and dropdown menu.

import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

Menu {
    font.family: Theme.fontFamily
    font.pixelSize: 14

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 40
        color: Theme.surface2
        border.width: 1
        border.color: Theme.borderDefault
        radius: Theme.radiusMd
    }

    delegate: MenuItem {
        implicitHeight: 36
        background: Rectangle {
            color: parent.hovered ? Theme.surface3 : Theme.surface2
            Behavior on color { ColorAnimation { duration: Theme.motionFast } }
        }
        contentItem: Text {
            text: parent.text
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: parent.enabled ? Theme.fgPrimary : Theme.fgDisabled
            leftPadding: Theme.space3
            verticalAlignment: Text.AlignVCenter
        }
    }
}
