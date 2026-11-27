// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/sessionbus.cpp — Orion Shell session-bus implementation.

#include "sessionbus.h"
#include "log.h"

#include <QDBusConnection>
#include <QDBusError>

namespace Orion {

SessionBus::SessionBus(QObject *parent)
    : QObject(parent)
    , m_locked(false)
{
}

SessionBus::~SessionBus() = default;

bool SessionBus::acquireName()
{
    auto bus = QDBusConnection::sessionBus();
    if (!bus.registerService(QStringLiteral("org.orion.Shell"))) {
        qCWarning(orionShell) << "Failed to acquire org.orion.Shell:"
                               << bus.lastError().message();
        return false;
    }
    if (!bus.registerObject(QStringLiteral("/Shell"), this,
                            QDBusConnection::ExportAllSlots | QDBusConnection::ExportAllProperties)) {
        qCWarning(orionShell) << "Failed to register /Shell object:"
                               << bus.lastError().message();
        return false;
    }
    qCInfo(orionShell) << "Acquired org.orion.Shell on the session bus.";
    return true;
}

void SessionBus::setLocked(bool on)
{
    if (on == m_locked)
        return;
    m_locked = on;
    emit lockedChanged();
}

}  // namespace Orion
