// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/kwinclient.cpp — KWin D-Bus client implementation.

#include "kwinclient.h"
#include "log.h"

#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusInterface>
#include <QDBusPendingReply>
#include <QDBusServiceWatcher>
#include <QVariantMap>

namespace Orion {

namespace {
constexpr const char *KWIN_SERVICE = "org.kde.KWin";
constexpr const char *KWIN_PATH    = "/KWin";
constexpr const char *KWIN_IFACE   = "org.kde.KWin";
}

KWinClient::KWinClient(QObject *parent)
    : QObject(parent)
    , m_kwinAvailable(false)
{
    auto bus = QDBusConnection::sessionBus();

    // Detect whether KWin is on the session bus. The KWin service name is
    // `org.kde.KWin`. (When the panel runs under a non-KWin compositor the
    // service won't exist; we then report an empty window list.)
    m_kwinAvailable = bus.interface()->isServiceRegistered(QStringLiteral(KWIN_SERVICE));

    // Watch for KWin coming or going so the panel picks up windows when
    // the compositor restarts.
    auto *watcher = new QDBusServiceWatcher(QStringLiteral(KWIN_SERVICE), bus,
                                            QDBusServiceWatcher::WatchForOwnerChange,
                                            this);
    connect(watcher, &QDBusServiceWatcher::serviceOwnerChanged,
            this, [this](const QString &, const QString &, const QString &newOwner) {
        m_kwinAvailable = !newOwner.isEmpty();
        qCInfo(orionPanel) << "KWin owner changed; available =" << m_kwinAvailable;
        if (m_kwinAvailable)
            refresh();
        else if (!m_windows.isEmpty()) {
            m_windows.clear();
            emit windowsChanged();
        }
    });

    if (m_kwinAvailable)
        refresh();
}

KWinClient::~KWinClient() = default;

void KWinClient::refresh()
{
    if (!m_kwinAvailable) {
        if (!m_windows.isEmpty()) {
            m_windows.clear();
            emit windowsChanged();
        }
        return;
    }

    // TODO: Implement real window list retrieval via the
    // PlasmaWindowManagement Wayland protocol or org.kde.plasma.window_management
    // D-Bus interface. KWin's `org.kde.KWin` D-Bus interface does not expose
    // a "queryWindows" method directly; the modern path is the Plasma
    // window-management protocol (requires qt6-waylandclient + the
    // plasma-window-management protocol XML).
    //
    // For now we leave m_windows unchanged. The empty default is sufficient
    // for the panel to render pinned apps without running-app indicators,
    // which is the desired degraded behavior when KWin integration isn't
    // available (CONTRIBUTING.md §23 rule 18).
    qCDebug(orionPanel) << "KWinClient::refresh() — TODO: implement Plasma window query";
}

bool KWinClient::activate(const QString &uuid)
{
    if (!m_kwinAvailable || uuid.isEmpty())
        return false;
    // TODO: forward to PlasmaWindowManagement.activate(uuid)
    qCDebug(orionPanel) << "KWinClient::activate(" << uuid << ") — TODO";
    return false;
}

bool KWinClient::minimize(const QString &uuid)
{
    if (!m_kwinAvailable || uuid.isEmpty())
        return false;
    // TODO: forward to PlasmaWindowManagement.setMinimized(uuid, true)
    qCDebug(orionPanel) << "KWinClient::minimize(" << uuid << ") — TODO";
    return false;
}

bool KWinClient::close(const QString &uuid)
{
    if (!m_kwinAvailable || uuid.isEmpty())
        return false;
    // TODO: forward to PlasmaWindowManagement.close(uuid)
    qCDebug(orionPanel) << "KWinClient::close(" << uuid << ") — TODO";
    return false;
}

}  // namespace Orion
