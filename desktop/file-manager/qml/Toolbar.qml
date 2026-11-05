// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/Toolbar.qml — top toolbar of the file manager.
//
// Layout (left → right):
//   [Back] [Forward] [Up]  |  Breadcrumb (clickable path)  |  [View toggle] [Show hidden] [Search]
//
// Signals:
//   backClicked()
//   forwardClicked()
//   upClicked()
//   searchChanged(string q)
//   viewModeChanged(string mode)   // "list" | "icon" | "compact"
//   toggleHidden()

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Rectangle {
    id: root
    implicitHeight: 52
    color: Theme.surface1

    property bool canGoBack: false
    property bool canGoForward: false
    property bool showHidden: false
    property bool searchEnabled: true

    signal backClicked()
    signal forwardClicked()
    signal upClicked()
    signal searchChanged(string q)
    signal viewModeChanged(string mode)
    signal toggleHidden()

    function focusBreadcrumb() {
        // For v1, focusing the breadcrumb is implemented as clearing the
        // search field and focusing it. The user can then type a path
        // prefix to filter. A future revision will provide an inline
        // path-edit mode.
        searchField.forceActiveFocus();
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.borderSubtle
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.space2
        anchors.rightMargin: Theme.space2
        spacing: Theme.space2

        // Back / Forward / Up nav cluster.
        Row {
            spacing: 0
            Layout.alignment: Qt.AlignVCenter

            // Back
            Item {
                width: 36
                height: 36
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusMd
                    color: backMa.containsMouse ? Theme.surface3
                          : backMa.pressed ? Theme.surface4
                          : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                    opacity: root.canGoBack ? 1 : 0.4
                }
                OrionIcon {
                    anchors.centerIn: parent
                    source: "go-previous"
                    size: 20
                    tint: root.canGoBack ? Theme.fgPrimary : Theme.fgDisabled
                }
                MouseArea {
                    id: backMa
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: root.canGoBack
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.backClicked()
                }
            }

            // Forward
            Item {
                width: 36
                height: 36
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusMd
                    color: fwdMa.containsMouse ? Theme.surface3
                          : fwdMa.pressed ? Theme.surface4
                          : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                    opacity: root.canGoForward ? 1 : 0.4
                }
                OrionIcon {
                    anchors.centerIn: parent
                    source: "go-next"
                    size: 20
                    tint: root.canGoForward ? Theme.fgPrimary : Theme.fgDisabled
                }
                MouseArea {
                    id: fwdMa
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: root.canGoForward
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.forwardClicked()
                }
            }

            // Up
            Item {
                width: 36
                height: 36
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusMd
                    color: upMa.containsMouse ? Theme.surface3
                          : upMa.pressed ? Theme.surface4
                          : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                }
                OrionIcon {
                    anchors.centerIn: parent
                    source: "go-up"
                    size: 20
                    tint: Theme.fgPrimary
                }
                MouseArea {
                    id: upMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.upClicked()
                }
            }
        }

        // Breadcrumb area (visual placeholder; the actual clickable
        // breadcrumb is rendered by Breadcrumb.qml below the toolbar
        // in Main.qml. This slot just shows the current path text).
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.space3
                text: fileSystem.currentPath
                font.family: Theme.fontFamily
                font.pixelSize: 14
                color: Theme.fgSecondary
                elide: Text.ElideMiddle
                width: parent.width - 2 * Theme.space3
            }
        }

        // View mode toggle.
        Row {
            spacing: 0
            Layout.alignment: Qt.AlignVCenter

            Item {
                width: 36; height: 36
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusMd
                    color: viewMenu.containsMouse ? Theme.surface3
                          : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                }
                OrionIcon {
                    anchors.centerIn: parent
                    source: "view-list"
                    size: 20
                    tint: Theme.fgPrimary
                }
                MouseArea {
                    id: viewMenu
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: viewToggleMenu.popup(parent, 0, parent.height + 4)
                }

                OrionMenu {
                    id: viewToggleMenu
                    MenuItem {
                        text: qsTr("List view")
                        checkable: true
                        checked: true
                        onTriggered: root.viewModeChanged("list")
                    }
                    MenuItem {
                        text: qsTr("Icon view")
                        onTriggered: root.viewModeChanged("icon")
                    }
                    MenuItem {
                        text: qsTr("Compact view")
                        onTriggered: root.viewModeChanged("compact")
                    }
                }
            }

            // Show hidden files toggle.
            Item {
                width: 36; height: 36
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusMd
                    color: hiddenMa.containsMouse ? Theme.surface3
                          : (root.showHidden ? Theme.surface4 : "transparent")
                    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                }
                OrionIcon {
                    anchors.centerIn: parent
                    source: root.showHidden ? "view-hidden-files" : "view-visible"
                    size: 20
                    tint: root.showHidden ? Theme.accent500 : Theme.fgPrimary
                }
                MouseArea {
                    id: hiddenMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleHidden()
                }
            }
        }

        // Search field.
        TextField {
            id: searchField
            Layout.preferredWidth: 220
            Layout.alignment: Qt.AlignVCenter
            placeholderText: qsTr("Search current folder…")
            font.family: Theme.fontFamily
            font.pixelSize: 14
            selectByMouse: true
            background: Rectangle {
                implicitHeight: 36
                implicitWidth: 220
                radius: Theme.radiusMd
                color: Theme.surface1
                border.width: 1
                border.color: searchField.activeFocus
                    ? Theme.accent500
                    : Theme.borderDefault
                Behavior on border.color {
                    ColorAnimation { duration: Theme.motionFast }
                }
            }
            onTextEdited: root.searchChanged(text)
            Keys.onEscapePressed: {
                text = "";
                root.searchChanged("");
            }
        }
    }
}
