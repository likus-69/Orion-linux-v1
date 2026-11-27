// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/kwinclient.h — KWin D-Bus client for the Orion Panel taskbar.
//
// Provides a `windows` property that QML binds against to render the
// running-app portion of the taskbar. Each window is exposed as a
// QVariantMap with these keys (matching what panel/qml/Main.qml expects):
//   - uuid        (QString) — KWin's internal window id
//   - appId       (QString) — application id (maps to .desktop file id)
//   - title       (QString) — current window title
//   - isActive    (bool)
//   - isMinimized (bool)
//
// Implementation note: KWin does not expose a simple "list windows" D-Bus
// API. The canonical ways are:
//   1. The Plasma window-management protocol
//      `org.kde.plasma.window_management` (Wayland protocol via
//      PlasmaWindowManagement — the modern path)
//   2. The KWin scripting DBus interface `org.kde.kwin.Scripting` (legacy)
//   3. The foreign-toplevel-management Wayland protocol (wlroots-derived;
//      KWin supports it as of Plasma 6)
//
// This file declares the interface and the refresh/activate/minimize API.
// The initial implementation in kwinclient.cpp queries the session bus
// for the `org.kde.KWin` service and falls back to an empty list when
// KWin is not reachable. Full Plasma window-management protocol binding
// is a follow-up task (marked with TODOs in the implementation).

#pragma once

#include <QObject>
#include <QVariantList>
#include <QString>

namespace Orion {

class KWinClient : public QObject
{
    Q_OBJECT

    /// The current list of windows. Each entry is a QVariantMap with the
    /// keys documented above. QML reads this via the `panelKWin.windows`
    /// context property.
    Q_PROPERTY(QVariantList windows READ windows NOTIFY windowsChanged)

public:
    explicit KWinClient(QObject *parent = nullptr);
    ~KWinClient() override;

    QVariantList windows() const { return m_windows; }

    /// Re-queries KWin for the current window list. Safe to call from a
    /// timer (e.g. every 1s) or in response to a D-Bus signal.
    Q_INVOKABLE void refresh();

    /// Activates the window with `uuid` (brings it to the front).
    /// Returns true if the request was sent to KWin (does not guarantee
    /// KWin honored it).
    Q_INVOKABLE bool activate(const QString &uuid);

    /// Minimizes the window with `uuid`.
    Q_INVOKABLE bool minimize(const QString &uuid);

    /// Closes the window with `uuid` (gracefully, like clicking the close button).
    Q_INVOKABLE bool close(const QString &uuid);

signals:
    void windowsChanged();

private:
    QVariantList m_windows;
    bool m_kwinAvailable;
};

}  // namespace Orion
