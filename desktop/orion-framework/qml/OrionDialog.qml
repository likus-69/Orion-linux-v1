// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/OrionDialog.qml — modal dialog with title, content, and actions.

import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

Dialog {
    id: dialog

    property string titleText: ""
    property var actions: []  // list of {text, role, onClicked}

    modal: true
    anchors.centerIn: parent
    padding: Theme.space5

    background: Rectangle {
        color: Theme.surface2
        border.width: 1
        border.color: Theme.borderSubtle
        radius: Theme.radiusXl
    }

    header: Item {
        implicitWidth: parent.width
        implicitHeight: titleLabel.implicitHeight + Theme.space4

        Text {
            id: titleLabel
            text: dialog.titleText
            font.family: Theme.fontFamily
            font.pixelSize: 18
            font.weight: 600
            color: Theme.fgPrimary
            topPadding: Theme.space4
            leftPadding: Theme.space5
        }
    }

    footer: Item {
        implicitWidth: parent.width
        implicitHeight: actionsRow.implicitHeight + Theme.space4

        Row {
            id: actionsRow
            anchors.right: parent.right
            anchors.rightMargin: Theme.space5
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.space4
            spacing: Theme.space2

            Repeater {
                model: dialog.actions
                OrionButton {
                    required property var modelData
                    required property int index
                    text: modelData.text
                    variant: (modelData.role === "primary")
                        ? OrionButton.Variant.Primary
                        : OrionButton.Variant.Secondary
                    onClicked: {
                        if (modelData.onClicked) modelData.onClicked();
                        dialog.close();
                    }
                }
            }
        }
    }
}
