// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        Text {
            text: qsTr("Check your display")
            font.family: Theme.fontFamily
            font.pixelSize: 22
            font.weight: Font.DemiBold
            color: Theme.fgPrimary
        }
        Text {
            text: qsTr("Adjust scaling if text looks too small or too large. You can fine-tune in Settings → System → Display.")
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.fgSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.space2
            Text {
                text: qsTr("Display scaling:")
                font.family: Theme.fontFamily
                font.pixelSize: 14
                color: Theme.fgPrimary
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.space2
                Repeater {
                    model: ["100%", "125%", "150%", "200%"]
                    OrionButton {
                        text: modelData
                        variant: OrionButton.Variant.Secondary
                        Layout.fillWidth: true
                        checkable: true
                        checked: index === 1
                    }
                }
            }
        }

        Text {
            text: qsTr("Resolution: 1920x1080 @ 60 Hz\nDisplay: Built-in (Laptop)")
            font.family: Theme.fontFamilyMono
            font.pixelSize: 13
            color: Theme.fgSecondary
        }
    }
}
