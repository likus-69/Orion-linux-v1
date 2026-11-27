// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/notificationsdaemon.cpp — Orion::NotificationsDaemon implementation.

#include "notificationsdaemon.h"
#include "log.h"

namespace Orion {

NotificationsDaemon::NotificationsDaemon(QObject *parent)
    : QObject(parent)
{
    load();
}

NotificationsDaemon::~NotificationsDaemon() = default;

void NotificationsDaemon::load()
{
    // TODO: Implement freedesktop.org Notifications D-Bus spec at org.freedesktop.Notifications; emit Notify signals to QML.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionNotifications) << "NotificationsDaemon::load() — skeleton, TODO";
}

void NotificationsDaemon::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
