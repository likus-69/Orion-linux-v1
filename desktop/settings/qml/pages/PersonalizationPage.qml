// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/pages/PersonalizationPage.qml — Personalization settings.
//
// Sections:
//   * Themes — 5 cards (orion-dark/light/midnight/aurora/high-contrast)
//   * Accent color — 7 swatches
//   * Wallpaper — grid of thumbnails
//   * Fonts — family selector
//   * Lock screen — timeout picker
//   * Desktop layout — panel position + taskbar auto-hide
//   * Animations — reduceMotion / reduceTransparency / animationsEnabled toggles

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import org.orion.framework

Flickable {
    id: page
    anchors.fill: parent
    contentWidth: width
    contentHeight: column.implicitHeight + 2 * Theme.space5
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

    readonly property var p: controller.personalization

    ColumnLayout {
        id: column
        width: page.width - 2 * Theme.space5
        x: Theme.space5
        y: Theme.space5
        spacing: Theme.space5

        // ---- Themes ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Theme")
            subtitle: qsTr("Choose a base palette for windows, panels, and apps")

            contentItem: GridLayout {
                columns: page.width > 900 ? 3 : 2
                columnSpacing: Theme.space4
                rowSpacing: Theme.space4
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Repeater {
                    model: [
                        { id: "orion-dark",          name: qsTr("Orion Dark"),
                          desc: qsTr("Deep navy + blue accent (default)") },
                        { id: "orion-light",         name: qsTr("Orion Light"),
                          desc: qsTr("Bright surfaces, darker accent") },
                        { id: "orion-midnight",      name: qsTr("Orion Midnight"),
                          desc: qsTr("Pure black, violet accent (OLED)") },
                        { id: "orion-aurora",        name: qsTr("Orion Aurora"),
                          desc: qsTr("Emerald accent on dark green") },
                        { id: "orion-high-contrast", name: qsTr("Orion High Contrast"),
                          desc: qsTr("WCAG AAA, no blur or gradients") }
                    ]
                    ThemeCard {
                        Layout.fillWidth: true
                        themeId: modelData.id
                        themeName: modelData.name
                        description: modelData.desc
                        isSelected: p.theme === modelData.id
                        onSelected: function(tid) {
                            controller.setTheme(tid);
                            Theme.currentTheme = tid;
                        }
                    }
                }
            }
        }

        // ---- Accent color ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Accent color")
            subtitle: qsTr("Used for highlights, focus rings, and primary buttons")

            contentItem: Row {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Repeater {
                    model: p.accents
                    AccentSwatch {
                        accentId: modelData.id
                        hexColor: modelData.hex
                        label: modelData.name
                        isSelected: p.accent === modelData.id
                        onSelected: function(aid) {
                            controller.setAccent(aid);
                        }
                    }
                }
            }
        }

        // ---- Wallpaper ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Wallpaper")
            subtitle: qsTr("Pick a background or browse for an image")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                // Current wallpaper preview + browse button.
                Row {
                    spacing: Theme.space4
                    width: parent.width

                    Rectangle {
                        id: preview
                        width: 160
                        height: 90
                        radius: Theme.radiusMd
                        color: Theme.surface3
                        border.width: 1
                        border.color: Theme.borderSubtle
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: p.wallpaper
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                        }
                    }

                    Column {
                        spacing: Theme.space2
                        anchors.verticalCenter: preview.verticalCenter

                        Text {
                            text: qsTr("Current: %1").arg(
                                p.wallpaper ? p.wallpaper.split("/").pop() : qsTr("(none)"))
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            color: Theme.fgSecondary
                            elide: Text.ElideRight
                            width: 280
                        }
                        OrionButton {
                            text: qsTr("Browse…")
                            variant: OrionButton.Variant.Secondary
                            size: OrionButton.Size.Compact
                            onClicked: wallpaperDialog.open()
                        }
                    }
                }

                // Wallpaper grid (from ~/.local/share/orion/wallpapers and
                // /usr/share/orion/wallpapers).
                GridView {
                    width: parent.width
                    height: cellHeight * 2 + Theme.space2
                    cellWidth: 144
                    cellHeight: 96
                    clip: true
                    model: p.wallpapers
                    delegate: Item {
                        width: GridView.view.cellWidth
                        height: GridView.view.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: Theme.space1
                            radius: Theme.radiusSm
                            color: Theme.surface3
                            border.width: p.wallpaper === modelData.path ? 2 : 1
                            border.color: p.wallpaper === modelData.path
                                          ? Theme.accent500
                                          : Theme.borderSubtle
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: modelData.path
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }
                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                            TapHandler {
                                onTapped: controller.setWallpaper(modelData.path)
                            }
                        }
                    }
                    ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }
                }
            }
        }

        // ---- Fonts ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Fonts")
            subtitle: qsTr("Default font family for the shell and apps")

            contentItem: Row {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Text {
                    text: qsTr("Family")
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.fgSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }
                OrionComboBox {
                    width: 280
                    // Lazy-load the family list on first open.
                    model: p.fontFamilies
                    onActivated: controller.setFontFamily(currentText)
                    Component.onCompleted: {
                        var idx = find(p.fontFamily);
                        if (idx >= 0) currentIndex = idx;
                    }
                }
                Item { Layout.fillWidth: true; width: 200 }
            }
        }

        // ---- Lock screen ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Lock screen")
            subtitle: qsTr("Idle timeout before the screen locks")

            contentItem: Row {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Text {
                    text: qsTr("Lock after")
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: Theme.fgSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }
                OrionComboBox {
                    id: lockCombo
                    width: 200
                    model: [
                        qsTr("Never"),
                        qsTr("30 seconds"),
                        qsTr("1 minute"),
                        qsTr("2 minutes"),
                        qsTr("5 minutes"),
                        qsTr("10 minutes"),
                        qsTr("15 minutes"),
                        qsTr("30 minutes")
                    ]
                    property var secondsMap: [0, 30, 60, 120, 300, 600, 900, 1800]
                    Component.onCompleted: {
                        var v = p.lockScreenTimeout;
                        var idx = secondsMap.indexOf(v);
                        if (idx < 0) idx = 4;
                        currentIndex = idx;
                    }
                    onActivated: {
                        controller.setLockScreenTimeout(secondsMap[currentIndex]);
                    }
                }
            }
        }

        // ---- Desktop layout ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Desktop layout")
            subtitle: qsTr("Where the Orion panel lives and how it behaves")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width

                    Text {
                        text: qsTr("Panel position")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionComboBox {
                        id: panelCombo
                        width: 160
                        model: [qsTr("Top"), qsTr("Bottom"), qsTr("Left"), qsTr("Right")]
                        property var idMap: ["top", "bottom", "left", "right"]
                        Component.onCompleted: {
                            var idx = idMap.indexOf(p.panelPosition);
                            if (idx < 0) idx = 1;
                            currentIndex = idx;
                        }
                        onActivated: controller.setPanelPosition(idMap[currentIndex])
                    }
                }

                Row {
                    spacing: Theme.space3
                    width: parent.width

                    Text {
                        text: qsTr("Auto-hide taskbar")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionSwitch {
                        checked: p.taskbarAutoHide
                        onToggled: controller.setTaskbarAutoHide(checked)
                    }
                }
            }
        }

        // ---- Animations ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Animations & transparency")
            subtitle: qsTr("Accessibility toggles for motion and translucency")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Reduce motion")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item { width: 20; height: 1 }
                    OrionSwitch {
                        checked: p.reduceMotion
                        onToggled: {
                            controller.setReduceMotion(checked);
                            Theme.reduceMotion = checked;
                        }
                    }
                    Item { width: 16; height: 1 }
                    Text {
                        text: qsTr("Disables transitions and reduces animation duration to 0 ms.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.fgTertiary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Reduce transparency")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionSwitch {
                        checked: p.reduceTransparency
                        onToggled: {
                            controller.setReduceTransparency(checked);
                            Theme.reduceTransparency = checked;
                        }
                    }
                    Item { width: 16; height: 1 }
                    Text {
                        text: qsTr("Replaces blur effects with solid surfaces.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: Theme.fgTertiary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: Theme.space3
                    width: parent.width
                    Text {
                        text: qsTr("Enable animations")
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: Theme.fgSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    OrionSwitch {
                        checked: p.animationsEnabled
                        onToggled: controller.setAnimationsEnabled(checked)
                    }
                }
            }
        }

        Item { Layout.fillHeight: true; height: Theme.space2 }
    }

    // ---- File dialog for picking a wallpaper ----
    FileDialog {
        id: wallpaperDialog
        title: qsTr("Choose a wallpaper")
        nameFilters: [qsTr("Images (*.png *.jpg *.jpeg *.webp)"), qsTr("All files (*)")]
        onAccepted: controller.setWallpaper(currentFile.toString())
    }
}
