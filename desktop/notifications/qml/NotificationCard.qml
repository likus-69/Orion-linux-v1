// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    id: card
    property string appName: ""
    property string summary: ""
    property string body: ""
    property string iconSource: ""
    signal close()

    implicitHeight: Math.max(80, layout.implicitHeight + 2 * Theme.space3)
    implicitWidth: 360

    Rectangle {
        anchors.fill: parent
        color: Theme.surface2
        radius: Theme.radiusLg
        border.width: 1
        border.color: Theme.borderSubtle

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: Theme.space3
            spacing: Theme.space2

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.space2

                Rectangle {
                    width: 24; height: 24; radius: 4
                    color: Theme.surface3
                    OrionIcon { source: card.iconSource || "icon-application"; size: 18; anchors.centerIn: parent }
                }

                Text {
                    text: card.appName
                    font.family: Theme.fontFamily; font.pixelSize: 11
                    font.weight: Font.DemiBold; color: Theme.fgTertiary
                    Layout.fillWidth: true; elide: Text.ElideRight
                }

                Rectangle {
                    width: 20; height: 20; radius: 4
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        font.family: Theme.fontFamily; font.pixelSize: 14
                        color: Theme.fgTertiary
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: card.close()
                    }
                }
            }

            Text {
                text: card.summary
                font.family: Theme.fontFamily; font.pixelSize: 14
                font.weight: Font.DemiBold; color: Theme.fgPrimary
                Layout.fillWidth: true; wrapMode: Text.WordWrap
            }

            Text {
                text: card.body
                font.family: Theme.fontFamily; font.pixelSize: 13
                color: Theme.fgSecondary; wrapMode: Text.WordWrap
                Layout.fillWidth: true
                visible: card.body.length > 0
            }
        }
    }

    Behavior on height { NumberAnimation { duration: Theme.motionDefault; easing.type: Easing.OutCubic } }
}
