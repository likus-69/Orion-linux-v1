// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/OrionTooltip.qml — small floating tooltip.

import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

ToolTip {
    delay: 400
    timeout: 4000
    padding: Theme.space2
    font.family: Theme.fontFamily
    font.pixelSize: 12
    color: Theme.fgPrimary

    background: Rectangle {
        color: Theme.surface3
        border.width: 1
        border.color: Theme.borderDefault
        radius: Theme.radiusSm
    }
}
