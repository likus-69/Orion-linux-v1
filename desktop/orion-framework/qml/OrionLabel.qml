// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/OrionLabel.qml — themed text element with role-based sizing.

import QtQuick
import org.orion.framework

Text {
    id: label

    enum Role { Display, H1, H2, H3, Body, BodyStrong, Caption, Overline, Mono }

    property int role: OrionLabel.Role.Body
    property color tint: Theme.fgPrimary

    font.family: role === OrionLabel.Role.Mono
        ? Theme.fontFamilyMono
        : Theme.fontFamily

    color: tint
    elide: Text.ElideRight

    // Apply role → size/weight/lineHeight.
    Component.onCompleted: __applyRole()
    onRoleChanged: __applyRole()

    function __applyRole() {
        switch (role) {
        case OrionLabel.Role.Display:
            font.pixelSize = 32; font.weight = Font.DemiBold; break;
        case OrionLabel.Role.H1:
            font.pixelSize = 24; font.weight = Font.DemiBold; break;
        case OrionLabel.Role.H2:
            font.pixelSize = 20; font.weight = Font.DemiBold; break;
        case OrionLabel.Role.H3:
            font.pixelSize = 18; font.weight = Font.Medium; break;
        case OrionLabel.Role.Body:
            font.pixelSize = 15; font.weight = Font.Normal; break;
        case OrionLabel.Role.BodyStrong:
            font.pixelSize = 15; font.weight = Font.DemiBold; break;
        case OrionLabel.Role.Caption:
            font.pixelSize = 13; font.weight = Font.Normal; break;
        case OrionLabel.Role.Overline:
            font.pixelSize = 11; font.weight = Font.DemiBold;
            font.letterSpacing = 0.6; break;
        case OrionLabel.Role.Mono:
            font.pixelSize = 14; font.weight = Font.Normal; break;
        }
    }
}
