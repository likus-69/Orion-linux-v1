// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework
import org.orion.search

ApplicationWindow {
    id: window
    width: 640; height: 480; visible: false
    title: qsTr("Orion Search")
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.Popup | Qt.WindowStaysOnTopHint

    property string query: ""

    Rectangle {
        anchors.fill: parent; color: Theme.surface1; radius: Theme.radiusLg
        border.width: 1; border.color: Theme.borderSubtle

        ColumnLayout {
            anchors.fill: parent; anchors.margins: Theme.space4; spacing: Theme.space3

            TextField {
                id: q
                Layout.fillWidth: true
                placeholderText: qsTr("Search apps, files, settings…")
                font.family: Theme.fontFamily; font.pixelSize: 16
                onTextChanged: window.query = text
                Keys.onPressed: (e) => {
                    if (e.key === Qt.Key_Escape) window.visible = false;
                }
            }

            ListView {
                Layout.fillWidth: true; Layout.fillHeight: true
                clip: true; spacing: Theme.space1
                model: searchIndex.search(window.query, 30)
                delegate: ResultRow {
                    width: parent.width
                    icon: modelData.icon
                    title: modelData.title
                    subtitle: modelData.subtitle
                    category: modelData.category
                    onClicked: {
                        if (modelData.category === "app")
                            Qt.openUrlExternally(modelData.uri);
                        else if (modelData.category === "file")
                            Qt.openUrlExternally(modelData.uri);
                        else if (modelData.category === "setting")
                            Qt.openUrlExternally(modelData.uri);
                        window.visible = false;
                    }
                }
            }
        }
    }
}
