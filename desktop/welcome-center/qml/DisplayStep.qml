// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/DisplayStep.qml — Step 5.
//
// Display check. Reads the current resolution and scaling factor from
// wlr-randr (Wayland) and shows a summary. The user can open Orion
// Settings for full control — the welcome center doesn't change display
// mode itself because that requires polkit on most compositors.

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    id: step
    Layout.fillWidth: true
    Layout.fillHeight: true

    property var displayInfo: ({})

    Component.onCompleted: refresh()

    function refresh() {
        displayInfo = welcomeController.getDisplayInfo();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        OrionLabel {
            role: OrionLabel.Role.H1
            text: qsTr("Check your display")
        }
        OrionLabel {
            role: OrionLabel.Role.Body
            tint: Theme.fgSecondary
            text: qsTr("Orion OS uses wlr-randr to read display info. Below is a summary of your "
                      + "current resolution and scaling. Use Settings → System → Display to "
                      + "change them.")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Detected displays")
            subtitle: step.displayInfo.available
                ? qsTr("Reported by wlr-randr")
                : qsTr("wlr-randr not available — install it for full display control")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 480

                ListView {
                    width: parent.width
                    height: Math.max(120, contentHeight)
                    clip: true
                    model: step.displayInfo.available
                            ? (step.displayInfo.outputs || [])
                            : []
                    delegate: OrionListRow {
                        width: ListView.view.width
                        title: qsTr("Output: %1").arg(modelData.name)
                        subtitle: qsTr("Resolution: %1   Scale: %2×")
                                   .arg(modelData.current || qsTr("(unknown)"))
                                   .arg(modelData.scale.toFixed(2))
                        accessoryText: qsTr("%n mode(s) available", "",
                                             (modelData.modes || []).length)
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: parent.count === 0 && step.displayInfo.available
                        text: qsTr("No displays reported.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                    }
                }

                Text {
                    visible: !step.displayInfo.available
                    text: qsTr("Error: %1").arg(
                        step.displayInfo.error || qsTr("Unknown"))
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 12
                    color: Theme.warning
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        // Quick tip about scaling.
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Scaling tip")
            subtitle: qsTr("For HiDPI displays")

            contentItem: Column {
                spacing: Theme.space2
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Text {
                    text: qsTr("If text looks too small on a 4K display, set the scale to "
                              + "1.5× or 2× in Settings → System → Display. Orion OS uses "
                              + "fractional scaling via the wlroots viewporter protocol.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.fgSecondary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                OrionButton {
                    text: qsTr("Open Display settings")
                    variant: OrionButton.Variant.Secondary
                    size: OrionButton.Size.Compact
                    onClicked: welcomeController.openSettings()
                }
            }
        }

        Item { Layout.fillHeight: true; Layout.preferredHeight: Theme.space2 }
    }
}
