// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    id: toggle
    property string text: ""
    property string icon: ""
    property bool checked: false
    signal toggled()

    implicitHeight: 56
    implicitWidth: parent ? parent.width : 160

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusLg
        color: toggle.checked ? Theme.accent500.withAlphaF(0.18) : Theme.surface2
        border.width: 1
        border.color: toggle.checked ? Theme.accent500 : Theme.borderSubtle

        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.motionFast } }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.space1

        OrionIcon {
            source: toggle.icon
            size: 22
            Layout.alignment: Qt.AlignHCenter
            tint: toggle.checked ? Theme.accent500 : Theme.fgPrimary
        }
        Text {
            text: toggle.text
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: toggle.checked ? Font.DemiBold : Font.Normal
            color: toggle.checked ? Theme.accent500 : Theme.fgPrimary
            Layout.alignment: Qt.AlignHCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: toggle.toggled()
    }
}
