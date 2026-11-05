// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import org.orion.framework

OrionButton {
    id: installBtn
    property string appId
    text: qsTr("Install")
    variant: OrionButton.Variant.Primary

    property bool installed: false
    text: installed ? qsTr("Remove") : qsTr("Install")

    onClicked: {
        if (installed) {
            pk.removePackage(appId)
        } else {
            pk.installPackage(appId)
        }
        installed = !installed
    }
}
