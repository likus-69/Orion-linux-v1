// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import org.orion.framework

Item {
    property string repo: "extra"
    implicitWidth: tag.implicitWidth + 16
    implicitHeight: 20

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: repo === "aur"     ? Theme.warning.withAlphaF(0.18)
             : repo === "flatpak" ? Theme.accent500.withAlphaF(0.18)
             : repo === "orion"    ? Theme.accent500.withAlphaF(0.18)
             :                       Theme.success.withAlphaF(0.18)

        Text {
            id: tag
            anchors.centerIn: parent
            text: repo === "aur"    ? qsTr("AUR (community)")
                 : repo === "flatpak" ? qsTr("Flatpak")
                 : repo === "orion"   ? qsTr("Orion")
                 :                      qsTr("Arch")
            font.family: Theme.fontFamily
            font.pixelSize: 10
            font.weight: Font.DemiBold
            color: repo === "aur" ? Theme.warning : Theme.fgSecondary
        }
    }
}
