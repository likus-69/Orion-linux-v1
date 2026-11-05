// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/Main.qml — Orion File Manager top-level window.
//
// Layout:
//   ┌────────────────────────────────────────────────────────┐
//   │ Toolbar (back/forward/up · breadcrumb · view · search) │
//   ├──────────┬─────────────────────────────────────────────┤
//   │ Sidebar  │  TabBar                                     │
//   │ (places) │  ───────────────────────────                │
//   │          │  ListView / GridView (file area)            │
//   │          │  ───────────────────────────                │
//   │          │  StatusBar                                  │
//   └──────────┴─────────────────────────────────────────────┘

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import org.orion.framework

ApplicationWindow {
    id: root
    visible: true
    width: 1100
    height: 720
    minimumWidth: 720
    minimumHeight: 480
    title: qsTr("Orion File Manager — %1").arg(fileSystem.currentPath)
    color: Theme.surface0

    // ---- Tab state ---------------------------------------------------------
    // v1 uses a single shared FileSystemModel and switches the current
    // path when the user selects a different tab. Each tab remembers its
    // path so back/forward also remain per-tab (within the active tab).
    ListModel {
        id: tabs
        // Roles: path (string), title (string)
        Component.onCompleted: {
            append({ path: fileSystem.homePath(),
                     title: qsTr("Home") });
        }
    }

    property int activeTab: 0
    property string viewMode: "list"   // "list" | "icon" | "compact"
    property bool showHidden: false

    // Forward / back history per active tab. Stored as arrays of paths.
    property var backHistory: []
    property var forwardHistory: []

    function pushBack() {
        // Save current path into the back history before navigating.
        var hist = backHistory.slice();
        hist.push(fileSystem.currentPath);
        backHistory = hist;
        forwardHistory = [];
    }

    function goBack() {
        if (backHistory.length === 0) return;
        var hist = backHistory.slice();
        var target = hist.pop();
        backHistory = hist;
        var fwd = forwardHistory.slice();
        fwd.push(fileSystem.currentPath);
        forwardHistory = fwd;
        fileSystem.cd(target);
    }

    function goForward() {
        if (forwardHistory.length === 0) return;
        var fwd = forwardHistory.slice();
        var target = fwd.pop();
        forwardHistory = fwd;
        var hist = backHistory.slice();
        hist.push(fileSystem.currentPath);
        backHistory = hist;
        fileSystem.cd(target);
    }

    function goUp() {
        pushBack();
        fileSystem.cdUp();
    }

    function openPath(p) {
        if (p === fileSystem.currentPath) return;
        pushBack();
        fileSystem.cd(p);
    }

    function setActiveTab(i) {
        // Save the current path on the outgoing tab.
        if (tabs.count > 0) {
            tabs.setProperty(activeTab, "path", fileSystem.currentPath);
        }
        activeTab = i;
        var p = tabs.get(i).path;
        // Don't push history when switching tabs.
        backHistory = [];
        forwardHistory = [];
        fileSystem.cd(p);
    }

    function newTab(path) {
        if (!path) path = fileSystem.homePath();
        tabs.append({ path: path, title: tabTitleFromPath(path) });
        setActiveTab(tabs.count - 1);
    }

    function closeTab(i) {
        if (tabs.count <= 1) return; // refuse to close the last tab
        tabs.remove(i);
        if (activeTab >= tabs.count) activeTab = tabs.count - 1;
        // Reload the new active tab's path.
        fileSystem.cd(tabs.get(activeTab).path);
    }

    function tabTitleFromPath(p) {
        if (p === fileSystem.homePath()) return qsTr("Home");
        var parts = p.split("/").filter(function(s){ return s.length > 0; });
        return parts.length === 0 ? qsTr("Root") : parts[parts.length - 1];
    }

    // Sync the active tab's title to the current path basename.
    Connections {
        target: fileSystem
        function onPathChanged() {
            if (tabs.count > 0) {
                tabs.setProperty(activeTab, "path", fileSystem.currentPath);
                tabs.setProperty(activeTab, "title", tabTitleFromPath(fileSystem.currentPath));
            }
        }
        function onErrorOccurred(message) {
            errorDialog.titleText = qsTr("Error");
            errorDialog.bodyText = message;
            errorDialog.actions = [
                { text: qsTr("OK"), role: "primary", onClicked: function(){} }
            ];
            errorDialog.open();
        }
        function onConfirmDelete(paths, permanent) {
            confirmDeleteDialog.paths = paths;
            confirmDeleteDialog.permanent = permanent;
            confirmDeleteDialog.titleText = permanent
                ? qsTr("Permanently delete?")
                : qsTr("Move to trash?");
            confirmDeleteDialog.bodyText = permanent
                ? qsTr("This will permanently delete %n item(s). This cannot be undone.",
                       "", paths.length)
                : qsTr("Move %n item(s) to the trash?", "", paths.length);
            confirmDeleteDialog.actions = [
                { text: qsTr("Cancel"), role: "secondary",
                  onClicked: function(){ fileSystem.resolveDeleteConfirmation(false); } },
                { text: permanent ? qsTr("Delete") : qsTr("Move to Trash"),
                  role: "primary",
                  onClicked: function(){ fileSystem.resolveDeleteConfirmation(true); } }
            ];
            confirmDeleteDialog.open();
        }
        function onConfirmOverwrite(srcPath, dstPath) {
            overwriteDialog.srcPath = srcPath;
            overwriteDialog.dstPath = dstPath;
            overwriteDialog.titleText = qsTr("File already exists");
            overwriteDialog.bodyText = qsTr("A file named “%1” already exists in “%2”. " +
                                            "What do you want to do?")
                                        .arg(srcPath.split("/").pop())
                                        .arg(dstPath.split("/").slice(0, -1).join("/"));
            overwriteDialog.actions = [
                { text: qsTr("Skip"), role: "secondary",
                  onClicked: function(){ fileSystem.resolveOverwrite("skip"); } },
                { text: qsTr("Rename"), role: "secondary",
                  onClicked: function(){ fileSystem.resolveOverwrite("rename"); } },
                { text: qsTr("Replace"), role: "primary",
                  onClicked: function(){ fileSystem.resolveOverwrite("replace"); } }
            ];
            overwriteDialog.open();
        }
        function onProgressStarted(op, total) {
            progressOverlay.op = op;
            progressOverlay.total = total;
            progressOverlay.done = 0;
            progressOverlay.currentFile = "";
            progressOverlay.visible = true;
        }
        function onProgressChanged(done, total, currentFile) {
            progressOverlay.done = done;
            progressOverlay.total = total;
            progressOverlay.currentFile = currentFile;
        }
        function onProgressFinished(op, succeeded, failed) {
            progressOverlay.visible = false;
            if (failed > 0) {
                errorDialog.titleText = qsTr("Operation completed with errors");
                errorDialog.bodyText = qsTr("%1 of %2 item(s) failed.")
                                        .arg(failed).arg(succeeded + failed);
                errorDialog.actions = [
                    { text: qsTr("OK"), role: "primary", onClicked: function(){} }
                ];
                errorDialog.open();
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ---- Top toolbar ----
        Toolbar {
            id: toolbar
            Layout.fillWidth: true
            onBackClicked: root.goBack()
            onForwardClicked: root.goForward()
            onUpClicked: root.goUp()
            onSearchChanged: function(q) { fileSystem.filter = q; }
            onViewModeChanged: function(m) { root.viewMode = m; }
            onToggleHidden: { root.showHidden = !root.showHidden;
                                fileSystem.showHidden = root.showHidden; }
            showHidden: root.showHidden
            searchEnabled: true
            canGoBack: backHistory.length > 0
            canGoForward: forwardHistory.length > 0
            Component.onCompleted: fileSystem.showHidden = root.showHidden;
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ---- Left sidebar ----
            PlacesSidebar {
                id: sidebar
                Layout.preferredWidth: 220
                Layout.minimumWidth: 180
                Layout.fillHeight: true
                onPlaceClicked: function(path) {
                    if (path === "trash://") {
                        // For v1, just open the trash directory if it exists
                        // under XDG_DATA_HOME/Trash/files.
                        var trashPath = fileSystem.homePath() + "/.local/share/Trash/files";
                        root.openPath(trashPath);
                    } else if (path === "recent://") {
                        // Not implemented in v1 — open the user's Documents dir
                        // as a placeholder.
                        root.openPath(fileSystem.homePath());
                    } else {
                        root.openPath(path);
                    }
                }
            }

            // ---- Center column: tab bar + view + status bar ----
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                TabBar {
                    id: tabBar
                    Layout.fillWidth: true
                    tabsModel: tabs
                    activeIndex: root.activeTab
                    onTabSelected: function(i) { root.setActiveTab(i); }
                    onTabClosed: function(i) { root.closeTab(i); }
                    onNewTabRequested: { root.newTab(); }
                }

                // Breadcrumb + current folder header.
                Breadcrumb {
                    Layout.fillWidth: true
                    currentPath: fileSystem.currentPath
                    onSegmentClicked: function(p) { root.openPath(p); }
                }

                // ---- File area: ListView or GridView depending on viewMode.
                StackLayout {
                    id: fileArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: root.viewMode === "icon" ? 1
                                 : root.viewMode === "compact" ? 2
                                 : 0

                    // List view (default).
                    ListView {
                        id: listView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: fileSystem
                        delegate: FileItemDelegate {
                            width: listView.width
                            viewMode: "list"
                            name: model.name
                            path: model.path
                            iconSource: model.icon
                            sizeText: model.sizeFormatted
                            mtimeText: model.mtimeFormatted
                            isDir: model.isDir
                            isSymlink: model.isSymlink
                            isSelected: model.selected
                            onDoubleClicked: fileSystem.open(path)
                            onClicked: fileSystem.toggleSelected(path)
                            onRightClicked: contextMenu.popup()
                            onRenameRequested: function(oldName) {
                                renameDialog.oldName = oldName;
                                renameDialog.newName = oldName;
                                renameDialog.open();
                            }
                            onDeleteRequested: function(paths) {
                                fileSystem.remove(paths);
                            }
                            onTrashRequested: function(paths) {
                                fileSystem.trash(paths);
                            }
                            onCopyRequested: function(paths) {
                                clipboard.mode = "copy";
                                clipboard.paths = paths;
                            }
                            onMoveRequested: function(paths) {
                                clipboard.mode = "move";
                                clipboard.paths = paths;
                            }
                        }

                        // Empty state.
                        Text {
                            anchors.centerIn: parent
                            visible: listView.count === 0
                            text: fileSystem.filter.length > 0
                                  ? qsTr("No items match “%1”").arg(fileSystem.filter)
                                  : qsTr("This folder is empty")
                            color: Theme.fgTertiary
                            font.family: Theme.fontFamily
                            font.pixelSize: 15
                        }

                        ScrollBar.vertical: ScrollBar { }
                    }

                    // Icon view (grid).
                    GridView {
                        id: gridView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        cellWidth: 110
                        cellHeight: 110
                        model: fileSystem
                        delegate: FileItemDelegate {
                            width: gridView.cellWidth
                            height: gridView.cellHeight
                            viewMode: "icon"
                            name: model.name
                            path: model.path
                            iconSource: model.icon
                            sizeText: model.sizeFormatted
                            isDir: model.isDir
                            isSymlink: model.isSymlink
                            isSelected: model.selected
                            onDoubleClicked: fileSystem.open(path)
                            onClicked: fileSystem.toggleSelected(path)
                            onRightClicked: contextMenu.popup()
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: gridView.count === 0
                            text: qsTr("This folder is empty")
                            color: Theme.fgTertiary
                            font.family: Theme.fontFamily
                            font.pixelSize: 15
                        }

                        ScrollBar.vertical: ScrollBar { }
                    }

                    // Compact view (ListView without large icons).
                    ListView {
                        id: compactView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: fileSystem
                        delegate: FileItemDelegate {
                            width: compactView.width
                            viewMode: "compact"
                            name: model.name
                            path: model.path
                            iconSource: model.icon
                            sizeText: model.sizeFormatted
                            mtimeText: model.mtimeFormatted
                            isDir: model.isDir
                            isSymlink: model.isSymlink
                            isSelected: model.selected
                            onDoubleClicked: fileSystem.open(path)
                            onClicked: fileSystem.toggleSelected(path)
                            onRightClicked: contextMenu.popup()
                        }
                        ScrollBar.vertical: ScrollBar { }
                    }
                }

                StatusBar {
                    id: statusBar
                    Layout.fillWidth: true
                    itemCount: fileSystem.count
                    selectedCount: fileSystem.selectedPaths.length
                    selectedSizeText: fileSystem.formatSize(
                        fileSystem.totalSize(fileSystem.selectedPaths))
                    freeSpaceText: fileSystem.freeBytesFormatted
                    currentPath: fileSystem.currentPath
                }
            }
        }
    }

    // ---- Clipboard-like state for copy/move -------------------------------
    QtObject {
        id: clipboard
        property string mode: ""     // "copy" or "move"
        property var paths: []
    }

    // ---- Context menu for file area ---------------------------------------
    OrionMenu {
        id: contextMenu

        MenuItem {
            text: qsTr("Open")
            onTriggered: {
                if (fileSystem.selectedPaths.length === 1) {
                    fileSystem.open(fileSystem.selectedPaths[0]);
                }
            }
        }
        MenuItem {
            text: qsTr("Copy")
            onTriggered: {
                clipboard.mode = "copy";
                clipboard.paths = fileSystem.selectedPaths.slice();
            }
        }
        MenuItem {
            text: qsTr("Cut")
            onTriggered: {
                clipboard.mode = "move";
                clipboard.paths = fileSystem.selectedPaths.slice();
            }
        }
        MenuItem {
            text: qsTr("Paste")
            enabled: clipboard.paths.length > 0
            onTriggered: {
                if (clipboard.mode === "copy") {
                    fileSystem.copy(clipboard.paths, fileSystem.currentPath);
                } else if (clipboard.mode === "move") {
                    fileSystem.move(clipboard.paths, fileSystem.currentPath);
                }
            }
        }
        MenuSeparator {}
        MenuItem {
            text: qsTr("Rename…")
            enabled: fileSystem.selectedPaths.length === 1
            onTriggered: {
                var p = fileSystem.selectedPaths[0];
                renameDialog.oldName = p.split("/").pop();
                renameDialog.newName = renameDialog.oldName;
                renameDialog.open();
            }
        }
        MenuItem {
            text: qsTr("Move to Trash")
            enabled: fileSystem.selectedPaths.length > 0
            onTriggered: fileSystem.trash(fileSystem.selectedPaths)
        }
        MenuItem {
            text: qsTr("Delete Permanently…")
            enabled: fileSystem.selectedPaths.length > 0
            onTriggered: fileSystem.remove(fileSystem.selectedPaths)
        }
        MenuSeparator {}
        MenuItem {
            text: root.showHidden ? qsTr("Hide Hidden Files")
                                  : qsTr("Show Hidden Files")
            onTriggered: {
                root.showHidden = !root.showHidden;
                fileSystem.showHidden = root.showHidden;
            }
        }
        MenuItem {
            text: qsTr("New Folder")
            onTriggered: {
                newFolderDialog.folderName = qsTr("New Folder");
                newFolderDialog.open();
            }
        }
    }

    // ---- Dialogs ----------------------------------------------------------
    OrionDialog {
        id: errorDialog
        property string bodyText: ""
        modal: true
        anchors.centerIn: parent
        width: 420
        // Inline content because OrionDialog does not expose a body slot.
        contentItem: Text {
            text: errorDialog.bodyText
            wrapMode: Text.WordWrap
            color: Theme.fgPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 14
            width: errorDialog.width - 2 * Theme.space5
        }
    }

    OrionDialog {
        id: confirmDeleteDialog
        property var paths: []
        property bool permanent: false
        property string bodyText: ""
        modal: true
        anchors.centerIn: parent
        width: 420
        contentItem: Text {
            text: confirmDeleteDialog.bodyText
            wrapMode: Text.WordWrap
            color: Theme.fgPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 14
            width: confirmDeleteDialog.width - 2 * Theme.space5
        }
    }

    OrionDialog {
        id: overwriteDialog
        property string srcPath: ""
        property string dstPath: ""
        property string bodyText: ""
        modal: true
        anchors.centerIn: parent
        width: 460
        contentItem: Text {
            text: overwriteDialog.bodyText
            wrapMode: Text.WordWrap
            color: Theme.fgPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 14
            width: overwriteDialog.width - 2 * Theme.space5
        }
    }

    OrionDialog {
        id: renameDialog
        property string oldName: ""
        property string newName: ""
        modal: true
        anchors.centerIn: parent
        width: 420
        titleText: qsTr("Rename")
        contentItem: ColumnLayout {
            width: renameDialog.width - 2 * Theme.space5
            spacing: Theme.space2
            OrionLabel {
                text: qsTr("New name")
                role: OrionLabel.Role.Caption
                tint: Theme.fgSecondary
            }
            OrionTextField {
                id: renameField
                Layout.fillWidth: true
                text: renameDialog.newName
                focus: true
                onTextEdited: renameDialog.newName = text
                Keys.onReturnPressed: {
                    if (renameDialog.newName.length > 0 &&
                        renameDialog.newName !== renameDialog.oldName) {
                        fileSystem.rename(renameDialog.oldName, renameDialog.newName);
                    }
                    renameDialog.close();
                }
                Keys.onEscapePressed: renameDialog.close();
            }
        }
        actions: [
            { text: qsTr("Cancel"), role: "secondary",
              onClicked: function(){} },
            { text: qsTr("Rename"), role: "primary",
              onClicked: function(){
                  if (renameDialog.newName.length > 0 &&
                      renameDialog.newName !== renameDialog.oldName) {
                      fileSystem.rename(renameDialog.oldName, renameDialog.newName);
                  }
              } }
        ]
    }

    OrionDialog {
        id: newFolderDialog
        property string folderName: ""
        modal: true
        anchors.centerIn: parent
        width: 420
        titleText: qsTr("New Folder")
        contentItem: ColumnLayout {
            width: newFolderDialog.width - 2 * Theme.space5
            spacing: Theme.space2
            OrionLabel {
                text: qsTr("Folder name")
                role: OrionLabel.Role.Caption
                tint: Theme.fgSecondary
            }
            OrionTextField {
                id: folderField
                Layout.fillWidth: true
                text: newFolderDialog.folderName
                focus: true
                onTextEdited: newFolderDialog.folderName = text
                selectByMouse: true
                onActiveFocusChanged: if (activeFocus) selectAll()
                Keys.onReturnPressed: {
                    if (newFolderDialog.folderName.length > 0) {
                        fileSystem.mkdir(newFolderDialog.folderName);
                    }
                    newFolderDialog.close();
                }
                Keys.onEscapePressed: newFolderDialog.close();
            }
        }
        actions: [
            { text: qsTr("Cancel"), role: "secondary", onClicked: function(){} },
            { text: qsTr("Create"), role: "primary",
              onClicked: function(){
                  if (newFolderDialog.folderName.length > 0) {
                      fileSystem.mkdir(newFolderDialog.folderName);
                  }
              } }
        ]
    }

    // ---- Progress overlay (during copy/move/trash/delete) -----------------
    Rectangle {
        id: progressOverlay
        visible: false
        anchors.centerIn: parent
        width: 360
        height: 120
        radius: Theme.radiusLg
        color: Theme.surface2
        border.width: 1
        border.color: Theme.borderSubtle

        property string op: ""
        property int done: 0
        property int total: 0
        property string currentFile: ""

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.space4
            spacing: Theme.space2

            OrionLabel {
                text: progressOverlay.op
                role: OrionLabel.Role.BodyStrong
                tint: Theme.fgPrimary
            }

            OrionLabel {
                text: progressOverlay.currentFile
                role: OrionLabel.Role.Caption
                tint: Theme.fgSecondary
                Layout.fillWidth: true
                elide: Text.ElideMiddle
            }

            ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: Math.max(1, progressOverlay.total)
                value: progressOverlay.done
            }

            OrionLabel {
                text: qsTr("%1 of %2").arg(progressOverlay.done)
                                        .arg(progressOverlay.total)
                role: OrionLabel.Role.Caption
                tint: Theme.fgTertiary
            }
        }

        // Busy spinner used when total is unknown / indefinite.
        OrionBusy {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.space2
            running: progressOverlay.visible
            size: 18
        }
    }

    // ---- Keyboard shortcuts ----------------------------------------------
    Shortcut {
        sequence: StandardKey.Back
        onActivated: root.goBack()
    }
    Shortcut {
        sequence: "Alt+Right"
        onActivated: root.goForward()
    }
    Shortcut {
        sequence: "Alt+Up"
        onActivated: root.goUp()
    }
    Shortcut {
        sequence: "Ctrl+T"
        onActivated: root.newTab()
    }
    Shortcut {
        sequence: "Ctrl+W"
        onActivated: root.closeTab(root.activeTab)
    }
    Shortcut {
        sequence: "Ctrl+H"
        onActivated: {
            root.showHidden = !root.showHidden;
            fileSystem.showHidden = root.showHidden;
        }
    }
    Shortcut {
        sequence: "Ctrl+L"
        onActivated: toolbar.focusBreadcrumb()
    }
    Shortcut {
        sequence: StandardKey.Delete
        onActivated: {
            if (fileSystem.selectedPaths.length > 0)
                fileSystem.trash(fileSystem.selectedPaths);
        }
    }
    Shortcut {
        sequence: "Shift+Delete"
        onActivated: {
            if (fileSystem.selectedPaths.length > 0)
                fileSystem.remove(fileSystem.selectedPaths);
        }
    }
    Shortcut {
        sequence: "F2"
        onActivated: {
            if (fileSystem.selectedPaths.length === 1) {
                var p = fileSystem.selectedPaths[0];
                renameDialog.oldName = p.split("/").pop();
                renameDialog.newName = renameDialog.oldName;
                renameDialog.open();
            }
        }
    }
    Shortcut {
        sequence: "F5"
        onActivated: {
            fileSystem.cd(fileSystem.currentPath);
        }
    }
}
