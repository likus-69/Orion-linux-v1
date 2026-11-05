// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/OrionTextField.qml — text input with label, hint, and error states.

import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

TextField {
    id: field

    property string label: ""
    property string hint: ""
    property string errorText: ""
    property bool hasError: errorText.length > 0

    implicitHeight: 36
    implicitWidth: 280
    font.family: Theme.fontFamily
    font.pixelSize: 14
    color: hasError ? Theme.danger : (enabled ? Theme.fgPrimary : Theme.fgDisabled)
    selectByMouse: true

    background: Rectangle {
        implicitWidth: field.implicitWidth
        implicitHeight: field.implicitHeight
        radius: Theme.radiusMd
        color: Theme.surface1
        border.width: 1
        border.color: field.hasError
            ? Theme.danger
            : (field.activeFocus ? Theme.accent500 : Theme.borderDefault)

        Behavior on border.color { ColorAnimation { duration: Theme.motionFast } }
    }

    // Label above the field.
    Label {
        text: field.label
        visible: field.label.length > 0
        anchors.bottom: parent.top
        anchors.bottomMargin: Theme.space1
        anchors.left: parent.left
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.weight: 600
        color: Theme.fgSecondary
    }

    // Hint below the field.
    Label {
        id: hintLabel
        text: field.hasError ? field.errorText : field.hint
        visible: text.length > 0
        anchors.top: parent.bottom
        anchors.topMargin: Theme.space1
        anchors.left: parent.left
        font.family: Theme.fontFamily
        font.pixelSize: 11
        color: field.hasError ? Theme.danger : Theme.fgTertiary
    }

    padding: Theme.space3
    leftPadding: Theme.space3
    rightPadding: Theme.space3
    verticalAlignment: TextInput.AlignVCenter
}
