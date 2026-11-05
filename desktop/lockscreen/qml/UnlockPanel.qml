// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework

Item {
    id: panel
    implicitWidth: 360
    implicitHeight: 140

    Rectangle {
        anchors.fill: parent
        color: Theme.surface2
        radius: Theme.radiusXl
        border.width: 1
        border.color: Theme.borderSubtle
        opacity: 0.92
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.space4
        spacing: Theme.space3

        RowLayout {
            Layout.fillWidth: true; spacing: Theme.space3

            Rectangle {
                width: 40; height: 40; radius: 20
                color: Theme.accent500
                Text {
                    anchors.centerIn: parent
                    text: locker.username.charAt(0).toUpperCase()
                    font.family: Theme.fontFamily
                    font.pixelSize: 18; font.weight: Font.DemiBold
                    color: Theme.fgInverse
                }
            }
            Text {
                text: locker.username
                font.family: Theme.fontFamily; font.pixelSize: 16
                font.weight: Font.DemiBold; color: Theme.fgPrimary
                Layout.fillWidth: true
            }
        }

        TextField {
            id: passwordField
            Layout.fillWidth: true
            echoMode: TextInput.Password
            placeholderText: qsTr("Enter password")
            font.family: Theme.fontFamily; font.pixelSize: 15
            color: Theme.fgPrimary
            onAccepted: {
                locker.tryUnlock(passwordField.text);
                passwordField.text = "";
            }
            background: Rectangle {
                implicitWidth: 200; implicitHeight: 36
                color: Theme.surface1
                radius: Theme.radiusMd
                border.width: 1
                border.color: passwordField.activeFocus ? Theme.accent500 : Theme.borderDefault
            }
            Keys.onPressed: (e) => {
                if (e.key === Qt.Key_Escape) passwordField.text = "";
            }
            focus: true
        }

        Text {
            id: errorText
            text: qsTr("Incorrect password")
            visible: false
            color: Theme.danger
            font.family: Theme.fontFamily; font.pixelSize: 12
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Connections {
        target: locker
        function onUnlockFailed() { errorText.visible = true; }
        function onUnlockSucceeded() { errorText.visible = false; }
    }
}
