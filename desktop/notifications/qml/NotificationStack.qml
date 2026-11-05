// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import org.orion.framework

Column {
    id: stack
    spacing: Theme.space2
    layoutDirection: Qt.LeftToRight

    // Live list of active notifications, kept in sync via the daemon's signals.
    ListModel { id: notifModel }

    Connections {
        target: notifDaemon
        function onNotificationAdded(n) {
            notifModel.append(n);
        }
        function onNotificationRemoved(id) {
            for (var i = 0; i < notifModel.count; ++i) {
                if (notifModel.get(i).id === id) {
                    notifModel.remove(i);
                    return;
                }
            }
        }
    }

    Repeater {
        model: notifModel
        delegate: NotificationCard {
            width: stack.width
            appName: model.appName
            summary: model.summary
            body: model.body
            iconSource: model.appIcon
            onClose: notifDaemon.CloseNotification(model.id)
        }
    }
}
