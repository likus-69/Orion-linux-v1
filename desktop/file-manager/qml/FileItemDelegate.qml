// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/FileItemDelegate.qml — row (List/Compact) and cell (Icon) delegate.
//
// Properties:
//   viewMode     "list" | "icon" | "compact"
//   name         file/folder display name
//   path         absolute path
//   iconSource   freedesktop icon name
//   sizeText     pre-formatted size ("1.2 MB" or "—")
//   mtimeText    pre-formatted mtime
//   isDir        true for directories
//   isSymlink    true for symbolic links
//   isSelected   selection state
//
// Signals:
//   clicked()
//   doubleClicked()
//   rightClicked()
//   renameRequested(string oldName)
//   deleteRequested(var paths)
//   trashRequested(var paths)
//   copyRequested(var paths)
//   moveRequested(var paths)

import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

Item {
    id: root

    property string viewMode: "list"
    property string name: ""
    property string path: ""
    property string iconSource: ""
    property string sizeText: ""
    property string mtimeText: ""
    property bool isDir: false
    property bool isSymlink: false
    property bool isSelected: false

    signal clicked()
    signal doubleClicked()
    signal rightClicked()
    signal renameRequested(string oldName)
    signal deleteRequested(var paths)
    signal trashRequested(var paths)
    signal copyRequested(var paths)
    signal moveRequested(var paths)

    implicitHeight: viewMode === "icon" ? 110
                  : viewMode === "compact" ? 28
                  : 44

    Rectangle {
        id: bg
        anchors.fill: parent
        color: root.isSelected
            ? Theme.accent500.withAlphaF(0.15)
            : (hover.hovered ? Theme.surface3 : Theme.surface1)
        Behavior on color { ColorAnimation { duration: Theme.motionFast } }

        // Selection indicator bar (left side, list mode).
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 3
            color: Theme.accent500
            visible: root.isSelected && root.viewMode !== "icon"
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.clicked()
        onDoubleTapped: root.doubleClicked()
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: root.rightClicked()
    }

    // ===== List view layout =====
    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.space3
        anchors.rightMargin: Theme.space3
        spacing: Theme.space3
        visible: root.viewMode === "list"

        OrionIcon {
            id: listIcon
            source: root.iconSource
            size: 24
            anchors.verticalCenter: parent.verticalCenter
            tint: root.isDir ? Theme.accent500 : Theme.fgPrimary
        }

        Column {
            width: parent.width
                - listIcon.width
                - sizeTextCol.implicitWidth
                - mtimeCol.implicitWidth
                - 3 * Theme.space3
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text: root.name + (root.isSymlink ? "  ↪" : "")
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.weight: root.isSelected ? Font.DemiBold : Font.Normal
                color: root.isDir ? Theme.accent500 : Theme.fgPrimary
                elide: Text.ElideRight
                width: parent.width
            }
            Text {
                text: root.mtimeText
                visible: root.viewMode === "list"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.fgTertiary
                elide: Text.ElideRight
                width: parent.width
            }
        }

        Text {
            id: sizeTextCol
            text: root.sizeText
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: Theme.fgSecondary
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: mtimeCol
            text: root.mtimeText
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: Theme.fgTertiary
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
            visible: root.viewMode === "list"
        }
    }

    // ===== Compact view layout (single-line, no mtime) =====
    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.space2
        anchors.rightMargin: Theme.space2
        spacing: Theme.space2
        visible: root.viewMode === "compact"

        OrionIcon {
            source: root.iconSource
            size: 16
            anchors.verticalCenter: parent.verticalCenter
            tint: root.isDir ? Theme.accent500 : Theme.fgPrimary
        }

        Text {
            text: root.name
            font.family: Theme.fontFamily
            font.pixelSize: 13
            color: root.isDir ? Theme.accent500 : Theme.fgPrimary
            elide: Text.ElideRight
            width: parent.width - 24 - 80 - 2 * Theme.space2
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.sizeText
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: Theme.fgTertiary
            horizontalAlignment: Text.AlignRight
            width: 80
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ===== Icon view layout (grid cell) =====
    Column {
        anchors.fill: parent
        anchors.margins: Theme.space2
        spacing: Theme.space1
        visible: root.viewMode === "icon"

        Item {
            width: parent.width
            height: parent.height - labelCol.height - Theme.space1
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                // Subtle hover/selected background tile behind the icon.
                anchors.centerIn: parent
                width: 64
                height: 64
                radius: Theme.radiusMd
                color: root.isSelected
                    ? Theme.accent500.withAlphaF(0.18)
                    : (hover.hovered ? Theme.surface3
                                       : Theme.surface1.withAlpha(0))
                Behavior on color { ColorAnimation { duration: Theme.motionFast } }
            }

            OrionIcon {
                anchors.centerIn: parent
                source: root.iconSource
                size: 48
                tint: root.isDir ? Theme.accent500 : Theme.fgPrimary
            }
        }

        Column {
            id: labelCol
            width: parent.width
            spacing: 0

            Text {
                text: root.name
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: root.isSelected ? Theme.accent500 : Theme.fgPrimary
                font.weight: root.isSelected ? Font.DemiBold : Font.Normal
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideMiddle
                width: parent.width
                wrapMode: Text.Wrap
                maximumLineCount: 2
            }

            Text {
                text: root.sizeText
                font.family: Theme.fontFamily
                font.pixelSize: 10
                color: Theme.fgTertiary
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                visible: !root.isDir
            }
        }
    }
}
