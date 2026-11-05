// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import org.orion.framework

Item {
    ListView {
        anchors.fill: parent
        anchors.margins: Theme.space4
        clip: true
        spacing: Theme.space2
        model: []  // populated by pk.searchReady signal
        delegate: AppCard {
            width: parent.width
            appId: modelData.appId
            name: modelData.name
            summary: modelData.summary
            icon: modelData.icon
            repo: modelData.repository
        }
    }
}
