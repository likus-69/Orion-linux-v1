// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        Item { Layout.fillHeight: 1 }

        Image {
            source: "file:///usr/share/orion/orion-logo.png"
            sourceSize.width: 80
            sourceSize.height: 80
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: qsTr("You're all set!")
            font.family: Theme.fontFamily
            font.pixelSize: 28
            font.weight: Font.DemiBold
            color: Theme.fgPrimary
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: qsTr("Orion OS is ready to use. Click Finish to dismiss this wizard.")
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.fgSecondary
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item { Layout.fillHeight: 2 }
    }
}
