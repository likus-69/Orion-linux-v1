// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework
import org.orion.systemmonitor

ApplicationWindow {
    width: 800; height: 600; visible: true
    title: qsTr("Orion System Monitor")
    color: Theme.surface0

    ColumnLayout {
        anchors.fill: parent; anchors.margins: Theme.space4
        spacing: Theme.space4

        // Top metrics row
        RowLayout {
            Layout.fillWidth: true; spacing: Theme.space4

            // CPU card
            OrionCard {
                Layout.fillWidth: true; Layout.preferredHeight: 140
                title: qsTr("CPU")
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: Theme.space3; spacing: Theme.space2
                    Text {
                        text: metrics.cpuPercent + "%"
                        font.family: Theme.fontFamily; font.pixelSize: 28
                        font.weight: Font.DemiBold; color: Theme.accent500
                    }
                    CpuChart { Layout.fillWidth: true; Layout.fillHeight: true }
                }
            }

            // Memory card
            OrionCard {
                Layout.fillWidth: true; Layout.preferredHeight: 140
                title: qsTr("Memory")
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: Theme.space3; spacing: Theme.space2
                    Text {
                        text: (metrics.memUsedBytes / 1024 / 1024) + " / "
                            + (metrics.memTotalBytes / 1024 / 1024) + " MB"
                        font.family: Theme.fontFamily; font.pixelSize: 14
                        color: Theme.fgPrimary
                    }
                    Text {
                        text: metrics.memPercent + "%"
                        font.family: Theme.fontFamily; font.pixelSize: 22
                        font.weight: Font.DemiBold; color: Theme.accent500
                    }
                }
            }

            // Network card
            OrionCard {
                Layout.fillWidth: true; Layout.preferredHeight: 140
                title: qsTr("Network")
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: Theme.space3; spacing: Theme.space2
                    Text { text: "↓ " + metrics.netDownKbps + " KB/s"; color: Theme.success; font.family: Theme.fontFamilyMono; font.pixelSize: 13 }
                    Text { text: "↑ " + metrics.netUpKbps + " KB/s";   color: Theme.accent500; font.family: Theme.fontFamilyMono; font.pixelSize: 13 }
                }
            }
        }

        // Process list
        OrionCard {
            Layout.fillWidth: true; Layout.fillHeight: true
            title: qsTr("Processes")
            ProcessList {
                anchors.fill: parent; anchors.margins: Theme.space3
                anchors.topMargin: Theme.space4
            }
        }
    }
}
