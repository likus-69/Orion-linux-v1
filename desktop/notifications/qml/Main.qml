// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework
import org.orion.notifications

Item {
    // Root — invisible; holds the notification stack.
    // Anchored to the bottom-right of the primary screen.
    anchors.fill: parent

    // We use a Window as a wrapper for proper layer-shell positioning.
    // The actual notification cards are in NotificationStack.qml.
    NotificationStack {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.space3
        anchors.bottomMargin: 56  // above the panel
        width: 360
    }
}
