// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/lockcontroller.cpp — Orion::LockController implementation.

#include "lockcontroller.h"
#include "log.h"

namespace Orion {

LockController::LockController(QObject *parent)
    : QObject(parent)
{
    load();
}

LockController::~LockController() = default;

void LockController::load()
{
    // TODO: Implement systemd-logind D-Bus (org.freedesktop.login1) Lock/Unlock; PAM for auth via the SDDM greeter.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionLockscreen) << "LockController::load() — skeleton, TODO";
}

void LockController::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
