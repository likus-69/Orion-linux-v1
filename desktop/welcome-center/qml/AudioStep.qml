// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/AudioStep.qml — Step 4.
//
// Audio check. Plays a test tone (freedesktop bell sound via paplay or
// pw-play) and shows a volume slider that adjusts the default sink via
// pactl. The user can play the tone as many times as they like; the
// slider updates the system volume immediately.

import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    id: step
    Layout.fillWidth: true
    Layout.fillHeight: true

    property int currentVolume: 50

    Component.onCompleted: {
        const v = welcomeController.getVolume();
        if (v >= 0) currentVolume = v;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space4

        OrionLabel {
            role: OrionLabel.Role.H1
            text: qsTr("Check your audio")
        }
        OrionLabel {
            role: OrionLabel.Role.Body
            tint: Theme.fgSecondary
            text: qsTr("Play a short test tone and adjust the volume. Orion OS uses PipeWire "
                      + "(with PulseAudio compatibility) — the slider below controls your "
                      + "default audio output.")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // ---- Test tone card ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Test tone")
            subtitle: qsTr("Plays the freedesktop bell sound")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Row {
                    spacing: Theme.space3
                    width: parent.width

                    OrionButton {
                        text: qsTr("Play test tone")
                        variant: OrionButton.Variant.Primary
                        size: OrionButton.Size.Default
                        onClicked: {
                            const ok = welcomeController.playTestTone();
                            if (!ok) {
                                toneErrorText.visible = true;
                            } else {
                                toneErrorText.visible = false;
                            }
                        }
                    }

                    Text {
                        id: toneErrorText
                        visible: false
                        text: qsTr("No audio player (paplay / pw-play) or sound file found. "
                                  + "Install packagekit-qt6 or pipewire-alsa.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.warning
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 200
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        // ---- Volume slider card ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Volume")
            subtitle: qsTr("Default output (sink) volume")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 480

                Row {
                    spacing: Theme.space3
                    width: parent.width

                    Text {
                        text: "🔊"
                        font.family: Theme.fontFamily
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    OrionSlider {
                        id: volumeSlider
                        width: parent.width - 100
                        anchors.verticalCenter: parent.verticalCenter
                        from: 0
                        to: 150   // PipeWire allows >100%; cap at 150.
                        value: step.currentVolume
                        onMoved: {
                            const ok = welcomeController.setVolume(
                                Math.round(volumeSlider.value));
                            if (ok) step.currentVolume = Math.round(volumeSlider.value);
                        }
                    }

                    Text {
                        text: "%1%".arg(Math.round(volumeSlider.value))
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: 14
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                        Layout.preferredWidth: 50
                    }
                }

                Text {
                    text: qsTr("Above 100% may amplify noise; 50–80% is a comfortable range "
                              + "for most speakers and headphones.")
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.fgTertiary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        Item { Layout.fillHeight: true; Layout.preferredHeight: Theme.space2 }
    }
}
