// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/OrionComboBox.qml — dropdown selector.

import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

ComboBox {
    id: combo
    implicitHeight: 36
    implicitWidth: 200
    font.family: Theme.fontFamily
    font.pixelSize: 14

    background: Rectangle {
        implicitWidth: combo.implicitWidth
        implicitHeight: combo.implicitHeight
        radius: Theme.radiusMd
        color: Theme.surface1
        border.width: 1
        border.color: combo.activeFocus ? Theme.accent500 : Theme.borderDefault
    }

    contentItem: Text {
        text: combo.displayText
        font: combo.font
        color: combo.enabled ? Theme.fgPrimary : Theme.fgDisabled
        verticalAlignment: Text.AlignVCenter
        leftPadding: Theme.space3
    }

    indicator: OrionIcon {
        source: "icon-chevron-down"
        size: 16
        x: combo.width - width - Theme.space3
        y: (combo.height - height) / 2
    }

    // Popup styling.
    popup: Popup {
        y: combo.height + Theme.space1
        width: combo.width
        implicitHeight: contentItem.implicitHeight + 2 * Theme.space2
        padding: Theme.space2

        background: Rectangle {
            color: Theme.surface2
            border.width: 1
            border.color: Theme.borderDefault
            radius: Theme.radiusMd
        }

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: combo.delegateModel
            currentIndex: combo.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }
    }
}
