// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/Breadcrumb.qml — clickable path segments shown above the file area.
//
// Renders one button per path segment from root to the current directory.
// Clicking any segment emits segmentClicked(path) so the parent can
// navigate there. The rightmost segment is non-interactive (it's the
// current folder).

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: 36
    color: Theme.surface1

    property string currentPath: ""
    signal segmentClicked(string path)

    // Rebuild the segments whenever currentPath changes.
    onCurrentPathChanged: rebuildModel()

    function rebuildModel() {
        var crumbs = fileSystem.breadcrumbs();
        crumbsModel.clear();
        for (var i = 0; i < crumbs.length; ++i) {
            crumbsModel.append({
                name: crumbs[i].name,
                path: crumbs[i].path,
                isLast: i === crumbs.length - 1
            });
        }
    }

    ListModel { id: crumbsModel }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.borderSubtle
    }

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: Theme.space3
        anchors.rightMargin: Theme.space3
        contentWidth: row.width
        contentHeight: row.height
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        Row {
            id: row
            spacing: 0
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: crumbsModel

                Row {
                    spacing: 0

                    // Separator chevron between segments.
                    OrionIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        source: "go-next"
                        size: 12
                        tint: Theme.fgTertiary
                        visible: index > 0
                    }

                    // Segment label.
                    Item {
                        id: seg
                        width: label.implicitWidth + 2 * Theme.space2
                        height: 28
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            id: bg
                            anchors.fill: parent
                            radius: Theme.radiusSm
                            color: segMouse.containsMouse
                                ? Theme.surface3
                                : (model.isLast ? Theme.surface2 : "transparent")
                            Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                        }

                        Text {
                            id: label
                            anchors.centerIn: parent
                            text: model.name
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            font.weight: model.isLast ? Font.DemiBold : Font.Normal
                            color: model.isLast ? Theme.fgPrimary : Theme.fgSecondary
                        }

                        MouseArea {
                            id: segMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: model.isLast ? Qt.ArrowCursor
                                                       : Qt.PointingHandCursor
                            onClicked: {
                                if (!model.isLast) {
                                    root.segmentClicked(model.path);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
