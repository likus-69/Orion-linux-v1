// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

Item {
    ListView {
        id: lv
        anchors.fill: parent
        clip: true
        spacing: 0
        model: metrics.processes

        header: Rectangle {
            width: lv.width; height: 28; color: Theme.surface2
            Row {
                anchors.fill: parent; anchors.leftMargin: Theme.space3; spacing: Theme.space3
                Text { text: qsTr("PID");  width: 80;  font.family: Theme.fontFamilyMono; font.pixelSize: 12; color: Theme.fgSecondary }
                Text { text: qsTr("CPU%"); width: 80;  font.family: Theme.fontFamilyMono; font.pixelSize: 12; color: Theme.fgSecondary }
                Text { text: qsTr("MEM%"); width: 80;  font.family: Theme.fontFamilyMono; font.pixelSize: 12; color: Theme.fgSecondary }
                Text { text: qsTr("RSS");  width: 100; font.family: Theme.fontFamilyMono; font.pixelSize: 12; color: Theme.fgSecondary }
                Text { text: qsTr("Name"); width: parent ? parent.width - 360 : 200; font.family: Theme.fontFamilyMono; font.pixelSize: 12; color: Theme.fgSecondary }
            }
        }

        delegate: OrionListRow {
            width: lv.width
            title: modelData.name
            subtitle: "PID " + modelData.pid + "  ·  CPU " + modelData.cpu.toFixed(1) + "%  ·  MEM " + modelData.mem.toFixed(1) + "%"
            accessoryText: (modelData.rss / 1024).toFixed(0) + " MB"
            onClicked: {
                // Right-click context menu would offer Kill / Suspend / Continue.
                // v1: just kill with SIGTERM.
                // metrics.killProcess(modelData.pid);  // Uncomment when confirmed via dialog
            }
        }
    }
}
