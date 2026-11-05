// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/OrionIcon.qml — themed SVG/PNG icon loader.

import QtQuick
import org.orion.framework

Item {
    id: icon

    property string source: ""      // e.g. "icon-search" or absolute path
    property color tint: Theme.fgPrimary
    property int size: 24

    implicitWidth: size
    implicitHeight: size

    // Look up the icon via the QIcon theme engine. This handles both
    // orion-theme PNG/SVG icons and the freedesktop hicolor fallback chain.
    Image {
        anchors.fill: parent
        source: icon.source.startsWith("/") || icon.source.startsWith("file:")
                ? icon.source
                : "image://orion-icons/" + icon.source
        sourceSize.width: icon.size
        sourceSize.height: icon.size
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
}
