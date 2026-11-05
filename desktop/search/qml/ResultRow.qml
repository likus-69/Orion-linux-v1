// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    id: row
    property string icon
    property string title
    property string subtitle
    property string category

    signal clicked()

    implicitHeight: 44
    implicitWidth: parent ? parent.width : 320

    Rectangle {
        anchors.fill: parent
        color: parent.hovered ? Theme.surface3 : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.space3
        anchors.rightMargin: Theme.space3
        spacing: Theme.space3

        OrionIcon { source: row.icon; size: 20; Layout.alignment: Qt.AlignVCenter }

        ColumnLayout {
            Layout.fillWidth: true; spacing: 0
            Text {
                text: row.title
                font.family: Theme.fontFamily; font.pixelSize: 14
                color: Theme.fgPrimary; elide: Text.ElideRight; Layout.fillWidth: true
            }
            Text {
                text: row.subtitle
                font.family: Theme.fontFamily; font.pixelSize: 11
                color: Theme.fgTertiary; elide: Text.ElideRight; Layout.fillWidth: true
                visible: row.subtitle.length > 0
            }
        }

        Text {
            text: row.category
            font.family: Theme.fontFamily; font.pixelSize: 10
            color: Theme.fgTertiary
        }
    }

    MouseArea { anchors.fill: parent; hoverEnabled: true; onClicked: row.clicked() }
}
