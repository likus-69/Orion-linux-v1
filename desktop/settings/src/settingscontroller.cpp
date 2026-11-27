// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/settingscontroller.cpp — Orion::SettingsController implementation.

#include "settingscontroller.h"
#include "log.h"

namespace Orion {

SettingsController::SettingsController(QObject *parent)
    : QObject(parent)
{
    load();
}

SettingsController::~SettingsController() = default;

void SettingsController::load()
{
    // TODO: Implement D-Bus proxies to logind (power), hostname1 (hostname), timedate1 (timezone), NetworkManager, accountsService.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionSettings) << "SettingsController::load() — skeleton, TODO";
}

void SettingsController::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
