// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        Text {
            text: qsTr("Test your audio")
            font.family: Theme.fontFamily
            font.pixelSize: 22
            font.weight: Font.DemiBold
            color: Theme.fgPrimary
        }
        Text {
            text: qsTr("Adjust the volume and play a test tone to confirm speakers are working.")
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.fgSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space4

            Text {
                text: qsTr("Output volume:")
                font.family: Theme.fontFamily
                font.pixelSize: 14
                color: Theme.fgPrimary
            }

            Slider {
                from: 0; to: 100; value: 60
                Layout.fillWidth: true
            }

            Text {
                text: qsTr("60%")
                font.family: Theme.fontFamily
                font.pixelSize: 13
                color: Theme.fgSecondary
            }
        }

        OrionButton {
            text: qsTr("Play test tone")
            variant: OrionButton.Variant.Primary
            onClicked: {
                var p = Qt.createQmlObject('import QtProcess; Process { command: ["paplay", "/usr/share/sounds/freedesktop/stereo/bell.oga"] }', window);
                // (placeholder; real impl would use QProcess directly)
            }
        }
    }
}
