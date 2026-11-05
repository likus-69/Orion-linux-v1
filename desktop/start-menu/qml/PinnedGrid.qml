// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors

import QtQuick
import org.orion.framework

Item {
    id: grid
    implicitHeight: 320
    implicitWidth: parent ? parent.width : 600

    property int columns: 6
    property int cellSize: 76

    Text {
        text: qsTr("Pinned")
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.weight: Font.DemiBold
        color: Theme.fgSecondary
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: Theme.space2
    }

    GridView {
        id: gv
        anchors.fill: parent
        anchors.topMargin: 28
        cellWidth: grid.cellSize
        cellHeight: grid.cellSize
        model: appIndex.pinnedApps
        clip: true

        delegate: Item {
            width: gv.cellWidth
            height: gv.cellHeight

            Column {
                anchors.centerIn: parent
                spacing: Theme.space2

                Rectangle {
                    width: 48; height: 48
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: parent.hovered ? Theme.surface3 : "transparent"
                    radius: Theme.radiusMd
                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }

                    OrionIcon {
                        anchors.centerIn: parent
                        source: modelData.icon || "icon-application"
                        size: 36
                    }

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.RightButton) {
                                contextMenu.popup();
                            } else {
                                appIndex.launch(modelData.desktopFileId);
                                menu.hide();
                            }
                        }
                    }

                    Menu {
                        id: contextMenu
                        MenuItem {
                            text: qsTr("Unpin from Start")
                            onTriggered: appIndex.togglePin(modelData.desktopFileId);
                        }
                        MenuItem {
                            text: qsTr("Open")
                            onTriggered: {
                                appIndex.launch(modelData.desktopFileId);
                                menu.hide();
                            }
                        }
                    }
                }

                Text {
                    text: modelData.name
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.fgPrimary
                    elide: Text.ElideRight
                    width: parent ? parent.parent.width - Theme.space2 : 64
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
