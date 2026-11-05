// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import org.orion.framework

Item {
    signal regionSelected(int x, int y, int w, int h)
    signal canceled()

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.4)
        MouseArea {
            anchors.fill: parent
            onPressed: (mouse) => {
                selRect.x = mouse.x; selRect.y = mouse.y
                selRect.width = 0; selRect.height = 0
                selRect.visible = true
            }
            onPositionChanged: (mouse) => {
                if (selRect.visible) {
                    selRect.width = mouse.x - selRect.x
                    selRect.height = mouse.y - selRect.y
                }
            }
            onReleased: (mouse) => {
                var x = Math.min(selRect.x, mouse.x)
                var y = Math.min(selRect.y, mouse.y)
                var w = Math.abs(mouse.x - selRect.x)
                var h = Math.abs(mouse.y - selRect.y)
                if (w > 4 && h > 4) {
                    regionSelected(x, y, w, h)
                } else {
                    canceled()
                }
                selRect.visible = false
            }
            Keys.onPressed: (e) => {
                if (e.key === Qt.Key_Escape) canceled()
            }
        }
    }

    Rectangle {
        id: selRect
        visible: false
        color: "transparent"
        border.width: 2
        border.color: Theme.accent500
    }
}
