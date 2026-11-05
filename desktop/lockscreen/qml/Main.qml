// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework
import org.orion.lockscreen

ApplicationWindow {
    id: window
    width: Screen.width; height: Screen.height; visible: true
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
    color: "transparent"

    Image {
        anchors.fill: parent
        source: "file:///usr/share/orion/wallpapers/orion-dark.png"
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.4)
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.space5

        // Big clock
        ColumnLayout {
            spacing: Theme.space1
            Layout.alignment: Qt.AlignHCenter
            Text {
                text: locker.currentTime
                font.family: Theme.fontFamily; font.pixelSize: 96
                font.weight: Font.DemiBold; color: "#FFFFFF"
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: locker.currentDate
                font.family: Theme.fontFamily; font.pixelSize: 18
                color: Qt.rgba(1, 1, 1, 0.7)
                Layout.alignment: Qt.AlignHCenter
            }
        }

        Item { Layout.preferredHeight: 60 }

        // Unlock panel
        UnlockPanel {
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Connections {
        target: locker
        function onUnlockSucceeded() { Qt.quit(); }
    }
}
