// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        Text {
            text: qsTr("Hardware check")
            font.family: Theme.fontFamily
            font.pixelSize: 22
            font.weight: Font.DemiBold
            color: Theme.fgPrimary
        }
        Text {
            text: qsTr("Orion OS scans your system for hardware that needs additional drivers.")
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.fgSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        OrionButton {
            text: qsTr("Run hardware scan")
            variant: OrionButton.Variant.Primary
            onClicked: {
                var result = welcome.runHardwareScan();
                resultText.text = JSON.stringify(result, null, 2);
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            TextArea {
                id: resultText
                readOnly: true
                font.family: Theme.fontFamilyMono
                font.pixelSize: 12
                color: Theme.fgSecondary
                background: Rectangle { color: Theme.surface1; radius: Theme.radiusMd }
                text: qsTr("Click 'Run hardware scan' to begin.")
            }
        }
    }
}
