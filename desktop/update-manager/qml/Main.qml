// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework
import org.orion.updatemanager

ApplicationWindow {
    width: 600; height: 480; visible: false
    title: qsTr("Orion Update Manager")
    color: Theme.surface0
    flags: Qt.Window

    ColumnLayout {
        anchors.fill: parent; anchors.margins: Theme.space4; spacing: Theme.space4

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: updates.pendingCount + qsTr(" updates available")
                font.family: Theme.fontFamily; font.pixelSize: 20
                font.weight: Font.DemiBold; color: Theme.fgPrimary
                Layout.fillWidth: true
            }
            OrionButton {
                text: qsTr("Check now")
                variant: OrionButton.Variant.Secondary
                onClicked: updates.checkForUpdates()
                enabled: !updates.busy
            }
            OrionButton {
                text: qsTr("Update all")
                variant: OrionButton.Variant.Primary
                onClicked: updates.applyAll()
                enabled: updates.pendingCount > 0 && !updates.busy
            }
        }

        UpdateList {
            Layout.fillWidth: true; Layout.fillHeight: true
        }
    }
}
