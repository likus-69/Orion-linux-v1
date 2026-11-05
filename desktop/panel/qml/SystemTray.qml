// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/SystemTray.qml — system tray cluster.
//
// Four indicators from left to right:
//   * Network icon   (NetworkManager state — populated by a future
//                     Orion::SystemTrayModel C++ helper)
//   * Audio icon     (PipeWire/PulseAudio via `wpctl get-volume` — ditto)
//   * Battery icon   (UPower onBattery + Percentage)
//   * Clock          (see Clock.qml)
//
// Clicking any of them invokes the org.orion.QuickSettings D-Bus service
// (the orion-quick-settings systemd user unit) to open the quick-settings
// popover. If the service is unavailable the click is a no-op.
//
// KNOWN LIMITATION (see README): QML has no built-in raw D-Bus binding in
// stock Qt6, so the per-icon *state* properties default to sensible
// placeholders until a small C++ SystemTrayModel is added (planned for v2).
// The component is fully wired visually; only the live state plumbing is
// pending.

import QtQuick
import QtQuick.Controls.Basic
import org.orion.framework

Row {
    id: tray

    // ---- Public state (settable from C++ via context property in future) -
    property string networkState: "unknown"   // unknown|offline|disconnected|connected|connected-wifi
    property string networkSsid: ""
    property bool   audioMuted: false
    property int    audioVolume: 50           // 0..100
    property bool   onBattery: false
    property double batteryPercent: 0.65      // 0..1
    property bool   batteryCharging: false

    // Refresh signal so an external C++ model can force a re-render.
    function refresh() { __refreshTick++; }
    property int __refreshTick: 0

    implicitWidth: clock.width + networkSlot.width + audioSlot.width
                   + batterySlot.width + 3 * Theme.space2
    spacing: Theme.space2

    // ---- Network -------------------------------------------------------
    Item {
        id: networkSlot
        objectName: "networkTrayIcon"
        width: 28
        height: tray.height

        HoverHandler { id: networkHover; cursorShape: Qt.PointingHandCursor }
        TapHandler {
            onTapped: tray.openQuickSettings()
        }
        OrionIcon {
            anchors.centerIn: parent
            size: 18
            source: tray.__networkIconName()
            tint: Theme.fgPrimary
        }
        OrionTooltip {
            visible: networkHover.hovered
            text: tray.__networkTooltip()
            x: (parent.width - width) / 2
            y: -height - Theme.space1
        }
    }

    // ---- Audio ---------------------------------------------------------
    Item {
        id: audioSlot
        objectName: "audioTrayIcon"
        width: 28
        height: tray.height

        HoverHandler { id: audioHover; cursorShape: Qt.PointingHandCursor }
        TapHandler { onTapped: tray.openQuickSettings() }
        OrionIcon {
            anchors.centerIn: parent
            size: 18
            source: tray.audioMuted ? "audio-volume-muted"
                   : tray.audioVolume < 33 ? "audio-volume-low"
                   : tray.audioVolume < 66 ? "audio-volume-medium"
                   : "audio-volume-high"
            tint: Theme.fgPrimary
        }
        OrionTooltip {
            visible: audioHover.hovered
            text: tray.audioMuted
                   ? qsTr("Audio: muted")
                   : qsTr("Audio: %1%").arg(tray.audioVolume)
            x: (parent.width - width) / 2
            y: -height - Theme.space1
        }
    }

    // ---- Battery -------------------------------------------------------
    Item {
        id: batterySlot
        objectName: "batteryTrayIcon"
        width: 28
        height: tray.height

        HoverHandler { id: batteryHover; cursorShape: Qt.PointingHandCursor }
        TapHandler { onTapped: tray.openQuickSettings() }
        OrionIcon {
            anchors.centerIn: parent
            size: 18
            source: tray.__batteryIconName()
            tint: Theme.fgPrimary
        }
        OrionTooltip {
            visible: batteryHover.hovered
            text: tray.__batteryTooltip()
            x: (parent.width - width) / 2
            y: -height - Theme.space1
        }
    }

    // ---- Clock ---------------------------------------------------------
    Clock {
        id: clock
        height: tray.height
        onActivated: tray.openQuickSettings()
    }

    // ---- Quick-settings launcher ---------------------------------------
    // Emits the session-bus signal org.orion.QuickSettings.Open via the
    // C++ PanelBus helper (exposed as `panelBus` context property from
    // main.cpp). The signal-based approach lets multiple panel instances
    // share a single Quick Settings service without owning a service name.
    function openQuickSettings() {
        if (panelBus) panelBus.openQuickSettings();
    }

    // ---- Icon-name + tooltip resolvers ---------------------------------
    function __networkIconName() {
        switch (networkState) {
        case "connected":      return "network-wired";
        case "connected-wifi":  return "network-wireless-connected";
        case "disconnected":   return "network-wireless-disconnected";
        case "offline":        return "network-offline";
        default:                return "network-wireless";
        }
    }
    function __networkTooltip() {
        if (networkState === "connected-wifi" && networkSsid.length > 0)
            return qsTr("Connected to %1").arg(networkSsid);
        if (networkState === "connected")     return qsTr("Network: wired");
        if (networkState === "disconnected")  return qsTr("Network: disconnected");
        if (networkState === "offline")        return qsTr("Network: offline");
        return qsTr("Network: unknown");
    }
    function __batteryIconName() {
        const pct = Math.round(batteryPercent * 100);
        const seg = pct >= 90 ? "full"
                  : pct >= 60 ? "good"
                  : pct >= 30 ? "low"
                  : pct >= 10 ? "caution"
                  : "empty";
        return onBattery
            ? "battery-" + seg
            : (batteryCharging ? "battery-" + seg + "-charging"
                               : "battery-" + seg + "-charged");
    }
    function __batteryTooltip() {
        const pct = Math.round(batteryPercent * 100);
        if (!onBattery && batteryCharging)
            return qsTr("Charging: %1%").arg(pct);
        return onBattery
            ? qsTr("Battery: %1%").arg(pct)
            : qsTr("Plugged in: %1%").arg(pct);
    }
}
