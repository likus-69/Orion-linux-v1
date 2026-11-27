// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/quickstate.cpp — Orion::QuickState implementation.

#include "quickstate.h"
#include "log.h"

namespace Orion {

QuickState::QuickState(QObject *parent)
    : QObject(parent)
{
    load();
}

QuickState::~QuickState() = default;

void QuickState::load()
{
    // TODO: Implement D-Bus proxies to NetworkManager, BlueZ, power-profiles-daemon, PipeWire (org.pulseaudio.Server or org.freedesktop.Pipewire).
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionQuickSettings) << "QuickState::load() — skeleton, TODO";
}

void QuickState::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
