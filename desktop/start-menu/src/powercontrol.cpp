// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/powercontrol.cpp — Orion::PowerControl implementation.

#include "powercontrol.h"
#include "log.h"

namespace Orion {

PowerControl::PowerControl(QObject *parent)
    : QObject(parent)
{
    load();
}

PowerControl::~PowerControl() = default;

void PowerControl::load()
{
    // TODO: Implement systemd-logind D-Bus: PowerOff, Reboot, Suspend, Hibernate; emit confirmation signals.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionStartMenu) << "PowerControl::load() — skeleton, TODO";
}

void PowerControl::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
