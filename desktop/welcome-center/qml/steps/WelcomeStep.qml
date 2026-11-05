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
            sourceSize.width: 96
            sourceSize.height: 96
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: qsTr("Welcome to Orion OS")
            font.family: Theme.fontFamily
            font.pixelSize: 32
            font.weight: Font.DemiBold
            color: Theme.fgPrimary
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: qsTr("A polished, Arch-Linux-based desktop operating system.\nLet's get you set up in a few short steps.")
            font.family: Theme.fontFamily
            font.pixelSize: 15
            color: Theme.fgSecondary
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Item { Layout.fillHeight: 2 }
    }
}
