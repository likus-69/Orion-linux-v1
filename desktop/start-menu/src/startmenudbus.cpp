// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/startmenudbus.cpp — Orion::StartMenuDBus implementation.

#include "startmenudbus.h"
#include "log.h"

namespace Orion {

StartMenuDBus::StartMenuDBus(QObject *parent)
    : QObject(parent)
{
    load();
}

StartMenuDBus::~StartMenuDBus() = default;

void StartMenuDBus::load()
{
    // TODO: Implement Acquire org.orion.StartMenu on the session bus so the panel can toggle the menu remotely.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionStartMenu) << "StartMenuDBus::load() — skeleton, TODO";
}

void StartMenuDBus::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
