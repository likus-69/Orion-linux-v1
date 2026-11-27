// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/updatemanager.cpp — Orion::UpdateManager implementation.

#include "updatemanager.h"
#include "log.h"

namespace Orion {

UpdateManager::UpdateManager(QObject *parent)
    : QObject(parent)
{
    load();
}

UpdateManager::~UpdateManager() = default;

void UpdateManager::load()
{
    // TODO: Implement PackageKit GetUpdates on a 30-minute timer; emit updatesChanged with the list of pending updates.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionUpdateManager) << "UpdateManager::load() — skeleton, TODO";
}

void UpdateManager::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
