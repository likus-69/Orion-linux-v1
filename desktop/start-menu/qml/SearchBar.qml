// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors

import QtQuick
import QtQuick.Layouts
import org.orion.framework

FocusScope {
    id: search
    property alias searchText: field.text
    signal searchTextChanged(string text)
    implicitHeight: 44
    implicitWidth: parent ? parent.width : 600

    Rectangle {
        anchors.fill: parent
        color: Theme.surface2
        radius: Theme.radiusLg
        border.width: 1
        border.color: field.activeFocus ? Theme.accent500 : Theme.borderDefault
        Behavior on border.color { ColorAnimation { duration: Theme.motionFast } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.space3
            anchors.rightMargin: Theme.space3
            spacing: Theme.space3

            OrionIcon {
                source: "icon-search"
                size: 20
                Layout.alignment: Qt.AlignVCenter
            }

            TextField {
                id: field
                Layout.fillWidth: true
                placeholderText: qsTr("Search apps and files")
                font.family: Theme.fontFamily
                font.pixelSize: 15
                color: Theme.fgPrimary
                selectByMouse: true
                background: Item {}
                focus: true

                onTextChanged: search.searchTextChanged(text)
                Keys.onPressed: (e) => {
                    if (e.key === Qt.Key_Down) allAppsListView.forceActiveFocus();
                }
            }
        }
    }
}
