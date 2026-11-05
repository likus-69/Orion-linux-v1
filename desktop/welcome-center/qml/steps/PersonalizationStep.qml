// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        Text {
            text: qsTr("Pick your look")
            font.family: Theme.fontFamily
            font.pixelSize: 22
            font.weight: Font.DemiBold
            color: Theme.fgPrimary
        }
        Text {
            text: qsTr("Choose a theme. You can change this any time in Settings → Personalization.")
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.fgSecondary
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 180
            cellHeight: 130
            clip: true
            model: [
                { name: "orion-dark",       label: qsTr("Orion Dark"),     accent: Theme.accent500 },
                { name: "orion-light",       label: qsTr("Orion Light"),    accent: Theme.accent500 },
                { name: "orion-midnight",    label: qsTr("Midnight"),       accent: "#7C5CFF" },
                { name: "orion-aurora",      label: qsTr("Aurora"),         accent: "#2FB57C" },
                { name: "orion-high-contrast", label: qsTr("High Contrast"), accent: "#FFFFFF" }
            ]

            delegate: Rectangle {
                width: 170; height: 120
                radius: Theme.radiusLg
                color: modelData.name === "orion-light" ? "#FFFFFF" :
                       modelData.name === "orion-dark" ? "#0B0F1A" :
                       modelData.name === "orion-midnight" ? "#04060B" :
                       modelData.name === "orion-aurora" ? "#0A1A14" : "#000000"
                border.width: 2
                border.color: Theme.accent500

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.space2
                    Text {
                        text: modelData.label
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: modelData.name === "orion-light" ? "#1A1F2E" : "#FFFFFF"
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }
                    Rectangle {
                        width: 24; height: 6
                        radius: 3
                        color: modelData.accent
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: welcome.setTheme(modelData.name)
                }
            }
        }
    }
}
