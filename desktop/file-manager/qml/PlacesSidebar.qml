// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/PlacesSidebar.qml — left sidebar listing standard places + mounts.
//
// Renders the PlacesModel rows. Clicking a row emits placeClicked(path).

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Rectangle {
    id: root
    color: Theme.surface1

    signal placeClicked(string path)

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: Theme.borderSubtle
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header label.
        Text {
            text: qsTr("Places")
            Layout.topMargin: Theme.space3
            Layout.leftMargin: Theme.space4
            Layout.rightMargin: Theme.space4
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.letterSpacing: 0.6
            color: Theme.fgTertiary
            textFormat: Text.PlainText
        }

        // Scrollable list of places.
        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: Theme.space2
            clip: true
            model: places
            spacing: 0
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
                width: list.width
                height: 36

                Rectangle {
                    id: rowBg
                    anchors.fill: parent
                    anchors.leftMargin: Theme.space1
                    anchors.rightMargin: Theme.space1
                    radius: Theme.radiusMd
                    color: rowMa.containsMouse
                        ? Theme.surface3
                        : (path === fileSystem.currentPath
                            ? Theme.accent500.withAlphaF(0.12)
                            : "transparent")
                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }

                    // Selection indicator bar.
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 0
                        width: 3
                        color: Theme.accent500
                        visible: path === fileSystem.currentPath
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.space3
                    anchors.rightMargin: Theme.space3
                    spacing: Theme.space3

                    OrionIcon {
                        source: model.icon
                        size: 18
                        anchors.verticalCenter: parent.verticalCenter
                        tint: model.isSpecial ? Theme.accent500 : Theme.fgPrimary
                    }

                    Text {
                        text: model.name
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.weight: path === fileSystem.currentPath
                            ? Font.DemiBold : Font.Normal
                        color: path === fileSystem.currentPath
                            ? Theme.fgPrimary : Theme.fgSecondary
                        elide: Text.ElideRight
                        width: parent.width - 24 - Theme.space3
                    }
                }

                MouseArea {
                    id: rowMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.placeClicked(model.path)
                }
            }

            ScrollBar.vertical: ScrollBar { }
        }

        // Separator + section header for mounts.
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.space3
            Layout.rightMargin: Theme.space3
            height: 1
            color: Theme.borderSubtle
            visible: mounts.count > 0
        }

        Text {
            text: qsTr("Devices")
            visible: mounts.count > 0
            Layout.topMargin: Theme.space3
            Layout.leftMargin: Theme.space4
            Layout.rightMargin: Theme.space4
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.letterSpacing: 0.6
            color: Theme.fgTertiary
            textFormat: Text.PlainText
        }

        // Mounts list (uses the MountsModel directly so each row shows
        // free-space info).
        ListView {
            id: mountsList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 240)
            Layout.topMargin: Theme.space2
            Layout.bottomMargin: Theme.space3
            clip: true
            model: mounts
            spacing: 0
            visible: mounts.count > 0
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
                width: mountsList.width
                height: 44

                Rectangle {
                    id: mountBg
                    anchors.fill: parent
                    anchors.leftMargin: Theme.space1
                    anchors.rightMargin: Theme.space1
                    radius: Theme.radiusMd
                    color: mountMa.containsMouse
                        ? Theme.surface3
                        : (mountPath === fileSystem.currentPath
                            ? Theme.accent500.withAlphaF(0.12)
                            : "transparent")
                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                }

                Column {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.space3
                    anchors.rightMargin: Theme.space3
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    Row {
                        spacing: Theme.space3
                        width: parent.width

                        OrionIcon {
                            source: model.icon
                            size: 18
                            anchors.verticalCenter: parent.verticalCenter
                            tint: model.isNetwork ? Theme.fgSecondary : Theme.fgPrimary
                        }

                        Text {
                            text: model.name
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            color: Theme.fgPrimary
                            elide: Text.ElideRight
                            width: parent.width - 24 - Theme.space3 - 80
                        }

                        Text {
                            text: model.freeBytesFormatted
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: Theme.fgTertiary
                            horizontalAlignment: Text.AlignRight
                            width: 80
                        }
                    }

                    Text {
                        text: model.mountPath
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        color: Theme.fgTertiary
                        elide: Text.ElideMiddle
                        width: parent.width
                        anchors.left: parent.left
                        anchors.leftMargin: 24 + Theme.space3
                    }
                }

                MouseArea {
                    id: mountMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.placeClicked(model.mountPath)
                }
            }

            ScrollBar.vertical: ScrollBar { }
        }
    }
}
