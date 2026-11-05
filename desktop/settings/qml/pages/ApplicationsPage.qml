// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/pages/ApplicationsPage.qml — Applications settings.
//
// Sections:
//   * Installed applications — grid of .desktop entries
//   * Default applications — per-mime-type picker (xdg-mime)
//   * Startup applications — autostart toggles
//   * Repository info — pacman -Sl summary

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework

Flickable {
    id: page
    anchors.fill: parent
    contentWidth: width
    contentHeight: column.implicitHeight + 2 * Theme.space5
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

    readonly property var apps: controller.installedApps
    readonly property var repos: controller.repoInfo

    ColumnLayout {
        id: column
        width: page.width - 2 * Theme.space5
        x: Theme.space5
        y: Theme.space5
        spacing: Theme.space5

        // ---- Installed applications ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Installed applications")
            subtitle: qsTr("%n application(s) discovered", "", apps.length)

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                TextField {
                    id: appSearch
                    width: parent.width
                    placeholderText: qsTr("Search installed apps…")
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    background: Rectangle {
                        color: Theme.surface1
                        border.width: 1
                        border.color: appSearch.activeFocus
                            ? Theme.accent500 : Theme.borderDefault
                        radius: Theme.radiusMd
                    }
                }

                ListView {
                    width: parent.width
                    height: Math.min(360, contentHeight)
                    clip: true
                    model: {
                        var q = appSearch.text.toLowerCase();
                        if (q.length === 0) return apps;
                        var out = [];
                        for (var i = 0; i < apps.length; ++i) {
                            var name = (apps[i].name || "").toLowerCase();
                            if (name.indexOf(q) >= 0) out.push(apps[i]);
                        }
                        return out;
                    }
                    delegate: OrionListRow {
                        width: ListView.view.width
                        iconSource: modelData.icon || "application-x-executable"
                        title: modelData.name || modelData.id
                        subtitle: (modelData.comment || qsTr("(no description)"))
                                  + (modelData.categories && modelData.categories.length > 0
                                       ? "  · " + modelData.categories.join(", ")
                                       : "")
                        accessoryText: qsTr("Uninstall")
                        onClicked: controller.uninstallApplication(modelData.id)
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: parent.count === 0
                        text: qsTr("No applications match your search.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                    }
                }

                Text {
                    text: qsTr("Uninstalling opens Orion Software Center, which runs "
                              + "<code>pacman -R</code> via polkit. Removing system "
                              + "components may break the OS.")
                    textFormat: Text.RichText
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.fgTertiary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        // ---- Default applications ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Default applications")
            subtitle: qsTr("Per-MIME-type handlers (xdg-mime)")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Repeater {
                    model: controller.defaultApps()
                    delegate: Row {
                        spacing: Theme.space3
                        width: parent ? parent.width : 600
                        Layout.fillWidth: true

                        Text {
                            text: modelData.mimeType
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 12
                            color: Theme.fgSecondary
                            width: 240
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        OrionComboBox {
                            id: defCombo
                            width: 240
                            // Populated with installed apps that handle this MIME type.
                            // v1: just lists all installed apps and lets xdg-mime reject
                            // invalid picks. v1.1 will filter by MimeAssociate.
                            model: {
                                var out = [];
                                for (var i = 0; i < apps.length; ++i) {
                                    out.push(apps[i].id + " — " + apps[i].name);
                                }
                                return out;
                            }
                            Component.onCompleted: {
                                var targetId = modelData.appId;
                                if (targetId && targetId.length > 0) {
                                    for (var i = 0; i < count; ++i) {
                                        if (textAt(i).indexOf(targetId) === 0) {
                                            currentIndex = i;
                                            break;
                                        }
                                    }
                                }
                            }
                            onActivated: {
                                var id = currentText.split(" — ")[0];
                                controller.setDefaultApplication(modelData.mimeType, id);
                            }
                        }
                    }
                }
            }
        }

        // ---- Startup applications ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Startup applications")
            subtitle: qsTr("XDG autostart entries — toggled on or off")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                ListView {
                    width: parent.width
                    height: Math.min(220, contentHeight)
                    clip: true
                    model: controller.startupApps()
                    delegate: OrionListRow {
                        width: ListView.view.width
                        iconSource: modelData.icon || "application-x-executable"
                        title: modelData.name || modelData.id
                        subtitle: modelData.exec || qsTr("(no Exec line)")
                        onClicked: controller.toggleStartupApp(modelData.id, !modelData.enabled)
                        accessoryText: modelData.enabled ? qsTr("Enabled") : qsTr("Disabled")
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: parent.count === 0
                        text: qsTr("No autostart entries found.")
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.fgTertiary
                    }
                }
            }
        }

        // ---- Repository info ----
        OrionCard {
            Layout.fillWidth: true
            title: qsTr("Repositories")
            subtitle: repos.available
                ? qsTr("Backend: %1 · %n package(s) in %2 repo(s)", "",
                       repos.packageCount)
                    .arg(repos.backend)
                    .arg((repos.repos || []).length)
                : qsTr("Backend: unknown — pacman not available on this system")

            contentItem: Column {
                spacing: Theme.space3
                width: parent ? parent.width - 2 * Theme.space4 : 600

                Row {
                    spacing: Theme.space2
                    width: parent.width
                    visible: repos.repos && repos.repos.length > 0
                    Repeater {
                        model: repos.repos || []
                        delegate: Rectangle {
                            width: repoLabel.implicitWidth + 16
                            height: 24
                            radius: 12
                            color: Theme.surface3
                            border.width: 1
                            border.color: Theme.borderSubtle
                            property string repoName: modelData
                            Text {
                                id: repoLabel
                                anchors.centerIn: parent
                                text: parent.repoName
                                font.family: Theme.fontFamilyMono
                                font.pixelSize: 11
                                color: Theme.fgSecondary
                            }
                        }
                    }
                }

                Text {
                    text: qsTr("Generated from <code>pacman -Sl</code>. Edit "
                              + "<code>/etc/pacman.conf</code> to add or remove repositories.")
                    textFormat: Text.RichText
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: Theme.fgTertiary
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        Item { Layout.fillHeight: true; height: Theme.space2 }
    }
}
