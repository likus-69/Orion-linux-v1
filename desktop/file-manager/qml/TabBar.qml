// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/TabBar.qml — multi-tab interface for the file manager.
//
// Each tab has a title and a path (managed by Main.qml's `tabs` ListModel).
// A "+" button at the right edge opens a new tab at $HOME.
//
// Signals:
//   tabSelected(int i)
//   tabClosed(int i)
//   newTabRequested()

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Rectangle {
    id: root
    implicitHeight: 40
    color: Theme.surface1

    // The ListModel of tabs. Each row has {path, title} roles.
    property var tabsModel
    property int activeIndex: 0

    signal tabSelected(int i)
    signal tabClosed(int i)
    signal newTabRequested()

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.borderSubtle
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Scrollable tab row.
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: tabRow.width
            contentHeight: tabRow.height
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            Row {
                id: tabRow
                spacing: 0

                Repeater {
                    model: root.tabsModel

                    Item {
                        width: tabButton.implicitWidth + 32
                        height: 40

                        Rectangle {
                            id: tabBg
                            anchors.fill: parent
                            color: root.activeIndex === index
                                ? Theme.surface2
                                : Theme.surface1
                            Behavior on color { ColorAnimation { duration: Theme.motionFast } }

                            // Active-tab underline indicator.
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width - 2 * Theme.space3
                                height: 2
                                color: Theme.accent500
                                visible: root.activeIndex === index
                            }
                        }

                        Row {
                            id: tabButton
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.space3
                            spacing: Theme.space2

                            OrionIcon {
                                source: "folder"
                                size: 16
                                anchors.verticalCenter: parent.verticalCenter
                                tint: root.activeIndex === index
                                    ? Theme.accent500
                                    : Theme.fgSecondary
                            }

                            Text {
                                text: model.title
                                anchors.verticalCenter: parent.verticalCenter
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                font.weight: root.activeIndex === index
                                    ? Font.DemiBold : Font.Normal
                                color: root.activeIndex === index
                                    ? Theme.fgPrimary
                                    : Theme.fgSecondary
                                elide: Text.ElideRight
                                width: Math.min(120, implicitWidth)
                            }

                            // Close button (×) — hidden on the last tab.
                            Item {
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter
                                visible: root.tabsModel.count > 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "×"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 16
                                    color: closeMa.containsMouse
                                        ? Theme.danger
                                        : Theme.fgTertiary
                                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                                }
                                MouseArea {
                                    id: closeMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.tabClosed(index)
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: function(mouse) {
                                if (mouse.button === Qt.MiddleButton) {
                                    root.tabClosed(index);
                                } else {
                                    root.tabSelected(index);
                                }
                            }
                        }
                    }
                }
            }
        }

        // New-tab button.
        Item {
            width: 36
            height: 36
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.centerIn: parent
                width: 28
                height: 28
                radius: Theme.radiusMd
                color: newTabMa.containsMouse ? Theme.surface3
                      : newTabMa.pressed ? Theme.surface4
                      : "transparent"
                Behavior on color { ColorAnimation { duration: Theme.motionFast } }

                Text {
                    anchors.centerIn: parent
                    text: "+"
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    color: newTabMa.containsMouse ? Theme.accent500 : Theme.fgPrimary
                }
            }
            MouseArea {
                id: newTabMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.newTabRequested()
            }
        }
    }
}
