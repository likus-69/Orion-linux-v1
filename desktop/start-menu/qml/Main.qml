// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework
import org.orion.startmenu

ApplicationWindow {
    id: menu

    width: 640
    height: 700
    flags: Qt.FramelessWindowHint | Qt.Popup | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: false
    onVisibleChanged: {
        if (visible) {
            searchBar.text = "";
            searchBar.focus = true;
            // Position above the panel (assumed at bottom of primary screen).
            menu.x = Screen.width / 2 - menu.width / 2;
            menu.y = Screen.height - menu.height - 56;  // 48px panel + 8px gap
        }
    }

    onActiveFocusItemChanged: {
        if (!activeFocusItem && visible) {
            // Click outside → close.
            hide();
        }
    }

    // Background surface — apply theme + blur.
    Rectangle {
        anchors.fill: parent
        color: Theme.reduceTransparency ? Theme.surface1 : Qt.rgba(
            Theme.surface1.redF(), Theme.surface1.greenF(), Theme.surface1.blueF(), 0.92)
        radius: Theme.radiusXl
        border.width: 1
        border.color: Theme.borderSubtle

        // Subtle inner shadow.
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            color: "transparent"
            border.width: 1
            border.color: Theme.borderSubtle
            radius: parent.radius - 1
            opacity: 0.5
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.space4
        spacing: Theme.space4

        // ---- Search bar ----
        SearchBar {
            id: searchBar
            width: parent.width
            onSearchTextChanged: searchResults.model = appIndex.search(searchText)
            Keys.onPressed: (e) => {
                if (e.key === Qt.Key_Escape) menu.hide();
            }
        }

        // ---- Body: Pinned grid OR all-apps view OR search results ----
        StackLayout {
            id: body
            width: parent.width
            height: parent.height - searchBar.height - footer.height - 2 * Theme.space4

            currentIndex: searchBar.searchText.length > 0 ? 2
                       : allAppsToggle.checked ? 1
                       : 0

            PinnedGrid {
                id: pinnedGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            AllAppsView {
                id: allAppsView
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // Search results view (reuses AllAppsView's list)
            AllAppsView {
                id: searchResults
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: qsTr("Search results")
            }
        }

        // ---- Recommended section ----
        RecommendedSection {
            visible: searchBar.searchText.length === 0
            width: parent.width
        }

        // ---- All apps toggle ----
        OrionButton {
            id: allAppsToggle
            text: checked ? qsTr("Back") : qsTr("All apps")
            variant: OrionButton.Variant.Ghost
            checkable: true
            anchors.right: parent.right
        }

        // ---- Footer (user profile + power) ----
        Footer {
            id: footer
            width: parent.width
        }
    }
}
