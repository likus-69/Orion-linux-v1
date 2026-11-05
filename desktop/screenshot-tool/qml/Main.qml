// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework
import org.orion.screenshot

ApplicationWindow {
    id: window
    width: 480; height: 280; visible: true
    title: qsTr("Orion Screenshot")
    color: Theme.surface0
    flags: Qt.Window | Qt.WindowStaysOnTopHint

    ColumnLayout {
        anchors.fill: parent; anchors.margins: Theme.space5; spacing: Theme.space4

        Text {
            text: qsTr("Capture a screenshot")
            font.family: Theme.fontFamily; font.pixelSize: 20
            font.weight: Font.DemiBold; color: Theme.fgPrimary
        }

        ColumnLayout {
            Layout.fillWidth: true; spacing: Theme.space2

            OrionButton {
                text: qsTr("Capture full screen")
                Layout.fillWidth: true
                onClicked: { shot.captureFullScreen(); Qt.quit(); }
            }
            OrionButton {
                text: qsTr("Capture active window")
                Layout.fillWidth: true
                variant: OrionButton.Variant.Secondary
                onClicked: { shot.captureActiveWindow(); Qt.quit(); }
            }
            OrionButton {
                text: qsTr("Capture region")
                Layout.fillWidth: true
                variant: OrionButton.Variant.Secondary
                onClicked: overlay.visible = true
            }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: Theme.space3
            Switch { id: delay; text: qsTr("Delay 3 seconds") }
            Switch { id: copyClipboard; text: qsTr("Copy to clipboard") }
        }
    }

    // Region selection overlay.
    CaptureOverlay {
        id: overlay
        anchors.fill: parent
        visible: false
        onRegionSelected: (x, y, w, h) => {
            shot.captureRegion(x, y, w, h);
            overlay.visible = false;
            Qt.quit();
        }
        onCanceled: overlay.visible = false
    }
}
