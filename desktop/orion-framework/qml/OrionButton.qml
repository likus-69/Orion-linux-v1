// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/OrionButton.qml — primary, secondary, ghost, and danger button variants.

import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

Button {
    id: control

    enum Variant { Primary, Secondary, Ghost, Danger }
    enum Size { Compact, Default, Large }

    property int variant: OrionButton.Variant.Secondary
    property int size: OrionButton.Variant.Default

    implicitHeight: size === OrionButton.Size.Compact ? 28
                   : size === OrionButton.Size.Large    ? 44
                   : 36
    implicitWidth: Math.max(120, contentItem.implicitWidth + 24)
    padding: Theme.space3
    font.family: Theme.fontFamily
    font.pixelSize: size === OrionButton.Size.Compact ? 13 : 15
    font.weight: variant === OrionButton.Variant.Primary ? 600 : 400

    // Variant-driven colors. All tokens come from Theme; no hardcoded colors.
    readonly property color __restingBg: {
        switch (variant) {
        case OrionButton.Variant.Primary:
            return Theme.accent500;
        case OrionButton.Variant.Secondary:
            return Theme.surface2;
        case OrionButton.Variant.Ghost:
            return Theme.surface1.withAlpha(0);  // transparent
        case OrionButton.Variant.Danger:
            return Theme.danger;
        }
    }
    readonly property color __hoverBg: {
        switch (variant) {
        case OrionButton.Variant.Primary:
            return Theme.accent700;
        case OrionButton.Variant.Secondary:
            return Theme.surface3;
        case OrionButton.Variant.Ghost:
            return Theme.surface2;
        case OrionButton.Variant.Danger:
            return Theme.danger.darker(120);
        }
    }
    readonly property color __pressedBg: {
        switch (variant) {
        case OrionButton.Variant.Primary:
            return Theme.accent900;
        case OrionButton.Variant.Secondary:
            return Theme.surface4;
        case OrionButton.Variant.Ghost:
            return Theme.surface3;
        case OrionButton.Variant.Danger:
            return Theme.danger.darker(140);
        }
    }
    readonly property color __fg: {
        if (!enabled) return Theme.fgDisabled;
        if (variant === OrionButton.Variant.Primary ||
            variant === OrionButton.Variant.Danger) {
            return Theme.fgInverse;
        }
        return Theme.fgPrimary;
    }

    background: Rectangle {
        implicitWidth: control.implicitWidth
        implicitHeight: control.implicitHeight
        radius: Theme.radiusMd
        color: control.pressed ? control.__pressedBg
              : control.hovered ? control.__hoverBg
              : control.__restingBg
        border.width: variant === OrionButton.Variant.Secondary ? 1 : 0
        border.color: Theme.borderDefault

        // Focus ring
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: parent.radius + 2
            color: "transparent"
            border.width: 2
            border.color: Theme.accent500
            visible: control.activeFocus
        }

        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.__fg
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // Hover sound (no-op placeholder; the audio daemon plays the actual sound
    // via the freedesktop sound theme).
    HoverHandler {
        acceptedButtons: Qt.NoButton  // hover only
        cursorShape: Qt.PointingHandCursor
    }
}
