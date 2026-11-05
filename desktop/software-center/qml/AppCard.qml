// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    id: card
    property string appId
    property string name
    property string summary
    property string icon
    property string repo

    implicitHeight: 120
    implicitWidth: parent ? parent.width : 320

    Rectangle {
        anchors.fill: parent
        color: Theme.surface2; radius: Theme.radiusLg
        border.width: 1; border.color: Theme.borderSubtle

        RowLayout {
            anchors.fill: parent; anchors.margins: Theme.space3; spacing: Theme.space3

            Rectangle {
                width: 56; height: 56; radius: Theme.radiusMd
                color: Theme.surface3
                Layout.alignment: Qt.AlignVCenter
                Image {
                    anchors.centerIn: parent
                    source: card.icon.startsWith("/") ? "file://" + card.icon : ""
                    sourceSize.width: 36; sourceSize.height: 36
                }
            }

            ColumnLayout {
                Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: Theme.space1
                Text {
                    text: card.name
                    font.family: Theme.fontFamily; font.pixelSize: 14
                    font.weight: Font.DemiBold; color: Theme.fgPrimary
                    Layout.fillWidth: true; elide: Text.ElideRight
                }
                Text {
                    text: card.summary
                    font.family: Theme.fontFamily; font.pixelSize: 12
                    color: Theme.fgSecondary; wrapMode: Text.WordWrap
                    Layout.fillWidth: true; elide: Text.ElideRight
                }
                RepoBadge { repo: card.repo }
            }

            InstallButton {
                appId: card.appId
            }
        }
    }
}
